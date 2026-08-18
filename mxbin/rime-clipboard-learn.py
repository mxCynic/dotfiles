#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["jieba>=0.42", "pypinyin>=0.53"]
# ///
"""Learn frequently copied Chinese words and boost them in Rime (fcitx5-rime).

Rime's user dictionary already learns from what you *type*, but it has no idea
what you copy.  This script reads your clipboard history (cliphist), segments
the copied text, counts frequent words, and injects the winners into Rime's
user dictionary (luna_pinyin.userdb) with a boosted weight so they rank higher
next time you type them.

Two modes:

  --scan    Read cliphist history, update the local word-count state, and
            write a pending import file when new words cross the threshold.
  --import  Apply the pending import to Rime's user dictionary.  If fcitx5 is
            running, it is briefly stopped and restarted (LevelDB locks make
            concurrent writes unsafe); otherwise the import happens directly.

The systemd timer (systemd/user/rime-clipboard-learn.timer) runs both steps
periodically, and the Hyprland autostart also runs --import before fcitx5
starts, so words learned in a session apply on the next login without
interrupting anything.

State and pending files live under ~/.local/state; override with
RIME_USER_DIR / RIME_LEARN_STATE_DIR / RIME_LEARN_THRESHOLD if needed.
Set RIME_LEARN_SKIP_FCITX=1 to never stop/restart fcitx5 during --import.
"""

from __future__ import annotations

import argparse
import fcntl
import hashlib
import json
import os
import re
import subprocess
import sys
import time
import unicodedata
import warnings
from collections import Counter
from pathlib import Path

# jieba ships with harmless SyntaxWarnings on modern Pythons; keep logs clean.
warnings.filterwarnings("ignore")

import jieba
from pypinyin import Style, lazy_pinyin


RIME_DIR = Path(
    os.environ.get("RIME_USER_DIR", str(Path.home() / ".local/share/fcitx5/rime"))
).expanduser()
STATE_DIR = Path(
    os.environ.get("RIME_LEARN_STATE_DIR", str(Path.home() / ".local/state"))
).expanduser()
STATE_FILE = STATE_DIR / "rime-clipboard-learn.json"
PENDING_FILE = STATE_DIR / "rime-clipboard-learn.pending.txt"
LOCK_FILE = STATE_DIR / "rime-clipboard-learn.lock"

SCHEMA = os.environ.get("RIME_LEARN_SCHEMA", "luna_pinyin")

MIN_WORD_LEN = 2
MAX_WORD_LEN = 8
MAX_TOKEN_LEN = 6
BOOST_THRESHOLD = int(os.environ.get("RIME_LEARN_THRESHOLD", "3"))
BASE_WEIGHT = 60.0
WEIGHT_PER_COUNT = 8.0
MAX_WEIGHT = 300.0
MAX_HISTORY = 300
SEEN_CAP = 2000

# Common function words / fillers that are not worth boosting.
STOPWORDS = {
    "我们", "你们", "他们", "她们", "它们", "咱们", "自己", "大家",
    "这个", "那个", "这些", "那些", "这种", "那种", "这样", "那样",
    "这么", "那么", "什么", "怎么", "怎样", "如何", "哪些",
    "为什么", "干嘛", "要是", "反正", "其实", "于是", "接着",
    "同时", "另外", "甚至", "尤其", "比如", "例如", "包括", "的时候",
    "可以", "可能", "因为", "所以", "但是", "可是", "不过", "如果",
    "然后", "而且", "还是", "就是", "只是", "但是", "虽然", "尽管",
    "已经", "正在", "现在", "时候", "时间", "地方", "东西",
    "一个", "两个", "三个", "一些", "一下", "一次", "一点", "一样",
    "一直", "一起", "进行", "通过", "关于", "对于", "由于", "或者",
    "以及", "还有", "没有", "不是", "就是", "知道", "觉得", "感觉",
    "认为", "表示", "看到", "发现", "需要", "应该", "能够", "必须",
    "要求", "希望", "愿意", "开始", "结束", "完成", "发生", "出现",
    "成为", "作为", "来自", "之间", "之后", "之前", "其中", "所有",
    "整个", "任何", "其他", "别的", "每", "都", "也", "又", "再",
    "很", "太", "最", "更", "真", "好", "多", "少", "大", "小",
    "问题", "情况", "事情", "工作", "生活", "方法", "方式", "方面",
    "部分", "原因", "结果", "目的", "内容", "时候", "东西",
}


def log(msg: str) -> None:
    print(msg, flush=True)


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    kwargs.setdefault("capture_output", True)
    kwargs.setdefault("text", False)
    try:
        return subprocess.run(cmd, **kwargs)
    except FileNotFoundError:
        return subprocess.CompletedProcess(cmd, 127, b"", b"")


