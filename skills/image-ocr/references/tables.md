# Rebuilding tables from OCR

Plain OCR flattens a table into loose words, so the cell boundaries — the part
that carries the meaning — are lost. Recover them from word boxes.

## Procedure

1. Get boxes and confidence:

   ```bash
   python3 scripts/ocr_image.py <image> --tsv
   ```

2. Cluster by geometry. Sort words by `top`; words whose vertical ranges overlap
   belong to the same row. Within a row, sort by `left` and split into columns at
   the gaps that are large relative to the glyph height. Wide gaps separate
   columns, narrow ones separate words in a cell.

3. Establish the header row, then match each body row's words to the columns by
   horizontal range. Header cells are frequently the worst-recognized part of a
   screenshot (white text on a saturated fill, or a cell that wraps to two
   lines), so verify each header against its column's contents and against the
   document's domain vocabulary.

4. Fill short cells individually. A single-character cell such as 有/无/是/否 or
   an isolated number is the highest-stakes text in the image and the easiest to
   get wrong:

   ```bash
   python3 scripts/ocr_image.py <image> --crop <x0>,<y0>,<x1>,<y1> --psm 7
   python3 scripts/ocr_image.py <image> --crop <x0>,<y0>,<x1>,<y1> --mode band --psm 6
   ```

   When a crop is still ambiguous, widen it slightly so the neighbors provide
   context, or compare it against the same value elsewhere in the table. Header
   cells rendered as light text on a colored fill usually come back only with
   `--mode band`.

5. Render as a Markdown table with one column per detected column. Record merged
   cells explicitly (a value spanning two rows) rather than duplicating or
   silently dropping it, and note anything you had to infer.

## Reading a cell you cannot trust

For a stubborn glyph, print it as a coarse bitmap — the shape often settles what
OCR will not:

```python
from PIL import Image
import numpy as np

a = np.array(Image.open("<image>").convert("L"))
sub = a[y0:y1, x0:x1] < 150
for y in range(sub.shape[0]):
    print("".join("#" if v else "." for v in sub[y]))
```

Compare the same cell across rows (for example a repeated 是/否 column) before
deciding; identical shapes must be identical characters.
