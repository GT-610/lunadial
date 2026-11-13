# Icon sources

Source artwork for the launcher icon. The build does not read this directory:
the rendered densities live in `app/src/main/res/mipmap-*` and the adaptive
icon definitions in `mipmap-anydpi-v26` / `mipmap-anydpi-v33`.

Regenerating after changing the artwork:

```bash
# legacy + adaptive densities, from the 1024x1024 sources
python3 - <<'PY'
from PIL import Image
from pathlib import Path

src, res = Path("artwork"), Path("app/src/main/res")
base = Image.open(src / "lunadial_icon.png").convert("RGBA")
fg = Image.open(src / "lunadial_icon_foreground.png").convert("RGBA")
mono = Image.open(src / "lunadial_icon_monochrome.png").convert("RGBA")

def round_mask(img):
    from PIL import ImageDraw
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).ellipse((0, 0, img.size[0] - 1, img.size[1] - 1), fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out

round_base = round_mask(base)
for name, scale in {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}.items():
    d = res / f"mipmap-{name}"
    for image, size, target in (
        (base, int(48 * scale), "ic_launcher.png"),
        (round_base, int(48 * scale), "ic_launcher_round.png"),
        (fg, int(108 * scale), "ic_launcher_foreground.png"),
        (mono, int(108 * scale), "ic_launcher_monochrome.png"),
    ):
        image.resize((size, size), Image.LANCZOS).save(d / target, optimize=True)
PY
```

The background colour is `ic_launcher_background` in
`app/src/main/res/values/colors.xml` (`#0F172A`).