def cliphist_texts(max_history: int) -> list[str]:
    """Return text entries from cliphist history (newest first, capped)."""
    proc = run(["cliphist", "list"])
    if proc.returncode != 0:
        return []
    lines = proc.stdout.decode("utf-8", "replace").splitlines()[:max_history]
    texts = []
    for line in lines:
        # Skip image entries; cliphist previews them as "[[ binary data ... ]]".
        if "[[ binary data" in line:
            continue
        entry_id = line.split("\t", 1)[0].strip()
        if not entry_id.isdigit():
            continue
        # cliphist decode accepts exactly one "id<Tab>preview" line per call.
        proc = run(["cliphist", "decode"], input=(line + "\n").encode())
        if proc.returncode != 0:
            continue
        text = proc.stdout.decode("utf-8", "replace").strip()
        if not (2 <= len(text) <= 5000):
            continue
        if re.search(r"[\u4e00-\u9fff]", text):
            texts.append(text)
    return texts


CJK_RUN_RE = re.compile(r"[\u4e00-\u9fff]+")


def candidates(text: str) -> set[str]:
    """Collect candidate words from copied text.

    Includes jieba words and whole short CJK runs (so unknown phrases like
    ``你好世界`` survive segmentation).  Long sentences only contribute jieba
    words: free-floating n-grams are too noisy to learn from.
    """
    cands: set[str] = set()
    for run in CJK_RUN_RE.findall(text):
        run = run.strip()
        if not run:
            continue
        if len(run) <= MAX_WORD_LEN:
            if len(run) >= MIN_WORD_LEN:
                cands.add(run)
        for token in jieba.lcut(run):
            token = token.strip()
            if MIN_WORD_LEN <= len(token) <= MAX_TOKEN_LEN and all(
                unicodedata.category(ch) == "Lo" for ch in token
            ):
                cands.add(token)
    return cands


def filter_candidates(counts: dict[str, int]) -> list[tuple[str, int]]:
    """Drop candidates that are substrings of longer, at-least-as-frequent ones.

    ``你好`` inside ``你好世界`` should not be boosted separately; a standalone
    ``你好`` that is copied more often than ``你好世界`` survives because its
    count is higher.
    """
    items = sorted(counts.items(), key=lambda kv: (-len(kv[0]), -kv[1], kv[0]))
    kept: list[tuple[str, int]] = []
    for word, count in items:
        if any(word in longer and count <= longer_count for longer, longer_count in kept):
            continue
        kept.append((word, count))
    return kept


def to_code(word: str) -> str:
    """Full pinyin code as stored in the luna_pinyin user dictionary."""
    try:
        syllables = lazy_pinyin(word, style=Style.NORMAL)
    except Exception:
        return ""
    code = " ".join(s.replace("ü", "v") for s in syllables)
    if not code or len(code) > 80 or not re.fullmatch(r"[a-z' ]+", code):
        return ""
    return code


def load_state() -> dict:
    if not STATE_FILE.exists():
        return {"seen": [], "words": {}, "pending": []}
    try:
        state = json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except Exception:
        state = {}
    state.setdefault("seen", [])
    state.setdefault("words", {})
    state.setdefault("pending", [])
    return state


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    tmp = STATE_FILE.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")
    tmp.replace(STATE_FILE)


def acquire_lock():
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    handle = open(LOCK_FILE, "w")
    try:
        fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        handle.close()
        return None
    return handle


def scan(texts: list[str], state: dict, dry_run: bool = False) -> int:
    seen = state["seen"]
    words = state["words"]
    now = int(time.time())
    fresh: Counter = Counter()
    new_clips = 0

    for text in texts:
        digest = hashlib.sha1(text.encode("utf-8", "replace")).hexdigest()
        if digest in seen:
            continue
        seen.append(digest)
        new_clips += 1
        for token in candidates(text):
            if token in STOPWORDS:
                continue
            fresh[token] += 1

    for token, n in filter_candidates(fresh):
        entry = words.setdefault(
            token, {"count": 0, "first": now, "last": now, "boosted": False}
        )
        entry["count"] += n
        entry["last"] = now

    if len(seen) > SEEN_CAP:
        del seen[: len(seen) - SEEN_CAP]

    # Keep state small: retain words that might still reach the threshold.
    words = {w: e for w, e in words.items() if e["count"] >= 2 or w in fresh}
    state["words"] = words

    qualified = {
        w: e["count"]
        for w, e in words.items()
        if not e["boosted"] and e["count"] >= BOOST_THRESHOLD
    }
    pending = [w for w, _ in filter_candidates(qualified)]
    if pending:
        log(f"{len(pending)} new word(s) ready to boost: {', '.join(sorted(pending))}")
        if dry_run:
            return len(pending)
        if write_pending(sorted(pending), words):
            state["pending"] = sorted(pending)
    log(
        f"scan: {new_clips} new clip(s), {sum(e['count'] for e in words.values())} "
        f"total occurrence(s), {len(pending)} pending word(s)"
    )
    return len(pending)


