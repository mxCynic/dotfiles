#!/usr/bin/env python3
"""Binarize a screenshot/image and OCR it with tesseract.

Plain `tesseract image stdout` fails on two layouts that show up constantly in
screenshots: dark-mode captures (light text on dark) and colored banner rows
(light text on a saturated fill). Both binarize to solid blocks, so tesseract
returns little or nothing. Gradients and uneven lighting break fixed thresholds
the other way, turning the background into "ink".

No single threshold wins on every screenshot, so by default this script builds
several binarizations (band background, narrow and wide adaptive local
contrast), OCRs each, and keeps the one tesseract is most confident about.

Examples:
    ocr_image.py screenshot.png
    ocr_image.py screenshot.png --lang chi_sim+eng --psm 6
    ocr_image.py table.png --tsv            # word boxes for table rebuilding
    ocr_image.py scan.png --crop 600,330,860,400   # re-read one cell/glyph
    ocr_image.py scan.png --keep-bin /tmp/bin.png  # inspect what tesseract saw
    ocr_image.py scan.png --mode band --verbose    # force one strategy, show scores
"""

from __future__ import annotations

import argparse
import shutil
import statistics
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image


def fail(msg: str) -> "NoReturn":  # type: ignore[name-defined]
    sys.exit(f"ocr_image: {msg}")


def ensure_tesseract(lang: str) -> None:
    if shutil.which("tesseract") is None:
        fail("tesseract not found on PATH (install tesseract, e.g. `pacman -S tesseract`)")
    out = subprocess.run(["tesseract", "--list-langs"], capture_output=True, text=True)
    if out.returncode != 0:
        return
    available = {
        line.strip()
        for line in out.stdout.splitlines()
        if line.strip() and ":" not in line
    }
    missing = [l for l in lang.split("+") if l and l not in available]
    if missing:
        fail(
            f"tesseract language(s) {missing} not installed; available: {sorted(available)} "
            "(install e.g. `tesseract-data-chi_sim`)"
        )


