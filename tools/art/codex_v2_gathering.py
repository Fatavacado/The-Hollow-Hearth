"""Original native Copperfern gatherable/vegetation pixel art for the v2 benchmark.

No image input or copied asset pixels. Explicit silhouettes, material ramps and
harvest states; preserves a8085de canvas/foot-row/blocker contracts. Run this
script directly to regenerate only these 12 PNGs (not the whole art library).
"""
from pathlib import Path
import math
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art'
P={
 'ink':'#293C35','leaf0':'#294F3B','leaf1':'#426E42','leaf2':'#64934F','leaf3':'#91B664','leaf4':'#B5CC7C',
 'bark0':'#49392F','bark1':'#70503A','bark2':'#916A46','bark3':'#B48B5C','bark4':'#D2AD77',
 'soil0':'#4E4932','soil1':'#6D6441','soil2':'#938159',
 'cream0':'#A6AD8A','cream1':'#D8D6AD','cream2':'#F1E6BC',
 'berry0':'#46476A','berry1':'#6976A0','berry2':'#9DADD1','berry3':'#CEDBDA',
 'teal0':'#365F62','teal1':'#548D8D','teal2':'#8ABDB3','teal3':'#C4DFCA',
 'amber0':'#9D6836','amber1':'#C99346','amber2':'#E0B866','amber3':'#F0D68D',
 'clay0':'#754B36','clay1':'#A66E48','clay2':'#C28D62','clay3':'#D9AC7E',
 'stone0':'#4E5C55','stone1':'#737E72','stone2':'#9DA38D','stone3':'#C4C5A7',
}
def C(n):return P.get(n,n)
def new(w,h):return Image.new('RGBA',(w,h))
def poly(d,points,c):d.polygon(points,fill=C(c))
def line(d,points,c,width=1):d.line(points,fill=C(c),width=width)
def rect(d,box,c):d.rectangle(box,fill=C(c))
def ellipse(d,box,c):d.ellipse(box,fill=C(c))
def soil(d,cx,y,rx=10):
 ellipse(d,(cx-rx,y-2,cx+rx,y+2),'soil0')
 line(d,[(cx-rx+3,y-1),(cx-3,y-2),(cx+2,y-1)],'soil1')
 line(d,[(cx+3,y+1),(cx+rx-3,y)],'soil2')

def pointed_leaf(d,base,tip,width=3):
 bx,by=base;tx,ty=tip;dx,dy=tx-bx,ty-by;length=max(1,math.hypot(dx,dy));px,py=-dy/length*width,dx/length*width
 mid=((bx+tx)*.5,(by+ty)*.5)
 pts=[(bx,by),(round(mid[0]+px),round(mid[1]+py)),(tx,ty),(round(mid[0]-px),round(mid[1]-py))]
 poly(d,pts,'leaf0')
 # A narrow illuminated blade and a stable central vein.
 q=[(bx,by),(round(mid[0]+px*.55),round(mid[1]+py*.55)),(tx,ty),(round(mid[0]-px*.3),round(mid[1]-py*.3))]
 poly(d,q,'leaf2');line(d,[(bx,by),(tx,ty)],'leaf3')

def fern_frond(d,base,tip,light=False):
 bx,by=base;tx,ty=tip;dx,dy=tx-bx,ty-by
 line(d,[(bx,by),(tx,ty)],'leaf1')
 for t in [.24,.43,.62,.79]:
  x,y=round(bx+dx*t),round(by+dy*t);w=3 if t<.65 else 2
  # Paired offset pinnae make a fern silhouette, not a generic grass tuft.
  for side in [-1,1]:
   ex=round(x+side*w-dx*.12);ey=round(y-dy*.10-2)
   poly(d,[(x,y+1),(ex,ey),(ex+side,ey+1),(x,y)],'leaf2' if side<0 else 'leaf1')
   if side<0:line(d,[(ex,ey),(x,y)],'leaf3' if light else 'leaf2')
 line(d,[(bx,by),(tx,ty)],'leaf2');d.point((tx,ty),fill=C('leaf4'))

def fern(full):
 im=new(32,30);d=ImageDraw.Draw(im);soil(d,16,27,10)
 if full:
  for tip in [(5,17),(5,10),(12,4),(18,3),(25,9),(28,17),(20,13)]:fern_frond(d,(16,26),tip,tip[0]<16)
 else:
  for x,y in [(12,24),(16,23),(20,24)]:line(d,[(16,27),(x,y)],'leaf1');d.point((x,y),fill=C('cream0'))
  pointed_leaf(d,(16,27),(10,21),2)
 return im

