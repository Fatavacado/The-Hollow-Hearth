"""Assembles a small forest patch from the real atlas tiles via the dual-grid rule, for review."""
import sys
from PIL import Image
import cf_forest as F
from cf_player import frames
from cf_palette import zoom
out = sys.argv[1]
parts = F.build()
atlas = parts["forest_terrain_v001.png"]
MAP = [
    "##############",
    "##...#####..##",
    "#.....##......",
    "#......====...",
    "#...=====.....",
    "#..===........",
    "#..==.....#...",
    "##.==....###..",
    "###==.....#...",
]
T = 32
G, P, M = 0, 1, 3
def terr(x, y):
    if y < 0 or y >= len(MAP) or x < 0 or x >= len(MAP[0]): return M
    return {"=": P, "#": M}.get(MAP[y][x], G)
def coords(tl, tr, bl, br, seed):
    if tl == tr == bl == br:
        return {G: 0, P: 4, M: 12}[tl] + seed % 4, 3
    for t, row in ((M, 2), (P, 0)):
        if t in (tl, tr, bl, br):
            return sum(1 << i for i, c in enumerate((tl, tr, bl, br)) if c == t), row
    return 0, 3
W, H = len(MAP[0]), len(MAP)
img = Image.new("RGBA", (W * T, H * T))
for y in range(H + 1):
    for x in range(W + 1):
        cx, cy = coords(terr(x-1,y-1), terr(x,y-1), terr(x-1,y), terr(x,y), (x*7+y*13))
        img.alpha_composite(atlas.crop((cx*T, cy*T, cx*T+T, cy*T+T)), (x*T - 16, y*T - 16))
decor = parts["forest_decor_v001.png"]
for i, (x, y) in enumerate(((2,2),(6,2),(9,6),(11,4),(3,6),(7,7),(12,2),(5,5))):
    k = i % 6
    img.alpha_composite(decor.crop((k*T,0,k*T+T,T)), (x*T, y*T))
def place(im, fx, fy, foot):
    img.alpha_composite(im, (int(fx - im.width//2), int(fy - foot - 1)))
place(parts["tree_round_v001.png"], 3*32+16, 3*32, 94)
place(parts["bush_v001.png"], 7*32, 3*32, 26)
place(parts["glowcap_full_v001.png"], 9*32, 5*32+8, 24)
place(parts["glowcap_empty_v001.png"], 10*32+16, 5*32+20, 24)
place(parts["moonberry_full_v001.png"], 11*32, 3*32+4, 26)
place(parts["moonberry_empty_v001.png"], 12*32+12, 6*32, 26)
fr = frames()
place(fr["south"]["idle"][0], 6*32, 5*32+10, 57)
place(fr["east"]["walk"][1], 8*32, 6*32+20, 57)
place(parts["tree_round_v001.png"], 11*32+16, 8*32+20, 94)
img.save(out + "/forest_patch_1x.png")
zoom(img, 2).save(out + "/forest_patch_x2.png")
zoom(atlas, 2).save(out + "/forest_atlas_x2.png")
