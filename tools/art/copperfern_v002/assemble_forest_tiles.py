"""Copperfern v002 forest terrain: PixelLab Wang tilesets -> palette-corrected DualGrid atlas.

Tiles are drawn by PixelLab create_topdown_tileset (standard, 32 px, high top-down):
  path_grass_16.png   lower = sandy path,  upper = meadow grass   (tileset bb223a1a-...)
  grass_forest_16.png lower = meadow grass, upper = undergrowth   (tileset da0f9408-..., chained
                      from the first set's grass base tile so the meadow matches)
PixelLab drew the meadow acid yellow-green and the undergrowth cool emerald, both off the approved
Copperfern palette. This script recolours by luminance rank within each colour family onto the
approved ramps (sand is kept), then lays the 16 corner tiles into the DualGrid atlas
(scripts/world/dual_grid.gd): row 0 path transitions, row 2 canopy transitions, row 3 pure tiles.

Usage: python tools/art/copperfern_v002/assemble_forest_tiles.py
"""
import colorsys
import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
SRC = ROOT / "assets/art/benchmark/copperfern_v002/source/pixellab_tiles"
OUT = ROOT / "assets/art/benchmark/copperfern_v002"
T = 32

# Approved Copperfern ramps (dark -> light). Meadow follows the approved mockup's golden-lime grass;
# undergrowth follows spruce #3E6861 / moss #829357 with a deep ink-green shadow.
MEADOW = ["#5f8a3a", "#6f9a3c", "#7ea53f", "#8eb244", "#9dbe49", "#a9c74e"]
UNDERGROWTH = ["#1f3a33", "#27473b", "#2f5541", "#386246", "#41704b", "#4d7d50"]


def hexrgb(h: str) -> tuple:
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def family(rgb: tuple) -> str:
    r, g, b = rgb
    h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    if r > g:                     # sand, earth and their blends: keep
        return "sand"
    if l < 0.30:
        return "undergrowth"
    return "meadow"


def lum(rgb: tuple) -> float:
    r, g, b = rgb
    return 0.299 * r + 0.587 * g + 0.114 * b


def build_map(images: list) -> dict:
    colours = set()
    for im in images:
        colours |= {p[:3] for p in im.getdata() if p[3]}
    mapping = {}
    for fam, ramp in (("meadow", MEADOW), ("undergrowth", UNDERGROWTH)):
        members = sorted((c for c in colours if family(c) == fam), key=lum)
        for i, c in enumerate(members):
            step = min(len(ramp) - 1, i * len(ramp) // max(1, len(members)))
            mapping[c] = hexrgb(ramp[step])
    # the two most common meadow colours are the flat base; give them the main grass tone
    return mapping


def recolour(im: Image.Image, mapping: dict) -> Image.Image:
    out = im.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a:
                px[x, y] = (*mapping.get((r, g, b), (r, g, b)), 255)
    return out


def tiles_by_mask(sheet: Image.Image, meta: dict, marked: str) -> dict:
    """mask bit i (TL, TR, BL, BR) set where that corner is the `marked` terrain."""
    order = ["NW", "NE", "SW", "SE"]
    tiles = {}
    for t in meta["tileset_data"]["tiles"]:
        mask = sum(1 << i for i, k in enumerate(order) if t["corners"][k] == marked)
        bb = t["bounding_box"]
        tiles[mask] = sheet.crop((bb["x"], bb["y"], bb["x"] + bb["width"], bb["y"] + bb["height"]))
    if sorted(tiles) != list(range(16)):
        raise SystemExit(f"tileset is missing corner masks: {sorted(tiles)}")
    return tiles


def main() -> int:
    path_sheet = Image.open(SRC / "path_grass_16.png").convert("RGBA")
    forest_sheet = Image.open(SRC / "grass_forest_16.png").convert("RGBA")
    mapping = build_map([path_sheet, forest_sheet])
    path_sheet, forest_sheet = recolour(path_sheet, mapping), recolour(forest_sheet, mapping)
    path = tiles_by_mask(path_sheet, json.loads((SRC / "path_grass_metadata.json").read_text()), "lower")
    canopy = tiles_by_mask(forest_sheet, json.loads((SRC / "grass_forest_metadata.json").read_text()), "upper")

    atlas = Image.new("RGBA", (16 * T, 4 * T), (0, 0, 0, 0))
    for mask in range(16):
        atlas.paste(path[mask], (mask * T, 0))
        atlas.paste(path[0], (mask * T, T))          # water row unused in the benchmark
        atlas.paste(canopy[mask], (mask * T, 2 * T))
    for v in range(4):                               # one drawn tile per pure terrain
        atlas.paste(path[0], (v * T, 3 * T))         # grass
        atlas.paste(path[15], ((4 + v) * T, 3 * T))  # path
        atlas.paste(path[0], ((8 + v) * T, 3 * T))   # (water: unused)
        atlas.paste(canopy[15], ((12 + v) * T, 3 * T))
    if set(atlas.getchannel("A").getdata()) - {255}:
        print("atlas has transparent or partial-alpha pixels")
        return 1
    out = OUT / "forest_terrain_v002.png"
    atlas.save(out)
    (OUT / "source/forest_terrain_v002_palette_map.json").write_text(json.dumps(
        {"#%02x%02x%02x" % k: "#%02x%02x%02x" % v for k, v in sorted(mapping.items())}, indent=1) + "\n")
    print(f"ok: {out.relative_to(ROOT)} 512x128, {len(mapping)} colours remapped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
