"""Original Copperfern v2 native terrain art; no image/asset-pack input pixels.

Keeps the a8085de runtime atlas interfaces: 32px cells; forest 16x4 corner masks,
eight decor cells; tavern 8x2. All outputs are deterministic. Geometry and palette
are authored here rather than re-running the placeholder generators.

Run: python tools/art/codex_v2_terrain.py [--check-only]
"""
from __future__ import annotations
import argparse
import math
import random
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/art/tiles'
T=32
P={
'g0':'#294B3D','g1':'#3F6542','g2':'#5A8049','g3':'#73964F','g4':'#91AD60','g5':'#ADC574',
'd0':'#97794F','d1':'#B09363','d2':'#C4A775','d3':'#D2B988','d4':'#E1CA9C',
'b0':'#285B62','b1':'#367B7B','b2':'#499792','b3':'#69B0A5','b4':'#94C9B7','b5':'#C3DDC7',
'w0':'#48382F','w1':'#654B36','w2':'#826141','w3':'#A17A4E','w4':'#B68F5E','w5':'#CAA573','w6':'#DDC095',
'c0':'#AE9771','c1':'#C9B38A','c2':'#DECCA4','c3':'#ECDEBA','s0':'#4F5551','s1':'#6B7568','s2':'#939984','s3':'#B8BBA1',
'r0':'#774435','r1':'#9E5D43','r2':'#BD7B55','r3':'#D49A6C','teal':'#477F74','cream':'#F0E2B6',
}
def col(n):
 h=P.get(n,n).lstrip('#');return tuple(bytes.fromhex(h))+(255,)
def new(w=32,h=32):return Image.new('RGBA',(w,h))
def draw(im):return ImageDraw.Draw(im)
def flat(n):return Image.new('RGBA',(T,T),col(n))
def periodic(im):
 # Tile endpoints share exact samples; variant overlays stay off this border.
 for i in range(T):
  im.putpixel((31,i),im.getpixel((0,i)));im.putpixel((i,31),im.getpixel((i,0)))
 im.putpixel((31,31),im.getpixel((0,0)));return im

def grass():
 im=flat('g3');d=draw(im)
 # Broad quiet leaf-green masses. Tufts are asymmetric two/three pixel clusters,
 # not dense independent noise; the decor atlas supplies the taller silhouettes.
 clusters=[(3,5,6,3,'g2'),(17,18,8,3,'g2'),(9,26,7,2,'g4'),(21,7,5,2,'g4'),(4,16,4,2,'g4')]
 for x,y,w,h,c in clusters:d.polygon([(x,y),(x+w,y),(x+w+2,y+1),(x+w,y+h),(x+1,y+h)],fill=col(c))
 for x,y in [(7,10),(24,24),(15,4),(4,27)]:
  d.line((x,y+2,x+1,y),fill=col('g4'));d.point((x+2,y+2),fill=col('g2'))
 return periodic(im)
def path():
 im=flat('d2');d=draw(im)
 for x,y,w in [(3,5,9),(18,17,8),(6,26,5)]:d.line((x,y,x+w,y),fill=col('d3'))
 for x,y in [(8,17),(24,8),(18,28)]:d.line((x,y,x+2,y),fill=col('d1'));d.point((x,y-1),fill=col('d3'))
 return periodic(im)
def water():
 im=flat('b2');d=draw(im)
 # Long stepped bands make water read as horizontal surface at game scale.
 for x,y,w in [(1,5,11),(18,12,10),(4,22,14),(24,28,5)]:
  d.line((x,y,x+w,y),fill=col('b3'));d.line((x+2,y+1,x+w+2,y+1),fill=col('b1'))
 for x,y,w in [(7,8,5),(23,20,4)]:d.line((x,y,x+w,y),fill=col('b4'))
 return periodic(im)
def canopy():
 im=flat('g0');d=draw(im)
 for x,y,w,h in [(1,2,14,11),(16,1,14,10),(9,13,16,12),(-5,20,14,11),(24,17,13,14)]:
  d.polygon([(x+3,y),(x+w-4,y),(x+w,y+4),(x+w-1,y+h-3),(x+w-5,y+h),(x+2,y+h-1),(x,y+4)],fill=col('g1'))
  d.polygon([(x+3,y),(x+w-4,y),(x+w-2,y+4),(x+w-6,y+7),(x+3,y+6),(x+1,y+3)],fill=col('g2'))
  d.line((x+4,y+1,x+8,y+1),fill=col('g3'))
 return periodic(im)

