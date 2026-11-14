"""Builds the Copperfern v002 review images from existing captures (no new art):
  review_compare_reference_v001_v002.png  approved reference vs v001 vs v002, forest and tavern rows
  review_keeper_sheet_labeled.png         4 directions x (4 idle + 6 walk) with labels
  review_tavern_annotated.png             current tavern, each element tagged V001 or V002

Usage: python tools/art/copperfern_v002/build_review_pack.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
DOC = ROOT / "docs/art/benchmark"
V1, V2 = DOC / "copperfern_v001", DOC / "copperfern_v002"
REF = ROOT / "docs/art-direction/copperfern-approved-top-down-reference.png"
SHEET = ROOT / "assets/art/benchmark/copperfern_v002/player_runtime_v002.png"
INK, CREAM, BG = (41, 59, 69), (241, 219, 177), (28, 36, 42)
OLD, NEW = (226, 120, 72), (120, 210, 110)


def font(size: int) -> ImageFont.ImageFont:
    for name in ("segoeuib.ttf", "arialbd.ttf", "arial.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


def fit_h(im: Image.Image, h: int, pixel: bool) -> Image.Image:
    w = round(im.width * h / im.height)
    return im.resize((w, h), Image.NEAREST if pixel else Image.LANCZOS)


def compare() -> None:
    ref = Image.open(REF).convert("RGB")
    half = ref.width // 2
    ref_forest, ref_tavern = ref.crop((0, 0, half - 10, ref.height)), ref.crop((half + 10, 0, ref.width, ref.height))
    H, PAD, TOP = 540, 24, 70
    rows = [
        ("Forest", fit_h(ref_forest, H, False), Image.open(V1 / "cf_08_forest_path.png"), Image.open(V2 / "cf_08_forest_path.png")),
        ("Tavern", fit_h(ref_tavern, H, False), Image.open(V1 / "cf_02_tavern_overview.png"), Image.open(V2 / "cf_02_tavern_overview.png")),
    ]
    rows = [(n, r, fit_h(a.convert("RGB"), H, True), fit_h(b.convert("RGB"), H, True)) for n, r, a, b in rows]
    width = PAD + max(r.width for _, r, _, _ in rows) + PAD + 960 + PAD + 960 + PAD
    out = Image.new("RGB", (width, TOP + 2 * (H + 60) + PAD), BG)
    d = ImageDraw.Draw(out)
    d.text((PAD, 18), "Copperfern review: approved reference  |  V001 (rejected, Python-drawn)  |  V002 (PixelLab + LibreSprite)",
           fill=CREAM, font=font(26))
    y = TOP
    for name, r, a, b in rows:
        x = PAD
        labels = [f"{name}: approved reference (concept)", f"{name}: V001 in Godot", f"{name}: V002 in Godot"]
        if name == "Tavern":
            labels[2] = "Tavern: V002 in Godot (only the keeper is new; room is still V001)"
        for im, label in zip((r, a, b), labels):
            d.text((x, y + 6), label, fill=CREAM, font=font(20))
            out.paste(im, (x, y + 40))
            x += im.width + PAD
            if im is r:
                x = PAD + max(rr.width for _, rr, _, _ in rows) + PAD
        y += H + 60
    out.save(V2 / "review_compare_reference_v001_v002.png")


def keeper_sheet() -> None:
    sheet = Image.open(SHEET).convert("RGBA")
    S, LW, TH = 3, 110, 60
    cell_w, cell_h = 48 * S, 64 * S
    out = Image.new("RGB", (LW + 10 * cell_w + 20, TH + 4 * cell_h), (169, 199, 78))
    d = ImageDraw.Draw(out)
    d.rectangle((0, 0, out.width, TH), fill=INK)
    d.rectangle((0, 0, LW, out.height), fill=INK)
    big = sheet.resize((sheet.width * S, sheet.height * S), Image.NEAREST)
    for col in range(10):
        x = LW + col * cell_w + (20 if col >= 4 else 0)
        d.text((x + 30, 18), (f"Idle {col + 1}" if col < 4 else f"Walk {col - 3}"), fill=CREAM, font=font(22))
        for row in range(4):
            out.paste(big.crop((col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h)),
                      (x, TH + row * cell_h), big.crop((col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h)))
    for row, name in enumerate(["South", "West", "East", "North"]):
        d.text((14, TH + row * cell_h + cell_h // 2 - 12), name, fill=CREAM, font=font(24))
    out.save(V2 / "review_keeper_sheet_labeled.png")


def tavern() -> None:
    S = 2
    shot = Image.open(V2 / "cf_02_tavern_overview.png").convert("RGB")
    im = shot.resize((shot.width * S, shot.height * S), Image.NEAREST)
    LEG = 150
    out = Image.new("RGB", (im.width, im.height + LEG), BG)
    out.paste(im, (0, 0))
    d = ImageDraw.Draw(out)
    boxes = [  # screen rect in the 640x360 capture (x0, y0, x1, y1), label, is_new, label anchor
        ((100, 45, 155, 140), "V001 stove + fire + pot", False, "below"),
        ((108, 175, 244, 222), "V001 counter", False, "below"),
        ((360, 154, 480, 206), "V001 table + 2 chairs", False, "above"),
        ((262, 200, 298, 250), "V002 keeper", True, "right"),
        ((48, 20, 592, 86), "V001 walls, posts, wainscot", False, "inside-right"),
        ((302, 278, 370, 340), "V001 doormat + doorway", False, "right"),
    ]
    f = font(20)
    for (x0, y0, x1, y1), label, new, anchor in boxes:
        c = NEW if new else OLD
        r = [x0 * S, y0 * S, x1 * S, y1 * S]
        d.rectangle(r, outline=c, width=4)
        tw = d.textlength(label, font=f)
        tx, ty = {"above": (r[0], r[1] - 28), "below": (r[0], r[3] + 4),
                  "right": (r[2] + 6, r[1]), "inside-right": (r[2] - tw - 16, r[3] - 32)}[anchor]
        d.rectangle((tx, ty, tx + tw + 10, ty + 26), fill=c)
        d.text((tx + 5, ty + 2), label, fill=(20, 20, 20), font=f)
    y = im.height + 14
    d.text((20, y), "Current tavern interior (Godot 4.7.2 capture, 640x360 shown x2).", fill=CREAM, font=font(22))
    d.rectangle((20, y + 44, 44, y + 68), fill=NEW)
    d.text((54, y + 42), "V002 - PixelLab keeper (the only new artwork in this room)", fill=CREAM, font=font(22))
    d.rectangle((20, y + 82, 44, y + 106), fill=OLD)
    d.text((54, y + 80), "V001 - everything else: floor planks, flagstones, walls, counter, table, chairs, stove, HUD/UI",
           fill=CREAM, font=font(22))
    out.save(V2 / "review_tavern_annotated.png")


if __name__ == "__main__":
    compare()
    keeper_sheet()
    tavern()
    print("ok")
