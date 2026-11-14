import sys
from PIL import Image
import cf_tavern as TV
from cf_player import frames
from cf_palette import zoom
out = sys.argv[1]
p = TV.build(); atlas = p["tavern_tiles_v001.png"]; T = 32
MAP = ["LUUPUUUUPUUUUPUUR", "LWWQWWWWQWWWWQWWR", "LSSFF............R".replace("F","s")[:17] , "LSSSs...........R", "Lss.............R", "L...............R", "L...............R", "L...............R", "L...............R", "FFFFFFF..FFFFFFFF"]
MAP = [r.ljust(17, ".")[:17] for r in MAP]
def tile(ch, x, y):
    return {"U":(0,1),"P":(1,1),"W":(2,1),"Q":(3,1),"L":(4,1),"R":(5,1),"F":(6,1),"S":(5,0),"s":(6,0)}.get(ch)
img = Image.new("RGBA", (17*T, 10*T), (20,14,12,255))
for y,row in enumerate(MAP):
    for x,ch in enumerate(row):
        c = tile(ch,x,y)
        if c is None:
            c = (4,0) if y == 2 else ((x*7+y*3)%4, 0)
        img.alpha_composite(atlas.crop((c[0]*T,c[1]*T,c[0]*T+T,c[1]*T+T)), (x*T,y*T))
def place(im, fx, fy, foot):
    img.alpha_composite(im, (int(fx - im.width//2), int(fy - foot - 1)))
place(p["stove_v001.png"], 2*32+16, 3*32+20, 87)
img.alpha_composite(p["stove_fire_v001.png"].crop((0,0,18,8)), (2*32+16-28+19, 3*32+20-87-1+69))
place(p["copper_pot_v001.png"], 2*32+16-10, 3*32+20-28, 19)
place(p["counter_v001.png"], 4*32, 6*32+8, 47)
place(p["chair_v001.png"], 10*32+4, 5*32+16, 29)
place(p["table_v001.png"], 11*32+20, 5*32+20, 47)
place(p["chair_v001.png"].transpose(Image.FLIP_LEFT_RIGHT), 13*32+4, 5*32+16, 29)
fr = frames()
place(fr["north"]["idle"][0], 4*32, 4*32+18, 57)
place(fr["south"]["walk"][2], 8*32, 7*32+10, 57)
img.save(out + "/tavern_room_1x.png")
zoom(img, 2).save(out + "/tavern_room_x2.png")
