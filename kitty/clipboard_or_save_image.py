#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime
from importlib import import_module
from pathlib import Path
import re
import subprocess
from time import time_ns
from typing import Any
from urllib.parse import unquote, urlparse

from kitty.boss import Boss

result_handler: Any = getattr(import_module("kittens.tui.handler"), "result_handler")


def main(args: list[str]) -> None:
    pass


def clipboard_mime_types(boss: Boss) -> list[str] | None:
    try:
        return list(boss.clipboard.get_available_mime_types_for_paste())
    except (AttributeError, RuntimeError):
        return None


def image_mime_type(types: list[str]) -> str:
    return next((t for t in types if t.startswith("image/")), "")


def extension_for_mime(mime: str) -> str:
    return {
        "image/png": "png",
        "image/jpeg": "jpg",
        "image/webp": "webp",
        "image/gif": "gif",
        "image/bmp": "bmp",
        "image/tiff": "tiff",
        "image/svg+xml": "svg",
    }.get(mime.split(";", 1)[0].lower(), mime.removeprefix("image/").replace("+", "-"))


def output_path(out_dir: Path, ext: str) -> Path:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    return out_dir / f"clipboard-{stamp}-{time_ns()}.{ext}"


def clipboard_mime_data(boss: Boss, mime: str) -> bytes:
    return boss.clipboard.get_mime_data(mime)


def save_image_mime(boss: Boss, mime: str, out_dir: Path) -> Path:
    out_file = output_path(out_dir, extension_for_mime(mime))
    out_file.write_bytes(clipboard_mime_data(boss, mime))
    return out_file


def html_file_image(boss: Boss, types: list[str]) -> Path | None:
    for mime in ("text/html", "text/plain"):
        if mime not in types:
            continue
        try:
            html = clipboard_mime_data(boss, mime).decode("utf-8", "replace")
        except RuntimeError:
            continue
        match = re.search(r'<img\b[^>]*\bsrc=["\'](file:[^"\']+)["\']', html, re.I)
        if match:
            path = unquote(urlparse(match.group(1)).path)
            return Path("/" + path.lstrip("/") if path.startswith("//") else path)
    return None


def save_html_file_image(boss: Boss, types: list[str], out_dir: Path) -> Path | None:
    source = html_file_image(boss, types)
    if source is None:
        return None
    out_file = output_path(out_dir, source.suffix.removeprefix(".") or "img")
    out_file.write_bytes(source.read_bytes())
    return out_file


def notify(summary: str, body: str = "") -> None:
    try:
        subprocess.run(
            ["notify-send", summary, body],
            check=False,
            stderr=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
        )
    except OSError:
        pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    window = boss.window_id_map.get(target_window_id)
    out_dir = Path(
        window.cwd_of_child
        if window is not None and window.cwd_of_child
        else Path.home()
    )
    types = clipboard_mime_types(boss)
    if types is None:
        boss.paste_from_clipboard()
        return

    mime = image_mime_type(types)

    try:
        out_file = (
            save_image_mime(boss, mime, out_dir)
            if mime
            else save_html_file_image(boss, types, out_dir)
        )
    except (OSError, RuntimeError) as err:
        notify("Clipboard image", f"Failed to handle clipboard: {err}")
    else:
        if out_file is None:
            boss.paste_from_clipboard()
        else:
            notify("Clipboard image saved", str(out_file))
