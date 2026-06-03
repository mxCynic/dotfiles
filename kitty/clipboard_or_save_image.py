#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime
from importlib import import_module
from pathlib import Path
import re
from shlex import quote
import subprocess
from time import time_ns
from typing import Any, Literal, overload
from urllib.parse import unquote, urlparse

from kitty.boss import Boss

result_handler: Any = getattr(import_module("kittens.tui.handler"), "result_handler")


def main(args: list[str]) -> None:
    pass


@overload
def wl_paste(*args: str, text: Literal[True]) -> str: ...


@overload
def wl_paste(*args: str, text: Literal[False] = False) -> bytes: ...


def wl_paste(*args: str, text: bool = False) -> str | bytes:
    return subprocess.check_output(
        ["wl-paste", *args], stderr=subprocess.DEVNULL, text=text
    )


def image_mime_type() -> str:
    try:
        return next(
            (
                t
                for t in wl_paste("--list-types", text=True).splitlines()
                if t.startswith("image/")
            ),
            "",
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""


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


def save_image_mime(mime: str, out_dir: Path) -> Path:
    out_file = output_path(out_dir, extension_for_mime(mime))
    out_file.write_bytes(wl_paste("--type", mime))
    return out_file


def html_file_image() -> Path | None:
    for mime in ("text/html", "text/plain"):
        try:
            html = wl_paste("--type", mime, text=True)
        except subprocess.CalledProcessError:
            continue
        match = re.search(r'<img\b[^>]*\bsrc=["\'](file:[^"\']+)["\']', html, re.I)
        if match:
            path = unquote(urlparse(match.group(1)).path)
            return Path("/" + path.lstrip("/") if path.startswith("//") else path)
    return None


def save_html_file_image(out_dir: Path) -> Path | None:
    source = html_file_image()
    if source is None:
        return None
    out_file = output_path(out_dir, source.suffix.removeprefix(".") or "img")
    out_file.write_bytes(source.read_bytes())
    return out_file


def print_in_shell(message: str) -> str:
    return f"printf '%s\\n' {quote(message)}\r"


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
    mime = image_mime_type()

    try:
        out_file = (
            save_image_mime(mime, out_dir) if mime else save_html_file_image(out_dir)
        )
    except (OSError, subprocess.CalledProcessError) as err:
        if window is not None:
            window.write_to_child(
                print_in_shell(f"Failed to save clipboard image: {err}")
            )
    else:
        if out_file is None:
            boss.paste_from_clipboard()
        elif window is not None:
            window.write_to_child(print_in_shell(f"Clipboard image saved: {out_file}"))