def write_pending(words: list[str], state_words: dict) -> bool:
    lines = [
        "# Rime user dictionary",
        f"#@/db_name\t{SCHEMA}",
        "#@/db_type\tuserdb",
        "#@/tick\t0",
    ]
    entries = 0
    for word in words:
        code = to_code(word)
        if not code:
            log(f"  skip {word}: no valid pinyin code")
            continue
        count = state_words[word]["count"]
        weight = min(BASE_WEIGHT + count * WEIGHT_PER_COUNT, MAX_WEIGHT)
        # Code keys in userdb carry a trailing space; t=0 lets the merger
        # stamp entries with the live tick so they get no decay penalty.
        lines.append(f"{code} \t{word}\tc=1 d={weight:.1f} t=0")
        entries += 1
    if not entries:
        return False
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    PENDING_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return True


def fcitx_running() -> bool:
    if os.environ.get("RIME_LEARN_SKIP_FCITX") == "1":
        return False
    proc = run(["fcitx5-remote", "--check"])
    return proc.returncode == 0


def stop_fcitx(timeout: float = 10.0) -> bool:
    run(["fcitx5-remote", "-e"])
    deadline = time.time() + timeout
    while time.time() < deadline:
        if not fcitx_running():
            return True
        time.sleep(0.3)
    return not fcitx_running()


def start_fcitx(timeout: float = 10.0) -> bool:
    env = dict(os.environ)
    # The user manager usually has these imported; fetch them if missing.
    if "WAYLAND_DISPLAY" not in env:
        proc = run(["systemctl", "--user", "show-environment"])
        if proc.returncode == 0:
            for line in proc.stdout.decode("utf-8", "replace").splitlines():
                if "=" in line:
                    key, value = line.split("=", 1)
                    env[key] = value
    try:
        subprocess.Popen(
            ["fcitx5", "-d"],
            env=env,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except FileNotFoundError:
        return False
    deadline = time.time() + timeout
    while time.time() < deadline:
        if fcitx_running():
            return True
        time.sleep(0.3)
    return fcitx_running()


def do_import(state: dict, dry_run: bool = False) -> int:
    if not PENDING_FILE.exists():
        return 0
    if not RIME_DIR.is_dir():
        log(f"error: rime dir not found: {RIME_DIR}")
        return 1

    was_running = fcitx_running()
    stopped = False
    if was_running:
        log("fcitx5 is running; stopping it for the import")
        if dry_run:
            log("[dry-run] would stop fcitx5, import, then restart it")
            return 0
        if not stop_fcitx():
            log("could not stop fcitx5 (dbus unavailable?); deferring import")
            return 1
        stopped = True
    else:
        log("fcitx5 is not running; importing directly")

    try:
        proc = subprocess.run(
            ["rime_dict_manager", "--restore", str(PENDING_FILE)],
            cwd=str(RIME_DIR),
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            log(f"import failed: {proc.stdout}{proc.stderr}".strip())
            return 1
        imported = state.get("pending", []) or pending_words_from_file()
        for word in imported:
            if word in state["words"]:
                state["words"][word]["boosted"] = True
        state["pending"] = []
        save_state(state)
        PENDING_FILE.unlink(missing_ok=True)
        log(f"imported {len(imported)} word(s) into {SCHEMA} user dictionary")
        return 0
    finally:
        if stopped and not dry_run:
            if not start_fcitx():
                log("warning: fcitx5 did not come back; run 'fcitx5 -d' manually")


def pending_words_from_file() -> list[str]:
    if not PENDING_FILE.exists():
        return []
    words = []
    for line in PENDING_FILE.read_text(encoding="utf-8").splitlines():
        if line.startswith("#") or "\t" not in line:
            continue
        fields = line.split("\t")
        if len(fields) >= 2 and fields[1]:
            words.append(fields[1])
    return words


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Learn clipboard words and boost them in Rime."
    )
    parser.add_argument("--scan", action="store_true", help="scan clipboard history")
    parser.add_argument(
        "--import", dest="do_import", action="store_true", help="apply pending import"
    )
    parser.add_argument(
        "--text", metavar="TEXT", action="append", help="analyze this text (repeatable)"
    )
    parser.add_argument("--dry-run", action="store_true", help="show what would happen")
    parser.add_argument("--threshold", type=int, help="occurrences needed before boosting")
    parser.add_argument("--max-history", type=int, help="cliphist entries to scan")
    args = parser.parse_args()

    global BOOST_THRESHOLD, MAX_HISTORY
    if args.threshold:
        BOOST_THRESHOLD = args.threshold
    if args.max_history:
        MAX_HISTORY = args.max_history

    jieba.setLogLevel(60)

    lock = acquire_lock()
    if lock is None:
        log("another instance is already running; skipping")
        return 0
    try:
        state = load_state()
        if args.do_import:
            return do_import(state, args.dry_run)
        if args.text:
            texts = list(args.text)
        else:
            texts = cliphist_texts(MAX_HISTORY)
            if not texts:
                log("no clipboard text entries found (cliphist empty or missing?)")
        count = scan(texts, state, args.dry_run)
        if not args.dry_run:
            save_state(state)
        return 0 if count >= 0 else 1
    finally:
        fcntl.flock(lock, fcntl.LOCK_UN)
        lock.close()


if __name__ == "__main__":
    sys.exit(main())
