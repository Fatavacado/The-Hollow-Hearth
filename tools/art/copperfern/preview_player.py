import sys
from PIL import Image
from cf_player import frames, DIRS
from cf_palette import zoom
out = sys.argv[1]
fr = frames()
sheet = Image.new("RGBA", (48 * 8, 64 * 4), (0, 0, 0, 0))
for r, d in enumerate(DIRS):
    for c, im in enumerate(fr[d]["idle"] + fr[d]["walk"]):
        sheet.alpha_composite(im, (c * 48, r * 64))
bg = Image.new("RGBA", sheet.size, (150, 196, 88, 255))
bg.alpha_composite(sheet)
zoom(bg, 4).save(out + "/player_sheet_x4.png")
# 1x on grass / floor / dark
strip = Image.new("RGBA", (48 * 6, 64), (0,0,0,0))
for i, col in enumerate([(150,196,88,255),(220,158,86,255),(40,50,45,255)]):
    for j, d in enumerate(("south","north")):
        tile = Image.new("RGBA",(48,64),col); tile.alpha_composite(fr[d]["idle"][0]); strip.paste(tile,(i*96+j*48,0))
zoom(strip, 3).save(out + "/player_backgrounds_x3.png")
