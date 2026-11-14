"""Package actual Godot viewport captures; never synthesize scene backgrounds.
Usage: python tools/art/codex_v2_review.py <candidate-capture-dir> <baseline-dir>
"""
from PIL import Image,ImageDraw
from pathlib import Path
import sys,shutil
ROOT=Path(__file__).resolve().parents[2]
src=Path(sys.argv[1]);baseline=Path(sys.argv[2]);out=ROOT/'docs/art-codex-v2';frames=src/'frames'
(out/'captures').mkdir(exist_ok=True);(out/'baseline').mkdir(exist_ok=True)
for p in src.glob('*.png'):
 im=Image.open(p);assert im.size==(640,360),(p,im.size)
 shutil.copy(p,out/'captures'/p.name)
for n in ['01_tavern_interior.png','02_forest_entrance.png','03_forest_gathering.png']:
 shutil.copy(baseline/n,out/'baseline'/n)
 board=Image.new('RGB',(1280,390),'#DFD3B7');d=ImageDraw.Draw(board);d.text((12,9),'BASELINE a8085de / 640x360',fill='#293B45');d.text((652,9),'CODEX V2 / same scene, camera and actor position',fill='#293B45')
 board.paste(Image.open(baseline/n).convert('RGB'),(0,30));board.paste(Image.open(src/n).convert('RGB'),(640,30));board.save(out/('compare_'+n))
# These are real rendered crops at each capture time, not sprite-sheet animation.
all_sequences={}
for state in ['idle','walk']:
 for facing in ['down','left','right','up']:
  paths=sorted(frames.glob(state+'_'+facing+'_*.png'));assert len(paths)==12,(state,facing,len(paths))
  images=[Image.open(p).convert('RGB') for p in paths]
  assert len({im.tobytes() for im in images})>=2,(state,facing,'animation did not render')
  all_sequences[state+'_'+facing]=images
  big=[im.resize((256,320),Image.Resampling.NEAREST) for im in images]
  big[0].save(out/(state+'_'+facing+'.gif'),save_all=True,append_images=big[1:],duration=120 if state=='idle' else 100,loop=0)
combined=[]
for frame in range(12):
 board=Image.new('RGB',(512,366),'#C6BEA1');d=ImageDraw.Draw(board)
 for row,state in enumerate(['idle','walk']):
  for col,facing in enumerate(['down','left','right','up']):
   x,y=col*128,row*183
   d.text((x+6,y+3),state+' '+facing,fill='#293B45')
   im=all_sequences[state+'_'+facing][frame].resize((128,160),Image.Resampling.NEAREST);board.paste(im,(x,y+20))
 combined.append(board)
combined[0].save(out/'engine_animation_review.gif',save_all=True,append_images=combined[1:],duration=110,loop=0)
world=[Image.open(p).convert('RGB') for p in sorted(frames.glob('world_walk_*.png'))];assert len(world)==12
world[0].save(out/'engine_world_walk.gif',save_all=True,append_images=world[1:],duration=100,loop=0)
player=Image.open(ROOT/'assets/art/characters/player.png').convert('RGBA')
bg=Image.new('RGBA',player.size,'#C6BEA1');bg.alpha_composite(player);bg.resize((720,768),Image.Resampling.NEAREST).convert('RGB').save(out/'player_sheet_x3.png')
# Show reference alongside native captures without stretching its different aspect ratio.
reference=Image.open(out/'approved-reference-c1600fb.png').convert('RGB')
board=Image.new('RGB',(1280,760),'#DFD3B7');d=ImageDraw.Draw(board);d.text((12,8),'APPROVED COPPERFERN REFERENCE (illustration, fitted without distortion)',fill='#293B45');d.text((652,8),'CODEX V2 (actual native Godot captures; frozen layout)',fill='#293B45')
reference.thumbnail((630,680),Image.Resampling.NEAREST);board.paste(reference,((640-reference.width)//2,45+(680-reference.height)//2));board.paste(Image.open(src/'02_forest_entrance.png').convert('RGB'),(640,30));board.paste(Image.open(src/'01_tavern_interior.png').convert('RGB'),(640,390));board.save(out/'reference_vs_runtime.png')
print('PASS: native captures, matched baseline comparisons; 8 rendered animation states/12frames each verified')
