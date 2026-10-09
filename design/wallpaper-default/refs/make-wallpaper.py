import sys
W,H=3840,2160
P={
 'light':dict(bg=('#dfe8ff','#ece6ff','#fff0e8'),glow='#ffffff',glowop=.85,
   hues=['#5f97ff','#8a86ff','#b48cff','#f39bc0','#ffb08f','#ffc9a8'],hi='#ffffff',hiop=.55,sh='#2a1a6b',shop=.22,edge='#ffffff',edgeop=.6),
 'dark':dict(bg=('#070d24','#120c30','#1d0a22'),glow='#2f4fd0',glowop=.55,
   hues=['#1a3fb0','#3430a0','#5a2896','#86306a','#8e3c32','#9a4e36'],hi='#c9d6ff',hiop=.14,sh='#000000',shop=.45,edge='#c9d6ff',edgeop=.3),
}
# bands sweep from lower-left up to the right; (yL, yR, thickness, lift)
BANDS=[(1500,900,380,0),(1700,1100,340,0),(1900,1320,320,0),(2100,1560,300,0),(2320,1820,300,0),(2540,2080,420,0)]
def band(yL,yR,t,lift,i):
    x0,x1=-500,W+500
    c1=(1300,yL+620+i*40); c2=(2500,yR-760+i*30)
    top=f"M{x0} {yL} C {c1[0]} {c1[1]:.0f}, {c2[0]} {c2[1]:.0f}, {x1} {yR}"
    bot=f"L{x1} {yR+t} C {c2[0]} {c2[1]+t*0.7:.0f}, {c1[0]} {c1[1]+t*1.3:.0f}, {x0} {yL+t} Z"
    return top+" "+bot, top
def svg(m):
    c=P[m]; h=c['hues']
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
         f'<!-- ModalityOS default wallpaper, {m}. CC0-1.0. -->','<defs>',
         f'<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{c["bg"][0]}"/><stop offset=".55" stop-color="{c["bg"][1]}"/><stop offset="1" stop-color="{c["bg"][2]}"/></linearGradient>',
         f'<radialGradient id="glow" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="{c["glow"]}" stop-opacity="{c["glowop"]}"/><stop offset="1" stop-color="{c["glow"]}" stop-opacity="0"/></radialGradient>',
         '<filter id="soft" x="-5%" y="-5%" width="110%" height="110%"><feGaussianBlur stdDeviation="6" edgeMode="duplicate"/></filter>',
         '<filter id="haze" x="-40%" y="-40%" width="180%" height="180%"><feGaussianBlur stdDeviation="120"/></filter>',
         '<filter id="drop" x="-10%" y="-10%" width="120%" height="140%"><feGaussianBlur stdDeviation="40"/></filter>',
         '<filter id="line" x="-5%" y="-5%" width="110%" height="110%"><feGaussianBlur stdDeviation="3"/></filter>']
    for i in range(len(BANDS)):
        a,b=h[i],h[min(i+1,len(h)-1)]
        out.append(f'<linearGradient id="f{i}" gradientUnits="userSpaceOnUse" x1="0" y1="{H}" x2="{W}" y2="0"><stop offset="0" stop-color="{a}"/><stop offset="1" stop-color="{b}"/></linearGradient>')
    out.append(f'<linearGradient id="shade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c["hi"]}" stop-opacity="{c["hiop"]}"/><stop offset=".35" stop-color="{c["hi"]}" stop-opacity="0"/><stop offset=".7" stop-color="{c["sh"]}" stop-opacity="0"/><stop offset="1" stop-color="{c["sh"]}" stop-opacity="{c["shop"]}"/></linearGradient>')
    out.append('</defs>')
    out.append(f'<rect width="{W}" height="{H}" fill="url(#bg)"/>')
    out.append(f'<ellipse cx="1250" cy="760" rx="1700" ry="900" fill="url(#glow)" filter="url(#haze)"/>')
    out.append(f'<ellipse cx="3300" cy="420" rx="900" ry="520" fill="{h[2]}" opacity=".35" filter="url(#haze)"/>')
    for i,(yL,yR,t,lift) in enumerate(BANDS):
        d,top=band(yL,yR,t,lift,i)
        out.append(f'<path d="{d}" fill="{c["sh"]}" opacity="{c["shop"]*0.9:.2f}" filter="url(#drop)" transform="translate(0 -40)"/>')
        out.append(f'<path d="{d}" fill="url(#f{i})" filter="url(#soft)"/>')
        out.append(f'<path d="{d}" fill="url(#shade)" filter="url(#soft)"/>')
        out.append(f'<path d="{top}" fill="none" stroke="{c["edge"]}" stroke-opacity="{c["edgeop"]}" stroke-width="{max(2,6-i)}" filter="url(#line)"/>')
    out.append('</svg>')
    return '\n'.join(out)
for m in P: open(f'{sys.argv[1]}/wallpaper-{m}.svg','w').write(svg(m))
