"""Codex v2 original Copperfern player: native registered four-direction rig.

Source is this candidate's own image-assisted direction study, not Claude's candidate.
Runtime contract unchanged: 48x64, foot row60, rows down/left/right/up,
columns neutral / contact A / passing A / contact B / passing B.
Column2 doubles as a restrained breathing idle when not moving.
Native limbs are independently articulated; asymmetric satchel is not mirrored.
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/art/source/codex_v2/player_directions.png'
DEST=ROOT/'assets/art/characters/player.png'
PREVIEW=ROOT/'.godot/codex_v2_player'
FW,FH=48,64
# Small shared authored material ramps; no per-frame adaptive palettes.
RAMPS={
 'ink':['#241f25','#342b2b'],
 'hair':['#302321','#483027','#624133','#7b5540','#94674b'],
 'skin':['#875039','#a76640','#c48450','#dda468','#edbd83'],
 'teal':['#24443f','#355e53','#48776a','#669080','#85aa95'],
 'cream':['#9d947a','#c5b99a','#e3d8b8','#f0e5cb'],
 'russet':['#713b31','#8d4d38','#ac6548','#c88358','#dfa16f'],
 'pants':['#24252d','#35343d','#48444a','#5b5153'],
 'boots':['#342b27','#51392b','#72503a','#926847','#b18557'],
 'brass':['#9c6c35','#c69a54','#e5c078'],
}
COLORS=[tuple(bytes.fromhex(h[1:])) for r in RAMPS.values() for h in r]
C=lambda h: tuple(bytes.fromhex(h[1:]))+(255,)
INK=C('#241f25')


def palette_map(im):
    out=Image.new('RGBA',im.size)
    for y in range(im.height):
        for x in range(im.width):
            p=im.getpixel((x,y))
            if p[3]<160:continue
            rgb=min(COLORS,key=lambda c:sum((c[i]-p[i])**2 for i in range(3)))
            out.putpixel((x,y),rgb+(255,))
    return out


def native_bases():
    im=Image.open(SOURCE).convert('RGBA');result=[]
    for row in range(4):
        crop=im.crop((row*im.width//4,0,(row+1)*im.width//4,im.height))
        crop.putalpha(crop.getchannel('A').point(lambda p:255 if p>=160 else 0))
        crop=crop.crop(crop.getbbox())
        crop=crop.resize((round(crop.width*46/crop.height),46),Image.Resampling.NEAREST)
        frame=Image.new('RGBA',(FW,FH));frame.alpha_composite(crop,(24-crop.width//2,15))
        result.append(palette_map(frame))
    return result


def poly(im,points,fill,edge=INK):
    d=ImageDraw.Draw(im);d.polygon(points,fill=fill)
    if edge:d.line(points+[points[0]],fill=edge,width=1)


def leg(im,x,knee_dx,foot_dx,raise_by,far=False,profile=0):
    """Two-segment trouser leg plus boot; contact foot remains on row60."""
    ds=ImageDraw.Draw(im);shade=C('#24252d') if far else C('#35343d')
    mid=C('#35343d') if far else C('#48444a');bot=60-raise_by
    poly(im,[(x,48),(x+4,48),(x+4+knee_dx,53),(x+4+foot_dx,bot-5),(x+foot_dx,bot-5),(x+knee_dx,53)],shade)
    ds.line((x+1,49,x+1+knee_dx,53),fill=mid)
    ds.point((x+1+knee_dx,54),fill=C('#5b5153'))
    toe=-1 if profile<0 else 1 if profile>0 else 0
    poly(im,[(x+foot_dx,bot-5),(x+4+foot_dx,bot-5),(x+4+foot_dx+max(toe,0),bot-1),(x+3+foot_dx+max(toe,0),bot),(x+foot_dx+min(toe,0),bot),(x+foot_dx+min(toe,0),bot-2)],C('#51392b') if far else C('#72503a'))
    ds.line((x+1+foot_dx,bot-4,x+3+foot_dx,bot-4),fill=C('#926847'))
    ds.point((x+foot_dx+min(toe,0)+1,bot-1),fill=C('#b18557') if not far else C('#72503a'))


def arms(im,direction,phase):
    d=ImageDraw.Draw(im)
    # Separate shoulders/elbows/hands, counter-swing on front/back; body isn't simply shifted.
    swing=[0,-1,0,1,0][phase]
    if direction in (0,3):
        for x,dy,far in [(15,swing,False),(31,-swing,True)]:
            # Short sleeve, turned-up cuff, forearm/hand. Skin kept warm and readable.
            poly(im,[(x+1,34+dy),(x+2,35+dy),(x+3,39+dy),(x+2,41+dy),(x,40+dy),(x,36+dy)],C('#355e53') if far else C('#48776a'))
            d.line((x,39+dy,x+2,40+dy),fill=C('#e3d8b8'))
            poly(im,[(x,41+dy),(x+2,41+dy),(x+2,45+dy),(x+1,46+dy),(x-1,45+dy)],C('#a76640') if far else C('#c48450'))
            d.point((x,42+dy),fill=C('#dda468'))
    else:
        # Independently resolve profile near/far arms; visible satchel stays physical left.
        dx=[0,-2,0,2,0][phase]*(1 if direction==1 else -1)
        x=23+dx if direction==1 else 21+dx
        poly(im,[(x,34),(x+3,34),(x+4,39),(x+3,41),(x,41),(x-1,38)],C('#48776a'))
        d.line((x,39,x+3,39),fill=C('#e3d8b8'))
        poly(im,[(x,41),(x+3,41),(x+4,45),(x+2,47),(x,46)],C('#c48450'))
        d.line((x+1,42,x+1,45),fill=C('#dda468'))


def render(base,direction,phase):
    # Keep generated head/torso/apron as native-cleaned layers; author the moving limbs.
    frame=Image.new('RGBA',(FW,FH));body=base.copy();d=ImageDraw.Draw(body)
    d.rectangle((0,49,47,63),fill=(0,0,0,0))
    # Remove old arms (retain torso, apron and physical-left bag).
    if direction in (0,3):
        d.rectangle((0,34,17,47),fill=(0,0,0,0));d.rectangle((31,34,47,47),fill=(0,0,0,0))
    else:
        # Profile arm is repainted with a clean silhouette, not a horizontally mirrored frame.
        d.rectangle((21 if direction==2 else 23,34,27 if direction==2 else 28,47),fill=(0,0,0,0))
    if direction in (0,3):
        lifts={0:(0,0),1:(0,2),2:(0,0),3:(2,0),4:(0,0)}[phase]
        legs=[(19,0,0,lifts[0],direction==3),(25,0,0,lifts[1],direction==0)]
        for a in legs:leg(frame,*a)
    else:
        # Alternate contact/passing poses through knee/ankle articulation in screen x.
        swing={0:0,1:3,2:0,3:-3,4:0}[phase]
        left=direction==1;sgn=-1 if left else 1
        leg(frame,22,-swing//2,-swing,1 if phase in (1,3) else 0,True,sgn)
        leg(frame,23,swing//2,swing,0,False,sgn)
    bob=1 if phase in (2,4) else 0
    if bob:
        # Keep the head registered while the shoulder/torso compresses one pixel.
        frame.alpha_composite(body.crop((0,34,48,64)),(0,33))
        frame.alpha_composite(body.crop((0,0,48,34)),(0,0))
    else:
        frame.alpha_composite(body,(0,0))
    # Arms are redrawn per pose (counter-motion); torso breathing never moves feet.
    arms(frame,direction,phase)
    # Re-author the small asymmetric satchel and strap after the arms.
    draw=ImageDraw.Draw(frame)
    bx=29 if direction==0 else 15 if direction==3 else 20 if direction==1 else None
    if bx is not None:
        by=42-bob
        poly(frame,[(bx,by),(bx+5,by),(bx+5,by+6),(bx+4,by+7),(bx,by+6)],C('#72503a'))
        draw.rectangle((bx+1,by+1,bx+4,by+2),fill=C('#926847'))
        draw.point((bx+2,by+3),fill=C('#e5c078'))
        draw.line((bx+1,by-5,bx+1,by),fill=C('#51392b'))
    # Remove orphan native-conversion specks, keeping the connected character.
    remaining={(x,y) for y in range(64) for x in range(48) if frame.getpixel((x,y))[3]}
    components=[]
    while remaining:
        start=remaining.pop();part={start};todo=[start]
        while todo:
            x,y=todo.pop()
            for dx,dy in ((-1,-1),(0,-1),(1,-1),(-1,0),(1,0),(-1,1),(0,1),(1,1)):
                q=(x+dx,y+dy)
                if q in remaining:
                    remaining.remove(q);part.add(q);todo.append(q)
        components.append(part)
    if components:
        largest=max(components,key=len)
        for part in components:
            if part is not largest:
                for q in part:frame.putpixel(q,(0,0,0,0))
    return frame


def build():
    bases=native_bases();sheet=Image.new('RGBA',(240,256));frames=[]
    for row,b in enumerate(bases):
        rowframes=[]
        for phase in range(5):
            f=render(b,row,phase);sheet.alpha_composite(f,(phase*48,row*64));rowframes.append(f)
        frames.append(rowframes)
    DEST.parent.mkdir(parents=True,exist_ok=True);sheet.save(DEST)
    PREVIEW.mkdir(parents=True,exist_ok=True)
    sheet.resize((960,1024),Image.Resampling.NEAREST).save(PREVIEW/'player_sheet_x4.png')
    # Actual directional walk frames, enlarged without interpolation, not generated video.
    for row,name in enumerate(('down','left','right','up')):
        images=[]
        for phase in (1,2,3,4):
            canvas=Image.new('RGBA',(48,64),'#b8b79a');canvas.alpha_composite(frames[row][phase]);images.append(canvas.resize((288,384),Image.Resampling.NEAREST).convert('RGB'))
        images[0].save(PREVIEW/f'walk_{name}.gif',save_all=True,append_images=images[1:],duration=110,loop=0)
    # Palette/registration checks that fail on malformed output.
    assert sheet.size==(240,256)
    assert set(sheet.getchannel('A').get_flattened_data())=={0,255}
    for row,rowframes in enumerate(frames):
        assert len({f.tobytes() for f in rowframes})>=4,(row,'needs articulated poses')
        for f in rowframes:
            bb=f.getbbox();assert bb and bb[0]>0 and bb[2]<48 and bb[1]>0 and bb[3]==61,bb
    print('PASS: 20 registered frames; four unique walking poses per direction; foot baseline row60; binary alpha')
    print('Shared native colors:',len({p for p in sheet.get_flattened_data() if p[3]}))
    return sheet

if __name__=='__main__':build()