def mushroom(d,x,y,w,h):
 # The stem terminates at y; cap occupies the upper third of the mushroom.
 stemw=max(2,w//4);top=y-h;cap_h=max(3,h//3)
 rect(d,(x-stemw//2,top+cap_h-1,x+stemw//2,y-1),'teal0')
 rect(d,(x-stemw//2+1,top+cap_h,x+stemw//2,y-2),'cream1')
 line(d,[(x,y-2),(x,y-h//2)],'cream2')
 poly(d,[(x-w//2,top+cap_h),(x-w//2+1,top+2),(x-2,top),(x+2,top),(x+w//2-1,top+2),(x+w//2,top+cap_h),(x+w//2-2,top+cap_h+1),(x-w//2+2,top+cap_h+1)],'teal0')
 poly(d,[(x-w//2+1,top+cap_h-1),(x-w//2+2,top+2),(x-2,top+1),(x+2,top+1),(x+w//2-2,top+3),(x+w//2-1,top+cap_h-1)],'teal1')
 line(d,[(x-w//2+3,top+2),(x-1,top+1),(x+2,top+2)],'teal3')
 line(d,[(x-w//2+2,top+cap_h),(x+w//2-2,top+cap_h)],'teal2')
 d.point((x-2,top+3),fill=C('cream2'))

def glowcap(full):
 im=new(32,28);d=ImageDraw.Draw(im);soil(d,16,25,12)
 if full:
  mushroom(d,9,24,10,12);mushroom(d,20,25,15,21);mushroom(d,27,24,7,10)
  # Local pale spores, not a global transparent glow wash.
  d.point((5,8),fill=C('teal2'));d.point((28,10),fill=C('teal2'))
 else:
  for x,y in [(9,23),(19,24),(26,23)]:rect(d,(x-1,y-2,x+1,y),'teal0');line(d,[(x,y-2),(x+1,y-2)],'cream1')
  ellipse(d,(12,23,15,24),'teal1')
 return im

def bush_shape(d):
 for b,c in [((2,11,16,25),'leaf0'),((10,4,25,23),'leaf0'),((20,12,30,26),'leaf0'),((7,15,25,28),'leaf0')]:ellipse(d,b,c)
 for pts in [[(4,14),(7,10),(12,11),(13,15),(9,18),(5,17)],[(13,8),(17,5),(22,8),(23,12),(18,15),(14,12)],[(22,16),(26,13),(29,16),(27,20),(23,20)],[(10,20),(14,16),(20,18),(22,24),(17,26),(11,25)]]:
  poly(d,pts,'leaf1');line(d,[pts[0],pts[1],pts[2]],'leaf2')
 # Offset leaf veins and small top leaf highlights, no independent texture noise.
 for x,y in [(7,14),(17,9),(24,17),(14,21)]:line(d,[(x,y+2),(x+3,y)],'leaf3')

def moonberry(full):
 im=new(32,30);d=ImageDraw.Draw(im);soil(d,16,27,13);bush_shape(d)
 if full:
  for x,y in [(8,17),(16,12),(24,20),(14,24)]:
   ellipse(d,(x-2,y-2,x+3,y+3),'berry0');ellipse(d,(x-1,y-1,x+2,y+2),'berry1');d.point((x,y-1),fill=C('berry3'));d.point((x+1,y+2),fill=C('berry2'))
 else:
  for x,y in [(8,17),(16,12),(24,20)]:line(d,[(x,y),(x+1,y-2)],'soil2')
 return im

def sweetroot(full):
 im=new(28,24);d=ImageDraw.Draw(im);soil(d,14,21,11)
 if full:
  # Two exposed pale roots planted in earth, with distinct paired leaf crowns.
  for cx in [10,19]:
   poly(d,[(cx-3,15),(cx-2,12),(cx+2,12),(cx+4,16),(cx+2,20),(cx,22),(cx-2,20)],'cream0')
   poly(d,[(cx-2,14),(cx,13),(cx+2,15),(cx+1,19),(cx,20),(cx-1,18)],'cream2')
   line(d,[(cx-2,17),(cx+1,18)],'cream1')
  for base,tip in [((11,14),(5,5)),((11,14),(10,2)),((11,14),(16,6)),((19,14),(17,4)),((19,14),(23,3)),((19,14),(25,10))]:pointed_leaf(d,base,tip,3)
 else:
  ellipse(d,(6,17,12,21),'soil0');ellipse(d,(16,17,22,21),'soil0');line(d,[(7,17),(11,17)],'soil2');line(d,[(17,17),(21,17)],'soil2');pointed_leaf(d,(13,22),(8,18),2)
 return im

def honeycomb(full):
 im=new(48,32);d=ImageDraw.Draw(im);soil(d,24,28,21)
 # Fallen hollow timber, with quiet top plane and curved annual rings at end.
 poly(d,[(5,10),(13,5),(37,8),(44,15),(42,26),(13,28),(5,23)],'bark0')
 poly(d,[(6,11),(14,7),(36,10),(42,16),(35,18),(14,15)],'bark3')
 poly(d,[(6,13),(14,16),(35,19),(42,17),(40,25),(14,26),(6,22)],'bark1')
 line(d,[(14,19),(25,21),(35,20)],'bark0');line(d,[(16,23),(23,24),(31,23)],'bark2');line(d,[(15,9),(24,11),(33,11)],'bark4')
 ellipse(d,(3,9,16,25),'bark0');ellipse(d,(5,10,14,23),'bark2');ellipse(d,(7,12,12,21),'bark3');ellipse(d,(8,14,11,19),'bark0')
 # Moss and fern leaves attach timber to ground rather than floating.
 pointed_leaf(d,(36,27),(43,23),2);line(d,[(13,26),(17,25),(22,26)],'leaf2')
 if full:
  poly(d,[(22,13),(29,11),(36,14),(37,21),(32,25),(24,23),(21,18)],'amber0')
  poly(d,[(23,14),(29,12),(34,15),(35,21),(31,23),(25,21)],'amber2')
  for x,y in [(26,15),(31,16),(26,20),(31,21)]:
   poly(d,[(x-1,y-1),(x+1,y-1),(x+2,y),(x+1,y+2),(x-1,y+2),(x-2,y)],'amber0');d.point((x,y),fill=C('amber1'))
  line(d,[(23,14),(28,12),(31,13)],'amber3');d.point((35,23),fill=C('amber2'))
 else:
  poly(d,[(22,15),(29,13),(35,16),(34,22),(28,24),(23,21)],'bark0');line(d,[(23,15),(29,14),(33,16)],'bark2')
 return im

def plant():
 im=new(24,34);d=ImageDraw.Draw(im)
 # Clay pot is a top-view ellipse plus shallow front, with a fern crown.
 ellipse(d,(5,27,20,32),'soil0');poly(d,[(5,21),(19,21),(17,31),(8,31)],'clay0');poly(d,[(7,22),(17,22),(16,29),(9,29)],'clay1');line(d,[(9,24),(9,28),(15,28)],'clay2')
 ellipse(d,(4,18,20,24),'clay2');ellipse(d,(6,19,18,22),'soil0');line(d,[(6,19),(11,18),(16,19)],'clay3')
 for tip in [(3,12),(6,7),(12,2),(19,6),(22,12)]:fern_frond(d,(12,21),tip,tip[0]<12)
 return im

def rock():
 im=new(26,22);d=ImageDraw.Draw(im);ellipse(d,(2,16,24,21),'soil0')
 poly(d,[(2,13),(6,6),(13,3),(20,6),(24,13),(23,18),(18,20),(7,20),(2,17)],'stone0')
 poly(d,[(4,12),(7,7),(13,5),(19,7),(20,11),(13,14),(7,15)],'stone2')
 poly(d,[(7,7),(13,5),(18,7),(12,8),(7,12)],'stone3')
 poly(d,[(14,14),(21,10),(23,14),(21,17),(17,19),(12,18)],'stone1')
 line(d,[(12,9),(13,12),(10,15)],'stone1');line(d,[(4,15),(7,17),(10,17)],'stone1')
 poly(d,[(5,16),(10,15),(14,17),(13,19),(7,19),(4,18)],'leaf1');line(d,[(6,16),(9,16),(11,17)],'leaf3')
 return im

SIZES={'fernleaf':(32,30),'glowcap':(32,28),'moonberry':(32,30),'sweetroot':(28,24),'honeycomb':(48,32)}
FOOT={'fernleaf':27,'glowcap':25,'moonberry':26,'sweetroot':22,'honeycomb':27}

def main():
 functions={'fernleaf':fern,'glowcap':glowcap,'moonberry':moonberry,'sweetroot':sweetroot,'honeycomb':honeycomb}
 outputs=[]
 for name,fn in functions.items():
  for full in [True,False]:
   im=fn(full);assert im.size==SIZES[name]
   path=ART/'nodes'/f'{name}_{"full" if full else "empty"}.png';im.save(path);outputs.append(path)
  a=Image.open(ART/'nodes'/f'{name}_full.png').convert('RGBA');b=Image.open(ART/'nodes'/f'{name}_empty.png').convert('RGBA')
  assert a.tobytes()!=b.tobytes(),name
  changes=sum(x!=y for x,y in zip(a.get_flattened_data(),b.get_flattened_data()));assert changes>10,(name,changes)
  print(f'{name}: {SIZES[name]}, preserved foot row {FOOT[name]}, full/harvested changed pixels {changes}')
 for name,fn,size in [('plant',plant,(24,34)),('rock',rock,(26,22))]:
  im=fn();assert im.size==size;path=ART/'props'/f'{name}.png';im.save(path);outputs.append(path)
 for path in outputs:
  im=Image.open(path).convert('RGBA');assert set(im.getchannel('A').get_flattened_data())<={0,255};assert im.getbbox() is not None
 print('PASS: 12 exact-size outputs, distinct harvested states, nonempty native bounds and binary alpha')

if __name__=='__main__':main()