def variant(base,kind,i):
 im=base.copy();d=draw(im)
 if kind=='grass':
  for x,y in [(6+i*4,12),(20-i*3,23)][:i%3]:
   d.line((x,y+2,x+1,y),fill=col('g4'));d.line((x+2,y+2,x+3,y+1),fill=col('g2'))
 elif kind=='path':
  if i:
   x,y=6+i*4,9+i*3;d.rectangle((x,y,x+2,y+1),fill=col('d1'));d.line((x,y,x+1,y),fill=col('d3'))
 elif kind=='water':
  if i:d.line((6+i*3,16,10+i*3,16),fill=col('b4'))
 elif kind=='canopy':
  if i:d.line((8+i*4,17,11+i*4,17),fill=col('g3'))
 return im

def field(mask,x,y):
 tl,tr,bl,br=[(mask>>i)&1 for i in range(4)]
 u,v=x/31,y/31
 # Bilinear corner field; authored periodic scalloping vanishes at edges, so
 # all compatible masks have EXACTLY identical shared edge samples.
 f=(tl*(1-u)+tr*u)*(1-v)+(bl*(1-u)+br*u)*v
 ripple=math.sin(math.pi*u)*math.sin(math.pi*v)*(math.sin(x*.53+y*.31)*.023+math.sin(y*.71-x*.22)*.018)
 return f+ripple

def transition(lower,upper,mask,kind):
 if mask==0:return lower.copy()
 if mask==15:return upper.copy()
 im=new();d=draw(im)
 def up(x,y):return field(mask,x,y)>.5
 for y in range(T):
  for x in range(T):
   hi=up(x,y);c=upper.getpixel((x,y)) if hi else lower.getpixel((x,y))
   # Keep one canonical edge pixel. Interior shoreline/detail does not alter
   # shared boundary samples, even for diagonal/saddle masks.
   if 0<x<31 and 0<y<31:
    near=any(up(nx,ny)!=hi for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)])
    if near:
     if kind=='path':c=col('d1') if hi else col('g2')
     elif kind=='water':c=col('b1') if hi else col('d1')
     else:c=col('g0') if hi else col('g1')
    elif kind=='water':
     if hi and any(not up(nx,ny) for nx,ny in [(x-2,y),(x+2,y),(x,y-2),(x,y+2)]):c=col('b3')
     elif not hi and up(x,y+2):c=col('d3')
    elif kind=='path' and not hi and up(x,y+2) and (x+2*y)%7<3:c=col('g4')
    elif kind=='canopy' and not hi and (up(x,y-2) or up(x,y-3)):c=col('g2')
   im.putpixel((x,y),c)
 return im

def decor():
 tiles=[]
 for i in range(4):
  im=new();d=draw(im)
  for j,(x,y) in enumerate([(8,15),(19,22),(23,9)]):
   x+=(i+j)%3-1;y+=(i*2+j)%3-1
   d.line((x,y+2,x,y+6),fill=col('g1'));d.line((x-2,y+4,x,y+5),fill=col('g2'))
   pet=['#E7DAB4','#C9D6B0','#A7C4B8','#D7AC8C'][i]
   d.rectangle((x-1,y-1,x+1,y+1),fill=col(pet));d.point((x,y),fill=col('#D6B66C'));d.point((x,y-2),fill=col('cream'))
  tiles.append(im)
 for i in range(2):
  im=new();d=draw(im)
  for x,y,h in [(11,18,7),(15,21,10),(20,19,6)]:
   x+=i*2-1;d.line((x,y+7,x-1,y+7-h),fill=col('g2'));d.line((x+1,y+6,x+3,y+2),fill=col('g4'));d.point((x-1,y+7-h),fill=col('g5'))
  tiles.append(im)
 im=new();d=draw(im)
 for x,y in [(9,20),(20,14),(23,25)]:d.polygon([(x,y),(x+2,y-1),(x+4,y+1),(x+3,y+2),(x,y+2)],fill=col('s1'));d.line((x+1,y,x+2,y),fill=col('s3'))
 tiles.append(im)
 im=new();d=draw(im)
 for x,y in [(7,12),(19,17),(23,25)]:d.polygon([(x,y+2),(x+2,y),(x+5,y+1),(x+3,y+3)],fill=col('d0'));d.line((x+1,y+2,x+3,y+1),fill=col('d2'))
 tiles.append(im);return tiles

