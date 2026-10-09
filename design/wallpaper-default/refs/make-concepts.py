import sys, math, random
W,H=3840,2160
out=sys.argv[1]
def wrap(m,body,defs=''):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><!-- ModalityOS wallpaper concept. CC0-1.0. --><defs>{defs}<filter id="b1" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="220"/></filter><filter id="b2" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="60"/></filter><filter id="b3" x="-10%" y="-10%" width="120%" height="120%"><feGaussianBlur stdDeviation="8" edgeMode="duplicate"/></filter><filter id="grain"><feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" seed="4"/><feColorMatrix values="0 0 0 0 .5  0 0 0 0 .5  0 0 0 0 .5  0 0 0 .06 0"/></filter></defs>{body}<rect width="{W}" height="{H}" filter="url(#grain)" opacity=".5"/></svg>'

# B: Aurora — soft colour fields (mesh-gradient feel)
AUR={'light':('#eef1ff',[('#7aa8ff',900,700,1500,1000),('#c7a6ff',2600,500,1400,900),('#ffb3c7',3000,1700,1400,900),('#ffd2a8',1200,1900,1500,800),('#a8e1ff',300,300,900,700),('#9fc0ff',-200,1100,900,1100),('#d9b8ff',4000,1000,900,1200),('#ffc2b0',2000,2400,2000,500),('#c9d6ff',1900,-250,2200,500)]),
     'dark':('#070a1c',[('#1d3fb3',900,700,1500,1000),('#4b23a0',2700,500,1400,900),('#8a2b6a',3000,1750,1400,900),('#7a3a20',1100,1950,1400,750),('#0f5b8a',300,300,900,700),('#16307a',-200,1100,900,1100),('#3b1d80',4000,1000,900,1200),('#5a2440',2000,2400,2000,500),('#14205a',1900,-250,2200,500)])}
def aurora(m):
    bg,blobs=AUR[m]
    body=f'<rect width="{W}" height="{H}" fill="{blobs[0][0]}"/><g transform="translate({W/2} {H/2}) scale(1.35) translate({-W/2} {-H/2})">'+''.join(f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{c}" opacity=".9" filter="url(#b1)"/>' for c,x,y,rx,ry in blobs)+'</g>'
    return wrap(m,body)

# C: Dunes — layered abstract hills under a soft gradient sky
DUN={'light':(('#cfe0ff','#f6e6ff','#ffe9dc'),['#b9c9ff','#a59cf0','#c88bd6','#ef9fb4','#ffb898']),
     'dark':(('#07102e','#1a1140','#2c1030'),['#17306f','#2a2370','#4a2068','#6e2552','#8a3a3a'])}
def dunes(m):
    sky,hills=DUN[m]
    defs=f'<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{sky[0]}"/><stop offset=".6" stop-color="{sky[1]}"/><stop offset="1" stop-color="{sky[2]}"/></linearGradient>'
    defs+='<linearGradient id="hs" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".22"/><stop offset=".4" stop-color="#fff" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".18"/></linearGradient>'
    body=f'<rect width="{W}" height="{H}" fill="url(#sky)"/><ellipse cx="2700" cy="700" rx="700" ry="520" fill="{"#ffffff" if m=="light" else "#3a4fd0"}" opacity="{.7 if m=="light" else .35}" filter="url(#b1)"/>'
    for i,c in enumerate(hills):
        base=1380+i*170; amp=150-i*12; ph=i*1.3
        pts=[(x, base+amp*math.sin(x/700+ph)+60*math.sin(x/260+ph*2)) for x in range(-200,W+201,40)]
        d='M -200 '+str(H+50)+' '+' '.join(f'L {x:.0f} {y:.0f}' for x,y in pts)+f' L {W+200} {H+50} Z'
        body+=f'<path d="{d}" fill="{c}" filter="url(#b3)"/><path d="{d}" fill="url(#hs)" filter="url(#b3)"/>'
    return wrap(m,body,defs)

# D: Silk — large translucent overlapping petals/folds crossing the frame
SILK={'light':('#f1efff',['#6f9dff','#a98cff','#ff9fbf','#ffb98f']),
      'dark':('#080a1e',['#1f45c0','#5530b0','#a0306e','#b5553a'])}
def silk(m):
    bg,cs=SILK[m]
    defs=''.join(f'<linearGradient id="s{i}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{c}" stop-opacity=".95"/><stop offset="1" stop-color="{c}" stop-opacity=".25"/></linearGradient>' for i,c in enumerate(cs))
    shapes=[
      'M -300 2300 C 600 1400, 1400 1300, 2200 1700 S 3600 2500, 4200 1900 L 4200 2500 L -300 2500 Z',
      'M -300 1500 C 700 2200, 1700 2300, 2600 1600 S 3800 600, 4200 900 L 4200 2500 L -300 2500 Z',
      'M 2200 -300 C 2500 600, 3100 1100, 4200 1150 L 4200 -300 Z',
      'M 2900 -300 C 2800 500, 3300 900, 4200 700 L 4200 -300 Z']
    body=f'<rect width="{W}" height="{H}" fill="{bg}"/><ellipse cx="1300" cy="800" rx="1400" ry="800" fill="{cs[1]}" opacity=".25" filter="url(#b1)"/>'
    for i,d in enumerate(shapes):
        body+=f'<path d="{d}" fill="{cs[i%len(cs)]}" opacity=".35" filter="url(#b2)" transform="translate(0 40)"/>'
        body+=f'<path d="{d}" fill="url(#s{i})" style="mix-blend-mode:{"multiply" if m=="light" else "screen"}" filter="url(#b3)"/>'
    return wrap(m,body,defs)

for name,f in (('aurora',aurora),('dunes',dunes),('silk',silk)):
    for m in ('light','dark'):
        open(f'{out}/concept-{name}-{m}.svg','w').write(f(m))
