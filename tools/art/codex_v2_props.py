"""Convert original generated source studies to the frozen slice's native prop contracts.

No scene coordinates, foot rows, blockers or atlas topology are changed. Source crops are
explicit because the generator's layout is not a production atlas. Cut alpha to binary,
remove hidden RGB, rebuild material palettes without dithering, place at original feet.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import argparse, random
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/art/source/codex_v2'
OUT=ROOT/'assets/art/props'
# name: source, source crop, frozen canvas, ground row, opaque color budget
SPECS={
 'oak_tree_a':('woodland',(20,0,505,490),(64,84),76,36),
 'oak_tree_b':('woodland',(510,0,1045,490),(64,84),76,36),
 'pine_tree':('woodland',(1080,0,1536,490),(48,92),86,32),
 'bush':('woodland',(0,700,450,1024),(32,30),26,24),
 'stump':('woodland',(450,700,880,1024),(30,24),20,24),
 'tavern_exterior':('woodland',(884,505,1536,1024),(224,200),187,64),
 'table':('tavern',(55,15,575,294),(52,44),39,30),
 'stool':('tavern',(680,30,950,295),(22,22),18,20),
 'barrel':('tavern',(1100,0,1430,294),(28,36),32,24),
 'counter':('tavern',(0,300,605,560),(160,56),55,48),
 'pantry_chest':('tavern',(670,300,960,570),(36,32),29,24),
 'shelf':('tavern',(1025,290,1536,602),(64,44),43,32),
 'hearth':('tavern',(40,565,570,1024),(96,128),127,48),
 'window':('tavern',(585,645,1040,1024),(52,44),43,32),
}

def build_prop(name,spec):
 source,crop,size,foot,budget=spec
 im=Image.open(SOURCE/(('woodland_props_source' if source=='woodland' else 'tavern_props_source')+'.png')).convert('RGBA').crop(crop)
 alpha=im.getchannel('A').point(lambda x:255 if x>=160 else 0)
 im.putalpha(alpha)
 bbox=im.getbbox()
 assert bbox is not None,name
 im=im.crop(bbox)
 # Fill native target without antialiasing. A static prop's foot matches source scene origin.
 maxw,maxh=size[0]-2,foot+1
 if name in ('oak_tree_a','oak_tree_b','pine_tree','table'):
  # Fill each frozen native silhouette contract rather than leaving large source-sheet
  # padding: tree height and table tops must agree with the 46px player.
  im=im.resize((maxw,maxh),Image.Resampling.NEAREST)
 elif name=='hearth':
  # Tall flue compensates source study proportions; actual cooking overlay remains unchanged.
  im=im.resize((92,127),Image.Resampling.NEAREST)
 elif name=='tavern_exterior':
  im=im.resize((222,188),Image.Resampling.NEAREST)
 elif name=='counter':im=im.resize((158,54),Image.Resampling.NEAREST)
 else:
  im.thumbnail((maxw,maxh),Image.Resampling.NEAREST)
 a=im.getchannel('A')
 # Opaque material palette, then restore exact binary transparency.
 rgb=im.convert('RGB').quantize(colors=budget,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(a)
 result=Image.new('RGBA',size)
 result.alpha_composite(rgb,((size[0]-rgb.width)//2,foot+1-rgb.height))
 if name=='hearth':
  # Preserve the baseline's live Fire/Cauldron overlay sockets. Remove the source
  # study's baked stove/kettle so there is one animated cooking fire, not two.
  d=ImageDraw.Draw(result)
  d.rectangle((20,68,76,126),fill='#C5AF86')
  d.rounded_rectangle((24,71,72,125),radius=15,fill='#76604A')
  d.rounded_rectangle((28,76,68,124),radius=12,fill='#302D29')
  d.line((23,123,73,123),fill='#E2CDA6',width=3)
  d.line((21,70,75,70),fill='#E2CDA6',width=2)
  for x,y in [(22,79),(72,81),(23,99),(72,103)]:
   d.rectangle((x,y,x+3,y+6),fill='#AD9877')
 if name=='tavern_exterior':
  # Source door was too small for the slice's 46px actor. Rebuild the doorway at native
  # 32x56; roof/overall footprint stay inside the baseline 224x200 canvas.
  d=ImageDraw.Draw(result);x0,y0=93,125
  d.rounded_rectangle((x0-3,y0-4,x0+35,y0+56),radius=13,fill='#493C32')
  d.rounded_rectangle((x0,y0-1,x0+32,y0+55),radius=11,fill='#A17A4D')
  for x in [99,106,113,120]:d.line((x,135,x,178),fill='#785737')
  d.line((95,176,124,176),fill='#C09B68')
  for y in [139,164]:
   d.rectangle((96,y,123,y+2),fill='#675039');d.point((98,y+1),fill='#C1A274');d.point((121,y+1),fill='#C1A274')
  d.rounded_rectangle((101,128,119,143),radius=6,fill='#4A3F33')
  d.rounded_rectangle((103,130,117,141),radius=5,fill='#D5B36F')
  d.line((110,129,110,142),fill='#796044');d.line((102,136,118,136),fill='#796044')
  d.rectangle((116,151,118,155),fill='#D8B66D')
  d.rectangle((90,182,130,187),fill='#BAAB8B');d.line((91,183,129,183),fill='#E0D1AD')
 # Ensure invisible RGB is zero; no fringe from the generative matte survives.
 pixels=list(result.get_flattened_data());result.putdata([c if c[3] else (0,0,0,0) for c in pixels])
 result.save(OUT/(name+'.png'))
 return result

def add_small_props():
 # Original native supplementary pieces; no asset-pack art or old placeholder pixels.
 for name,size in [('crate',(30,30)),('plant',(24,34))]:
  if name=='plant':continue # gathering artist owns this
  im=Image.new('RGBA',size);d=ImageDraw.Draw(im)
  d.polygon([(2,4),(25,1),(28,24),(4,28)],fill='#3B382F');d.polygon([(4,6),(24,4),(25,24),(5,25)],fill='#9D7446')
  for y in [9,15,21]:d.line((5,y,24,y-2),fill='#735439')
  d.line((5,7,23,23),fill='#C19B61',width=3);d.line((22,5,7,24),fill='#BB9259',width=2)
  for x,y in [(6,7),(23,5),(7,24),(23,23)]:d.point((x,y),fill='#403B32')
  im.save(OUT/(name+'.png'))
 # Match rug to Copperfern cloth, keep flat quiet center beneath active guests.
 im=Image.new('RGBA',(160,96));d=ImageDraw.Draw(im)
 d.rectangle((2,1,157,94),fill='#654337');d.rectangle((5,4,154,91),fill='#B36F50');d.rectangle((8,7,151,88),outline='#D5B07A',width=2);d.rectangle((13,12,146,83),fill='#8C5741')
 for x in range(18,146,16):
  d.line((x,10,x+3,10),fill='#EDD1A0');d.line((x,86,x+3,86),fill='#EDD1A0')
 for y in range(19,83,16):
  d.polygon([(9,y),(12,y+3),(9,y+6),(6,y+3)],fill='#D5B07A');d.polygon([(150,y),(153,y+3),(150,y+6),(147,y+3)],fill='#D5B07A')
 im.save(OUT/'rug.png')


def check():
 for name,spec in SPECS.items():
  im=Image.open(OUT/(name+'.png')).convert('RGBA');assert im.size==spec[2],name
  assert set(im.getchannel('A').get_flattened_data()) <= {0,255},name
  assert im.getbbox() and im.getbbox()[3] == spec[3]+1,(name,im.getbbox(),spec[3])
 print('PASS:14 hero props frozen dimensions, exact ground rows, binary alpha')

if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--check-only',action='store_true');args=parser.parse_args()
 if not args.check_only:
  for name,spec in SPECS.items():build_prop(name,spec)
  add_small_props()
 check()