def floor(i):
 im=flat('w4');d=draw(im)
 # Each plank is shaded as one material plane, with fine long grain clusters
 # and occasional curved knots rather than salt-and-pepper variation.
 for y in range(0,32,8):
  d.rectangle((0,y,31,y+6),fill=col('w4'))
  d.line((0,y,31,y),fill=col('w5'));d.line((0,y+7,31,y+7),fill=col('w2'))
  offset=(y//8*13+i*9)%24+4
  d.line((offset,y+1,offset,y+6),fill=col('w3'))
  d.line((3,y+3,13,y+3),fill=col('w3'));d.line((17,y+5,27,y+5),fill=col('w5'))
 if i:
  x,y=8+i*4,10+(i%2)*8;d.ellipse((x,y,x+5,y+2),outline=col('w3'));d.line((x-2,y+1,x+7,y+1),fill=col('w3'));d.point((x+2,y+1),fill=col('w2'))
 # Variants share every boundary pixel, including plank joins.
 base_boundary=[col('w5') if y%8==0 else col('w2') if y%8==7 else col('w4') for y in range(32)]
 for y,c in enumerate(base_boundary):im.putpixel((0,y),c);im.putpixel((31,y),c)
 # 32px plank atlas has a deliberate horizontal groove at each tile boundary.
 for x in range(32):im.putpixel((x,0),col('w2'));im.putpixel((x,31),col('w2'))
 return im

def wall(tile):
 im=flat('c2');d=draw(im)
 if tile==0:
  im=flat('w0');d=draw(im);d.rectangle((0,16,31,24),fill=col('w2'));d.line((0,16,31,16),fill=col('w4'));d.rectangle((0,25,31,28),fill=col('w1'));d.line((0,28,31,28),fill=col('w0'))
 elif tile in [1,2]:
  # Cream lime plaster: small sparse connected nicks, not grunge noise.
  for x,y in [(3,15),(21,8),(9,26)]:d.line((x,y,x+4,y),fill=col('c1'));d.point((x+1,y-1),fill=col('c3'))
  d.rectangle((0,0,31,3),fill=col('w1'));d.line((0,4,31,4),fill=col('c0'))
  if tile==2:
   d.rectangle((12,0,19,31),fill=col('w2'));d.line((13,0,13,31),fill=col('w4'));d.line((18,0,18,31),fill=col('w1'));d.rectangle((12,14,19,17),fill=col('w3'));d.point((15,15),fill=col('w1'))
 elif tile==3:
  im=flat('w2');d=draw(im);d.rectangle((0,1,31,4),fill=col('w4'));d.line((0,0,31,0),fill=col('w5'));d.line((0,5,31,5),fill=col('w0'))
  for x in [2,18]:
   d.rectangle((x,9,x+11,26),fill=col('w1'));d.rectangle((x+1,10,x+10,24),fill=col('w3'));d.line((x+2,11,x+9,11),fill=col('w4'));d.line((x+9,12,x+9,23),fill=col('w2'))
  d.rectangle((0,28,31,31),fill=col('w0'));d.line((0,28,31,28),fill=col('w3'))
 elif tile in [4,5,6]:
  im=flat('s1');d=draw(im)
  for y in range(0,32,8):
   d.line((0,y,31,y),fill=col('s0'))
   for x in range((y//8%2)*8,32,16):d.line((x,y,x,y+7),fill=col('s0'));d.line((x+1,y+1,min(x+14,31),y+1),fill=col('s2'))
  if tile==6:d.rectangle((0,0,31,3),fill=col('w1'));d.line((0,0,31,0),fill=col('w3'))
  else:
   x=28 if tile==4 else 0;d.rectangle((x,0,x+3,31),fill=col('w1'));d.line((x if tile==5 else x+3,0,x if tile==5 else x+3,31),fill=col('w0'))
 return im

def save_outputs():
 OUT.mkdir(parents=True,exist_ok=True)
 bases=[grass(),path(),water(),canopy()]
 atlas=new(512,128)
 for row,kind in enumerate(['path','water','canopy']):
  for mask in range(16):atlas.alpha_composite(transition(bases[0],bases[row+1],mask,kind),(mask*32,row*32))
 for kind_i,kind in enumerate(['grass','path','water','canopy']):
  for i in range(4):atlas.alpha_composite(variant(bases[kind_i],kind,i),((kind_i*4+i)*32,96))
 atlas.save(OUT/'forest_terrain.png')
 deco=new(256,32)
 for i,tile in enumerate(decor()):deco.alpha_composite(tile,(i*32,0))
 deco.save(OUT/'forest_decor.png')
 floors=[floor(i) for i in range(4)]
 shadow=floors[0].copy()
 for y in range(8):
  for x in range(32):
   r,g,b,a=shadow.getpixel((x,y));k=.78+.026*y;shadow.putpixel((x,y),(int(r*k),int(g*k),int(b*k),a))
 mat=floors[1].copy();d=draw(mat);d.rectangle((3,5,28,27),fill=col('r0'));d.rectangle((5,7,26,25),fill=col('r1'));d.rectangle((7,9,24,23),outline=col('r3'))
 for x in range(9,24,3):d.line((x,11,x,21),fill=col('r2'))
 tiles=floors+[shadow,mat,new(),new()]+[wall(i) for i in range(7)]+[new()]
 tavern=new(256,64)
 for i,tile in enumerate(tiles):tavern.alpha_composite(tile,((i%8)*32,(i//8)*32))
 tavern.save(OUT/'tavern_tiles.png')

def validate():
 atlas=Image.open(OUT/'forest_terrain.png').convert('RGBA');assert atlas.size==(512,128)
 assert set(atlas.getchannel('A').get_flattened_data())=={255}
 def tile(x,y):return atlas.crop((x*32,y*32,x*32+32,y*32+32))
 # Every one of 16 horizontal/vertical neighbor pairs with matching shared
 # corner bits, for every transition family: 64 pairs/family/axis.
 checked=0
 for row in range(3):
  for a in range(16):
   for b in range(16):
    aa,bb=tile(a,row),tile(b,row)
    if (a>>1&1)==(b&1) and (a>>3&1)==(b>>2&1):
     assert [aa.getpixel((31,y)) for y in range(32)]==[bb.getpixel((0,y)) for y in range(32)],('horizontal',row,a,b)
     checked+=1
    if (a>>2&1)==(b&1) and (a>>3&1)==(b>>1&1):
     assert [aa.getpixel((x,31)) for x in range(32)]==[bb.getpixel((x,0)) for x in range(32)],('vertical',row,a,b)
     checked+=1
 for i in range(16):
  group=i//4;im=tile(i,3);ref=tile(group*4,3)
  for coords in [[(x,0) for x in range(32)],[(x,31) for x in range(32)],[(0,y) for y in range(32)],[(31,y) for y in range(32)]]:
   assert [im.getpixel(p) for p in coords]==[ref.getpixel(p) for p in coords]
 for name,size in [('forest_decor.png',(256,32)),('tavern_tiles.png',(256,64))]:
  im=Image.open(OUT/name).convert('RGBA');assert im.size==size;assert set(im.getchannel('A').get_flattened_data())<={0,255}
 tav=Image.open(OUT/'tavern_tiles.png').convert('RGBA')
 for i in range(4):
  for j in range(4):
   a=tav.crop((i*32,0,i*32+32,32));b=tav.crop((j*32,0,j*32+32,32))
   assert [a.getpixel((31,y)) for y in range(32)]==[b.getpixel((0,y)) for y in range(32)]
   assert [a.getpixel((x,31)) for x in range(32)]==[b.getpixel((x,0)) for x in range(32)]
 print(f'PASS: {checked} compatible forest-mask edge pairs; all variant boundaries; 16 floor pair seams; exact atlas dimensions and binary alpha')

if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--check-only',action='store_true');args=ap.parse_args()
 if not args.check_only:save_outputs()
 validate()
