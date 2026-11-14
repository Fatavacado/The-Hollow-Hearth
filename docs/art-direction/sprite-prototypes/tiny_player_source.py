from PIL import Image
from pathlib import Path
p=Path('/workspace/The-Hollow-Hearth/docs/art-direction/sprite-prototypes')
# Original native pixel construction, using Copperfern material anchors.
rows=[
'      hhhh      ',
'    hhhHHhhh    ',
'   hhHHHHHhhh   ',
'  hhHHhHHHHhhh  ',
'  hHHhhsssHhh   ',
' hhHHhsssssshh  ',
'  hHhssssssss   ',
'   hssississs   ',
'   SssssssssS   ',
'    SssmsssS    ',
'     SssssS     ',
'    tTccTTt     ',
'   tTTTccTTTt   ',
'  tTTTTccTTTTt  ',
'  tTTTTccTTTTt  ',
'  cCTTTccTTTCc  ',
'  sSrrrrrrrrSs  ',
'  sSrrRRrrRRSs  ',
'  sSrrRRrrbbSs  ',
'   rRRRRRRbBb   ',
'   rRRRRRRbGb   ',
'   rRRRRRRbbb   ',
'   rRRrRRRRr    ',
'    iPiiiPi     ',
'    iPi iPi     ',
'    iPi iPi     ',
'    bBb bBb     ',
'   bBBBbBBBb    ',
'   bBbb bBbb    ',
'   bbbb bbbb    ',
]
pal={'h':'#241F25','H':'#48302C','s':'#BF8250','S':'#915737','i':'#293B45','m':'#8B4931','t':'#2D514D','T':'#4C7D6D','c':'#A8B8A0','C':'#728E7E','r':'#803F35','R':'#AE6549','P':'#42454C','b':'#42302B','B':'#81543B','G':'#D3A158'}
im=Image.new('RGBA',(16,30))
for y,row in enumerate(rows):
 assert len(row)<=16,(y,len(row))
 for x,ch in enumerate(row):
  if ch!=' ':im.putpixel((x,y),tuple(bytes.fromhex(pal[ch][1:]))+(255,))
im.save(p/'copperfern_player_tiny_16x30_v001.png')
frame=Image.new('RGBA',(64,64));frame.paste(im,(24,18));frame.save(p/'copperfern_player_tiny_idle_south_64x64_v001.png')
# 12x review with a quiet solid background for dark outlines.
preview=Image.new('RGBA',im.size,'#F1DBB1');preview.alpha_composite(im);preview.resize((192,360),Image.Resampling.NEAREST).save(p/'copperfern_player_tiny_12x_preview.png')
print('Original tiny sprite:',im.size,'colors',len(im.getcolors()),'bounds',im.getbbox())
