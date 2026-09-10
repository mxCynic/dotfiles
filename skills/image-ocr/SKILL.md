---
name: image-ocr
description: "Transcribe text out of images and screenshots into editable text or Markdown — clipboard captures, slide/chat screenshots, phone photos, tables, dark-mode UI, colored banners, Chinese and mixed scripts. Use when the user asks to read, copy, transcribe, or move text that currently exists only inside a picture. Not for describing a picture's appearance, and not for files that are already text."
---

# Image OCR

Extracted text is a draft, not a result. Tesseract reliably loses visually
similar CJK glyphs, and a confidently wrong character inside a study note is
worse than an obviously missing one. Read the output critically before handing
it on.

## Workflow

1. Locate the image. When the user says "latest"/"最新" or otherwise points at a
   folder, pick by modification time rather than by filename:

   ```bash
   find <dir> -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -printf '%T@ %p\n' | sort -n | tail -3
   ```

2. Run the helper on it:

   ```bash
   python3 scripts/ocr_image.py <image>
   ```

   It binarizes the image first, so light-on-dark (dark mode) and light text on
   colored fills (banner rows, highlighted cells) come out the same as ordinary
   text; upscaling small sources happens automatically. By default it tries
   three binarizations (band background, narrow and wide local contrast) and
   keeps whichever tesseract scores most confident — `--verbose` shows the
   scores and `--mode band|adaptive` forces one strategy when the pick is wrong.
   Other flags: `--lang chi_sim+eng` (default), `--psm 4|6|11` (layout modes),
   `--tsv` (word boxes with coordinates), `--crop x0,y0,x1,y1`,
   `--keep-bin <path>` (inspect what tesseract actually saw), `--delta`,
   `--window`, `--adaptive-window`, `--scale`.
   If Pillow or numpy is missing, run it through `uv run --with pillow --with numpy scripts/ocr_image.py <image>`.

3. Read the draft against context and fix OCR errors. Common CJK confusions to
   watch for: 己/已/巳, 未/末, 士/土, 日/曰, 干/于/千, 人/入, 全/金, 征/彷,
   简单/简陋, and any digit or Latin term embedded in Chinese text. Lists,
   tables, and section headings are strong priors — use them.

4. Re-read anything doubtful from a crop instead of guessing. Crop coordinates
   are in the source image's pixels, so they can be taken straight from
   `--tsv` boxes:

   ```bash
   python3 scripts/ocr_image.py <image> --crop 585,470,860,552 --psm 7
   ```

   `--psm 7` reads one text line, `--psm 10` one character. Changing `--psm` or
   `--delta` and getting the same answer is decent evidence a glyph is real.

5. Write the text where the user asked, keeping the original structure:
   headings, numbered lists, and Markdown tables rather than one blob. When the
   target is an existing note, append the new section and leave existing content
   untouched — the user may be editing that file at the same time.

6. Say which image the text came from so the transcription can be checked, and
   flag characters you could not resolve rather than smoothing them over.

## Tables

`--tsv` gives per-word boxes (`left top width height conf text`). Group words
into rows by their vertical position and into columns by horizontal position;
low `conf` values mark the cells worth re-reading. See
[references/tables.md](references/tables.md) for the full procedure, including
merged cells and two-line headers.

## Troubleshooting

- Empty or garbled output: save the binarized image with `--keep-bin` and look
  at it. Raise `--delta` when noise survives, lower it when faint text
  disappears, and move `--window` only if a whole band is misclassified.
- Confident nonsense from one region: the auto pick optimizes for the whole
  image, so a small header or banner cell can lose. Re-run that crop on its own
  and force `--mode band`, which handles white-on-colored text best.
- Whole regions missing: they are probably dense text on a colored or dark fill
  whose band background was misjudged — try `--window 1` or `--window 0` so the
  background is estimated locally.
- Rotated or photographed pages: deskew/rotate the image before OCR; this helper
  assumes roughly horizontal text.
- Missing language data is reported by the script; install `tesseract-data-chi_sim`
  (or the relevant pack) rather than silently dropping to `eng`.
