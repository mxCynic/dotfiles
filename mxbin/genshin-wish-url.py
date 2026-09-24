#!/usr/bin/env python3
"""从原神本地缓存里取出「抽卡记录链接」（Linux / Wine / Proton 版）。

Windows 上官方给的做法是在 PowerShell 里执行：

    iex "&{$(irm https://tt.xianx.com.cn/link/ys/l.ps1)} china"

它其实只做两件事：在游戏安装目录的 webview 缓存里翻出带 authkey 的抽卡
链接，并把链接复制到剪贴板，然后粘到抽卡统计网站上使用。这个脚本在
Linux 下做同样的事，直接从 Wine / Proton 前缀里读缓存，不需要把游戏
搬到 Windows，也不需要管理员权限。

用法：

    genshin-wish-url.py                 # 自动定位游戏目录并校验链接
    genshin-wish-url.py --copy          # 顺便复制到剪贴板
    genshin-wish-url.py --no-test       # 不联网校验，直接输出最新候选
    genshin-wish-url.py --game-dir "/path/to/Genshin Impact Game"

注意：authkey 是账号凭据，等同于「一次性抽卡记录读取权限」，不要外发。
在游戏里打开一次「抽卡记录」页面会刷新缓存里的链接；旧链接会过期。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

# 游戏数据目录名 -> 服务器
GAME_DATA_DIRS = {
    "YuanShen_Data": "cn",
    "GenshinImpact_Data": "os",
}

API_HOSTS = {
    "cn": "public-operation-hk4e.mihoyo.com",
    "os": "public-operation-hk4e-sg.hoyoverse.com",
}

# 缓存里 URL 以 NUL 结尾，取一段可打印字符即可
URL_RE = re.compile(r"https?://[^\s\x00-\x1f\"'<>\\]+")

CACHE_TAIL = ("Cache", "Cache_Data", "data_2")


def default_roots() -> list[Path]:
    home = Path.home()
    return [
        home / ".local/share/Steam/steamapps/compatdata",
        home / ".wine",
        home / ".local/share/wineprefixes",
        home / ".var/app/com.usebottles.bottles/data/bottles/bottles",
        home / ".local/share/lutris",
        home / "Games",
    ]


def find_game_dirs(roots: list[Path], max_depth: int = 8) -> list[Path]:
    """在 Wine/Proton 前缀里找 *_Data 游戏目录（顶层目录名匹配即可）。"""
    found: list[Path] = []
    for root in roots:
        if not root.is_dir():
            continue
        base_depth = len(root.parts)
        for dirpath, dirnames, _ in os.walk(root, onerror=lambda _e: None):
            here = Path(dirpath)
            depth = len(here.parts) - base_depth
            for name in [d for d in dirnames if d in GAME_DATA_DIRS]:
                found.append(here / name)
            # 别走进游戏资源目录，那里面动辄几十 G
            dirnames[:] = [d for d in dirnames if d not in GAME_DATA_DIRS]
            if depth >= max_depth:
                dirnames[:] = []
    return found


def cache_files(game_dir: Path) -> list[Path]:
    """返回某游戏目录下的 webview 缓存文件，新的在前。"""
    files = []
    for version_dir in (game_dir / "webCaches").glob("*"):
        candidate = version_dir.joinpath(*CACHE_TAIL)
        if candidate.is_file():
            files.append(candidate)
    files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return files


def extract_links(path: Path) -> list[str]:
    """按官方脚本同样的思路切分缓存，取出抽卡链接，新的在前。"""
    try:
        text = path.read_bytes().decode("utf-8", "ignore")
    except OSError:
        return []

    links: list[str] = []
    for chunk in text.split("1/0/"):
        if "webview_gacha" not in chunk:
            continue
        for url in URL_RE.findall(chunk):
            if "authkey=" in url and ("getGachaLog" in url or "/gacha" in url):
                links.append(url)

    seen: set[str] = set()
    ordered = [u for u in links if not (u in seen or seen.add(u))]
    return ordered[::-1]


def probe_url(link: str, api_host: str) -> str:
    """把抽卡链接改写成 getGachaLog 接口地址（等同官方脚本的 testUrl）。"""
    parts = urllib.parse.urlsplit(link)
    params = [
        (k, v)
        for k, v in urllib.parse.parse_qsl(parts.query, keep_blank_values=True)
        if k not in ("lang", "gacha_type", "size")
    ]
    params += [("lang", "en"), ("gacha_type", "301"), ("size", "5"), ("lang", "en-us")]
    return urllib.parse.urlunsplit(
        ("https", api_host, "/gacha_info/api/getGachaLog", urllib.parse.urlencode(params), "")
    )


def is_valid(link: str, api_host: str, timeout: float = 10.0) -> tuple[bool, str]:
    request = urllib.request.Request(
        probe_url(link, api_host),
        headers={"User-Agent": "Mozilla/5.0", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            payload = json.load(response)
    except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
        return False, f"请求失败：{exc}"
    return payload.get("retcode") == 0, str(payload.get("message", ""))


def copy_to_clipboard(text: str) -> str | None:
    for command in (["wl-copy"], ["xclip", "-selection", "clipboard"], ["xsel", "-ib"]):
        if shutil.which(command[0]) is None:
            continue
        try:
            subprocess.run(command, input=text.encode(), check=True)
        except (subprocess.CalledProcessError, OSError):
            continue
        return command[0]
    return None


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="从原神（国服/国际服）本地缓存中提取抽卡记录链接",
    )
    parser.add_argument("--game-dir", help="游戏目录，例如 '.../Genshin Impact Game'")
    parser.add_argument("--region", choices=sorted(API_HOSTS), help="覆盖服务器判断（cn/os）")
    parser.add_argument("--no-test", action="store_true", help="跳过联网校验")
    parser.add_argument("--copy", action="store_true", help="把结果复制到剪贴板")
    parser.add_argument("--all", action="store_true", help="列出所有候选链接")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)

    if args.game_dir:
        game_dirs = []
        root = Path(args.game_dir).expanduser()
        for name in GAME_DATA_DIRS:
            candidate = root / name
            if candidate.is_dir():
                game_dirs.append(candidate)
        if not game_dirs and root.name in GAME_DATA_DIRS:
            game_dirs = [root]
        if not game_dirs:
            print(f"在 {root} 下没有找到 YuanShen_Data / GenshinImpact_Data", file=sys.stderr)
            return 1
    else:
        game_dirs = find_game_dirs(default_roots())
        if not game_dirs:
            print(
                "没有找到原神安装目录。可以手动指定：\n"
                "    genshin-wish-url.py --game-dir '/path/to/Genshin Impact Game'",
                file=sys.stderr,
            )
            return 1

    game_dirs.sort(key=lambda p: p.stat().st_mtime, reverse=True)

    for game_dir in game_dirs:
        region = args.region or GAME_DATA_DIRS.get(game_dir.name, "cn")
        api_host = API_HOSTS[region]
        files = cache_files(game_dir)
        if not files:
            continue

        print(f"游戏目录：{game_dir}", file=sys.stderr)
        print(f"服务器　：{region}（{api_host}）", file=sys.stderr)

        links: list[str] = []
        for cache in files:
            links.extend(extract_links(cache))
        # 跨缓存文件再去重，顺序保持「新 -> 旧」
        seen: set[str] = set()
        links = [u for u in links if not (u in seen or seen.add(u))]

        if not links:
            print(
                f"缓存里没有抽卡链接：{files[0]}\n"
                "先在游戏里打开一次「抽卡记录」页面（祈愿 -> 历史记录），再运行本脚本。",
                file=sys.stderr,
            )
            continue

        if args.all:
            for link in links:
                print(link)
            return 0

        if args.no_test:
            link = links[0]
        else:
            link = ""
            for index, candidate in enumerate(links, start=1):
                print(f"\r校验第 {index}/{len(links)} 条链接…", end="", file=sys.stderr, flush=True)
                ok, message = is_valid(candidate, api_host)
                if ok:
                    link = candidate
                    break
                if message:
                    print(f"\n  跳过：{message}", file=sys.stderr)
            print("", file=sys.stderr)
            if not link:
                print(
                    "所有候选链接都失效了（authkey 过期）。\n"
                    "请在游戏里重新打开一次「抽卡记录」页面，再运行本脚本。",
                    file=sys.stderr,
                )
                continue

        print(link)
        if args.copy:
            tool = copy_to_clipboard(link)
            if tool:
                print(f"（已用 {tool} 复制到剪贴板）", file=sys.stderr)
            else:
                print("（没找到 wl-copy/xclip/xsel，未能复制）", file=sys.stderr)
        return 0

    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