def band_background(arr: np.ndarray, window: int, bins: int = 32) -> np.ndarray:
    """Most common (quantized) luminance for every row band.

    The background of a band is whatever value dominates it, so a white page
    row yields white, a dark-mode row yields near-black, and a banner row
    yields the fill color. Compared against the raw luminance, this turns any
    of those layouts into ordinary dark-on-light ink.
    """
    quantized = arr // (256 // bins)
    hist = np.zeros((quantized.shape[0], bins), dtype=np.int32)
    for y in range(quantized.shape[0]):
        hist[y] = np.bincount(quantized[y], minlength=bins)[:bins]
    padded = np.vstack([np.zeros((1, bins), dtype=np.int64), np.cumsum(hist, axis=0, dtype=np.int64)])
    rows = np.arange(quantized.shape[0])
    lo = np.clip(rows - window, 0, quantized.shape[0] - 1)
    hi = np.clip(rows + window + 1, 0, quantized.shape[0])
    band = padded[hi] - padded[lo]
    peak = np.argmax(band, axis=1).astype(np.int16)
    return (peak * (256 // bins) + (256 // bins) // 2)[:, None]


def integral(arr: np.ndarray) -> np.ndarray:
    return np.pad(arr, ((1, 0), (1, 0))).cumsum(0).cumsum(1)


def local_stats(arr: np.ndarray, window: int) -> tuple[np.ndarray, np.ndarray]:
    """Local mean and standard deviation, via integral images."""
    h, w = arr.shape
    i1, i2 = integral(arr), integral(arr * arr)
    rows, cols = np.arange(h), np.arange(w)
    y0, y1 = np.clip(rows - window // 2, 0, h - 1), np.clip(rows + window // 2 + 1, 0, h)
    x0, x1 = np.clip(cols - window // 2, 0, w - 1), np.clip(cols + window // 2 + 1, 0, w)

    def window_sum(img: np.ndarray) -> np.ndarray:
        return img[np.ix_(y1, x1)] - img[np.ix_(y0, x1)] - img[np.ix_(y1, x0)] + img[np.ix_(y0, x0)]

    count = ((y1 - y0)[:, None] * (x1 - x0)[None, :]).astype(np.float64)
    mean = window_sum(i1) / count
    var = np.maximum(window_sum(i2) / count - mean**2, 0)
    return mean, np.sqrt(var)


def candidate_masks(
    gray: np.ndarray, mode: str, delta: int, band_window: int, adaptive_window: int
) -> list[tuple[str, np.ndarray]]:
    """Binarizations to try, cheapest and most generally reliable first."""
    if mode == "band":
        return [("band", np.abs(gray - band_background(gray.astype(np.int16), band_window)) > delta)]

    floor = max(12, delta // 2)
    out: list[tuple[str, np.ndarray]] = []
    if mode in ("auto", "adaptive"):
        for win in (adaptive_window, adaptive_window * 4):
            mean, std = local_stats(gray, win)
            out.append((f"adaptive{win}", np.abs(gray - mean) > np.maximum(std, floor)))
    if mode == "auto":
        out.insert(0, ("band", np.abs(gray - band_background(gray.astype(np.int16), band_window)) > delta))
    return out


def to_image(mask: np.ndarray) -> Image.Image:
    return Image.fromarray(np.where(mask, 0, 255).astype(np.uint8))


def prepare(im: Image.Image, scale: int) -> np.ndarray:
    if scale > 1:
        im = im.resize((im.width * scale, im.height * scale), Image.LANCZOS)
    return np.asarray(im.convert("L"), dtype=np.float64)


def resolve_scale(requested: str, width: int) -> int:
    """Upscale only when the source is small.

    Screenshots are usually already large enough for tesseract; resampling them
    just adds ringing around glyph edges. Small crops and phone photos still
    benefit, so aim for roughly 1600px of width.
    """
    if requested != "auto":
        return max(1, int(requested))
    return max(1, min(4, round(1600 / max(1, width))))


def run_tesseract(bin_img: Image.Image, lang: str, psm: int, tsv: bool) -> str:
    with tempfile.TemporaryDirectory() as tmp:
        img_path = Path(tmp) / "bin.png"
        bin_img.save(img_path)
        if tsv:
            out_base = Path(tmp) / "out"
            subprocess.run(
                [
                    "tesseract",
                    str(img_path),
                    str(out_base),
                    "-l",
                    lang,
                    "--psm",
                    str(psm),
                    "-c",
                    "tessedit_create_tsv=1",
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            return (out_base.with_suffix(".tsv")).read_text(encoding="utf-8", errors="replace")
        out = subprocess.run(
            ["tesseract", str(img_path), "stdout", "-l", lang, "--psm", str(psm)],
            check=True,
            capture_output=True,
            text=True,
        )
        return out.stdout


def score_tsv(tsv: str) -> tuple[float, int]:
    """Total word confidence, used to pick the best binarization."""
    confs = []
    for row in tsv.splitlines()[1:]:
        f = row.split("\t")
        if len(f) >= 12 and f[0] == "5" and f[11].strip() and f[10] not in ("", "-1"):
            confs.append(float(f[10]))
    return (sum(confs) / 100 if confs else 0.0), len(confs)


def words_as_table(tsv: str, scale: int, dx: int, dy: int) -> str:
    """Word-level rows with coordinates mapped back to the original image."""
    lines = ["left\ttop\twidth\theight\tconf\ttext"]
    for row in tsv.splitlines()[1:]:
        f = row.split("\t")
        if len(f) < 12 or f[0] != "5":
            continue
        text = f[11].strip()
        if not text:
            continue
        l, t, w, h = (int(f[6]) // scale + dx, int(f[7]) // scale + dy,
                      int(f[8]) // scale, int(f[9]) // scale)
        lines.append(f"{l}\t{t}\t{w}\t{h}\t{f[10]}\t{text}")
    return "\n".join(lines) + "\n"


def parse_crop(spec: str) -> tuple[int, int, int, int]:
    try:
        x0, y0, x1, y1 = (int(float(v)) for v in spec.split(","))
    except ValueError:
        fail("--crop expects x0,y0,x1,y1")
    if x1 <= x0 or y1 <= y0:
        fail("--crop must satisfy x1 > x0 and y1 > y0")
    return x0, y0, x1, y1


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("images", nargs="+", help="image file(s) to OCR")
    p.add_argument("--lang", default="chi_sim+eng", help="tesseract language(s), default: %(default)s")
    p.add_argument("--psm", type=int, default=6, help="tesseract page segmentation mode, default: %(default)s")
    p.add_argument(
        "--scale",
        default="auto",
        help="upscale factor before OCR: an integer, or 'auto' to upscale small images only (default: %(default)s)",
    )
    p.add_argument("--mode", choices=("auto", "band", "adaptive"), default="auto", help="binarization strategy (default: %(default)s)")
    p.add_argument("--delta", type=int, default=45, help="luminance distance counted as ink, default: %(default)s")
    p.add_argument(
        "--window",
        type=int,
        default=2,
        help="band half-height in original pixels for --mode band (default: %(default)s)",
    )
    p.add_argument(
        "--adaptive-window",
        type=int,
        default=25,
        help="local contrast window in original pixels for --mode adaptive (default: %(default)s)",
    )
    p.add_argument("--crop", help="only read this region of the original image: x0,y0,x1,y1")
    p.add_argument("--tsv", action="store_true", help="print word boxes (left top width height conf text) instead of text")
    p.add_argument("--keep-bin", metavar="PATH", help="save the binarized image here for inspection")
    p.add_argument("--verbose", action="store_true", help="report each candidate's OCR score on stderr")
    args = p.parse_args()

    ensure_tesseract(args.lang)
    crop = parse_crop(args.crop) if args.crop else None
    band_window = max(0, args.window)
    adaptive_window = max(3, args.adaptive_window)

    for path_str in args.images:
        path = Path(path_str)
        if not path.is_file():
            fail(f"no such file: {path}")
        im = Image.open(path)
        im.load()
        if im.mode not in ("RGB", "L"):
            im = im.convert("RGB")
        dx = dy = 0
        if crop:
            x0, y0, x1, y1 = crop
            im = im.crop((x0, y0, min(x1, im.width), min(y1, im.height)))
            dx, dy = x0, y0

        scale = resolve_scale(args.scale, im.width)
        gray = prepare(im, scale)

        best: tuple[str, Image.Image, str, float] | None = None
        for name, mask in candidate_masks(
            gray, args.mode, args.delta, band_window * scale, adaptive_window * scale
        ):
            bin_img = to_image(mask)
            tsv = run_tesseract(bin_img, args.lang, args.psm, tsv=True)
            score, words = score_tsv(tsv)
            if args.verbose:
                print(f"# {path.name}: {name} score={score:.1f} words={words} ink={mask.mean():.3f}", file=sys.stderr)
            if best is None or score > best[3]:
                best = (name, bin_img, tsv, score)

        assert best is not None
        name, bin_img, tsv, score = best
        if args.verbose and len(args.images) > 1:
            print(f"# {path.name}: using {name} (score {score:.1f})", file=sys.stderr)

        if args.keep_bin:
            out = Path(args.keep_bin)
            if len(args.images) > 1:
                out = out.with_name(f"{out.stem}-{path.stem}{out.suffix}")
            out.parent.mkdir(parents=True, exist_ok=True)
            bin_img.save(out)
            print(f"# binarized image ({name}): {out}", file=sys.stderr)

        if len(args.images) > 1:
            print(f"# ==== {path}")
        if args.tsv:
            print(words_as_table(tsv, scale, dx, dy), end="")
        else:
            print(run_tesseract(bin_img, args.lang, args.psm, tsv=False), end="")


if __name__ == "__main__":
    main()
