"""Build concise designed course PDFs from JSON, with strict overflow checks.

Requires reportlab. Student computers need R only; this tool is for maintainers.
Usage: python build_pdfs.py input.json [other.json ...] --out pdf-folder
"""
import argparse, json, math, re, textwrap, os
from io import BytesIO
from functools import lru_cache
from copy import deepcopy
from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph, Table, TableStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.pagesizes import A4

NAVY=colors.HexColor('#2B3180'); TEAL=colors.HexColor('#4E73FF')
DARK=colors.HexColor('#07152F'); ORANGE=colors.HexColor('#FF9A3C')
INK=colors.HexColor('#1A1F4D'); MUTED=colors.HexColor('#666270')
PAPER=colors.white; PALE=colors.HexColor('#F3F5FC'); LINE=colors.HexColor('#E6E4EE')
ASSETS=Path(__file__).resolve().parent/'assets'/'v3'


def fonts():
    root=Path(__file__).resolve().parent/'fonts'
    for name,file in {'Body':'Inter-400.ttf','Bold':'Inter-700.ttf',
                      'Heading':'PlusJakartaSans-800.ttf'}.items():
        pdfmetrics.registerFont(TTFont(name,str(root/file)))
    pdfmetrics.registerFontFamily('Body',normal='Body',bold='Bold',italic='Body',boldItalic='Bold')
    mono=Path(os.environ.get('COURSE_MONO_FONT','/System/Library/Fonts/Supplemental/Courier New.ttf'))
    if mono.exists():pdfmetrics.registerFont(TTFont('Mono',str(mono)));monofont='Mono'
    else:monofont='Courier'
    return 'Body','Bold',monofont,'Heading'

BODY,BOLD,MONO,HEAD=fonts()

def asset(path):
    p=Path(path)
    return p if p.is_absolute() else Path(__file__).resolve().parent.parent/p

def draw_page_header(c,doc,p,i,n,W,H,m):
    slide=doc.get('landscape',False)
    c.setFillColor(PAPER);c.rect(0,0,W,H,fill=1,stroke=0)
    c.saveState();c.setFillColor(PALE)
    c.circle(W+28,H+30,95,fill=1,stroke=0)
    c.setStrokeColor(colors.HexColor('#E7ECFF'));c.setLineWidth(12)
    c.circle(W+28,H+30,76,fill=0,stroke=1);c.restoreState()
    c.drawImage(str(ASSETS/'leaders-logo-blue.png'),m,H-47,width=83,height=29,preserveAspectRatio=True,anchor='sw',mask='auto')
    c.setFont(BOLD,8 if not slide else 10);c.setFillColor(NAVY)
    c.drawRightString(W-m-40,H-34,'MASTER  /  À VOTRE RYTHME')
    c.setFillColor(colors.white);c.circle(W-m-15,H-31,17,fill=1,stroke=0)
    c.drawImage(str(ASSETS/'Rlogo.png'),W-m-28,H-42,width=27,height=21,preserveAspectRatio=True,anchor='c',mask='auto')
    y=H-67
    if doc.get('level'):
        c.setFillColor(ORANGE);c.circle(m+11,y-6,11,fill=1,stroke=0)
        c.setFont(BOLD,9);c.setFillColor(DARK);c.drawCentredString(m+11,y-9,str(doc['level']))
        y=draw_par(c,p.get('kicker',''),m+32,y,W-2*m-32,8.3,color=NAVY,font=BOLD)-12
    else:y=draw_par(c,p.get('kicker',''),m,y,W-2*m,8.3 if not slide else 11,color=NAVY,font=BOLD)-12
    return draw_par(c,p['title'],m,y,W-2*m,26 if not slide else 34,color=NAVY,font=HEAD)-24

def draw_cover(c,doc,p,W,H,m):
    c.setFillColor(DARK);c.rect(0,0,W,H,fill=1,stroke=0)
    c.drawImage(str(ASSETS/'course-cover-students.png'),0,0,width=W,height=W*2/3,mask='auto')
    c.drawImage(str(ASSETS/'leaders-logo-white.png'),m,H-80,width=118,height=42,preserveAspectRatio=True,anchor='sw',mask='auto')
    c.setFont(BOLD,9);c.setFillColor(ORANGE);c.drawString(m,H-121,'MASTER · STATISTIQUE APPLIQUÉE')
    c.setFont(HEAD,43);c.setFillColor(colors.white)
    c.drawString(m,H-187,'Statistiques')
    c.drawString(m,H-241,'avec R')
    c.setFillColor(ORANGE);c.setFont(HEAD,32);c.drawString(m,H-295,'À votre rythme')
    c.setFillColor(colors.white);c.circle(W-m-53,H-213,48,fill=1,stroke=0)
    c.drawImage(str(ASSETS/'Rlogo.png'),W-m-86,H-239,width=66,height=51,preserveAspectRatio=True,anchor='c',mask='auto')
    draw_par(c,p.get('subtitle',''),m,H-325,W-2*m,15,color=colors.HexColor('#B4C5FF'))
    draw_par(c,p.get('tagline',''),m,H-353,W-2*m,10.5,color=colors.white)
    xx=m
    for label in p.get('chips',[]):
        width=pdfmetrics.stringWidth(label,BOLD,8)+20
        c.setFillColor(colors.HexColor('#25355C'));c.roundRect(xx,H-402,width,24,12,fill=1,stroke=0)
        c.setFillColor(colors.white);c.setFont(BOLD,8);c.drawString(xx+10,H-394,label);xx+=width+8

def draw_footer(c,doc,i,n,W,H,m):
    c.setStrokeColor(LINE);c.setLineWidth(.5);c.line(m,40,W-m,40)
    c.setFont(BOLD,7);c.setFillColor(NAVY);c.drawString(m,26,'LEADERS  /  R')
    c.setFont(BODY,7);c.setFillColor(MUTED);c.drawRightString(W-m,26,f'{i:02} / {n:02}  ·  Y. Douma')
    if doc.get('index_link'):
        c.setFont(BOLD,8);c.setFillColor(NAVY);c.drawCentredString(W/2,26,'Revenir au parcours')
        c.linkURL(doc['index_link'],(W/2-55,19,W/2+55,36),relative=True,thickness=0)

@lru_cache(maxsize=256)
def equation(latex, size):
    """LaTeX-style math -> vector paths. No TeX installation is needed."""
    os.environ.setdefault('MPLCONFIGDIR',str(Path(__file__).parent/'.mpl-cache'))
    from matplotlib import rc_context
    from matplotlib.mathtext import math_to_image
    from matplotlib.font_manager import FontProperties
    from svglib.svglib import svg2rlg
    content=latex.strip().strip('$')
    stream=BytesIO()
    with rc_context({'mathtext.fontset':'stix','svg.fonttype':'path','font.size':size}):
        math_to_image('$'+content+'$',stream,format='svg',dpi=144,color='#2B3180',prop=FontProperties(size=size))
    drawing=svg2rlg(BytesIO(stream.getvalue()))
    if drawing is None: raise ValueError('Equation could not be rendered: '+latex)
    return drawing

def draw_equation(c,latex,x,y,w,size=23,max_height=90):
    from reportlab.graphics import renderPDF
    drawing=deepcopy(equation(latex,size))
    scale=min(1,w/drawing.width,max_height/drawing.height)
    drawing.scale(scale,scale)
    width,height=drawing.width*scale,drawing.height*scale
    renderPDF.draw(drawing,c,x+(w-width)/2,y-height)
    return height
def markup(s):
    s=escape(str(s))
    return re.sub(r'(https://[^\s]+)',lambda m:f'<link href="{m[1]}" color="#2B3180">{m[1]}</link>',s)

def para(s,size=11,leading=None,color=INK,font=BODY):
    return Paragraph(markup(s),ParagraphStyle('p',fontName=font,fontSize=size,leading=leading or size*1.36,textColor=color,spaceAfter=0,splitLongWords=True))

def draw_par(c,s,x,y,w,size=11,color=INK,font=BODY):
    p=para(s,size,color=color,font=font); _,h=p.wrap(w,2000); p.drawOn(c,x,y-h); return y-h

def block(c,b,x,y,w,slide=False):
    typ=b['type']; size=16 if slide else 10.5
    if typ=='formula':
        latex=b['latex']; cap=b.get('caption','')
        drawing=equation(latex,30 if slide else 24)
        scale=min(1,(w-30)/drawing.width,(110 if slide else 90)/drawing.height)
        eh=drawing.height*scale
        p=para(cap,13 if slide else 9.8,color=MUTED);_,ph=p.wrap(w-30,1000)
        h=eh+(ph+9 if cap else 0)+28
        c.setFillColor(colors.HexColor('#EDF0FF'));c.roundRect(x,y-h,w,h,7,fill=1,stroke=0)
        draw_equation(c,latex,x+15,y-13,w-30,30 if slide else 24,110 if slide else 90)
        if cap:p.drawOn(c,x+15,y-13-eh-9-ph)
        return y-h-14
    if typ=='mathsteps':
        for i,item in enumerate(b['items'],1):
            c.setFont(BOLD,10 if not slide else 14);c.setFillColor(TEAL)
            c.drawString(x,y-10,str(i))
            drawing=equation(item['latex'],23 if not slide else 29)
            if not slide and drawing.width<=w*.64:
                eqw=w*.64-22;tw=w*.36-12
                p=para(item.get('explanation',''),9.8,color=MUTED);_,ph=p.wrap(tw,1000)
                eh=draw_equation(c,item['latex'],x+20,y,eqw,23,65)
                p.drawOn(c,x+w*.64+12,y-ph)
                y-=max(eh,ph)+15
            else:
                eh=draw_equation(c,item['latex'],x+20,y,w-20,23 if not slide else 29,65)
                y-=eh+7
                y=draw_par(c,item.get('explanation',''),x+20,y,w-20,10 if not slide else 14,color=MUTED)-13
        return y-3
    if typ=='links':
        for item in b['items']:
            label=item['label']; target=item['target']
            p=para(label,10.5 if not slide else 15,color=NAVY,font=BOLD);_,h=p.wrap(w-43,1000)
            c.setFillColor(PALE);c.roundRect(x,y-h-15,w,h+15,5,fill=1,stroke=0)
            p.drawOn(c,x+10,y-7-h)
            c.setFillColor(ORANGE);c.circle(x+w-17,y-(h+15)/2,7,fill=1,stroke=0)
            c.setStrokeColor(DARK);c.setLineWidth(1);c.line(x+w-19,y-(h+15)/2+2,x+w-16,y-(h+15)/2);c.line(x+w-19,y-(h+15)/2-2,x+w-16,y-(h+15)/2)
            c.linkURL(target,(x,y-h-15,x+w,y),relative=not target.startswith(('https://','http://')),thickness=0)
            y-=h+24
        return y-3
    if typ=='brandgrid':
        items=b['items'];gap=12;cw=(w-gap*(len(items)-1))/len(items)
        paragraphs=[];height=0
        for item in items:
            title=para(item['title'],11,color=NAVY,font=BOLD);_,th=title.wrap(cw-24,1000)
            body=para(item['text'],9.5,color=INK);_,bh=body.wrap(cw-24,1000)
            paragraphs.append((title,th,body,bh));height=max(height,th+bh+91)
        for j,(item,parts) in enumerate(zip(items,paragraphs)):
            xx=x+j*(cw+gap);title,th,body,bh=parts
            c.setFillColor(PALE);c.setStrokeColor(LINE);c.roundRect(xx,y-height,cw,height,9,fill=1,stroke=1)
            c.drawImage(str(asset(item['image'])),xx+16,y-59,width=cw-32,height=40,preserveAspectRatio=True,anchor='c',mask='auto')
            title.drawOn(c,xx+12,y-75-th);body.drawOn(c,xx+12,y-82-th-bh)
        return y-height-18
    if typ=='figure':
        from svglib.svglib import svg2rlg
        from reportlab.graphics import renderPDF
        drawing=svg2rlg(str(b['path']));limit=b.get('height',200)
        scale=min(w/drawing.width,limit/drawing.height)
        drawing.scale(scale,scale)
        dw,dh=drawing.width*scale,drawing.height*scale
        renderPDF.draw(drawing,c,x+(w-dw)/2,y-dh)
        y-=dh+10
        if b.get('caption'):y=draw_par(c,b['caption'],x,y,w,9.5,color=MUTED)-10
        return y-8
    if typ=='text': return draw_par(c,b['text'],x,y,w,size)-13
    if typ=='bullets':
        for item in b['items']:
            c.setFillColor(TEAL); c.circle(x+3,y-7 if not slide else y-10,2.2,fill=1,stroke=0)
            y=draw_par(c,item,x+15,y,w-15,size)-7
        return y-4
    if typ=='code':
        fs=16 if slide else 9.3; lead=fs*(1.25 if slide else 1.36)
        lines=b['text'].splitlines()
        longest=max((pdfmetrics.stringWidth(v,MONO,fs) for v in lines),default=0)
        if longest>w-28:
            raise ValueError('Code line exceeds available width; format the source explicitly: '+max(lines,key=len))
        h=len(lines)*lead+24
        c.setFillColor(DARK);c.roundRect(x,y-h,w,h,8,fill=1,stroke=0)
        for i,line in enumerate(lines):
            c.setFont(MONO,fs);c.setFillColor(colors.HexColor('#B4C5FF') if line.lstrip().startswith('#') else colors.HexColor('#FFFFFF'))
            c.drawString(x+14,y-17-i*lead,line)
        return y-h-14
    if typ=='callout':
        label=b.get('label','À RETENIR'); body=b.get('text','')
        p=para(body,size if not slide else 15);_,ph=p.wrap(w-30,2000)
        h=ph+43
        c.setFillColor(PALE);c.roundRect(x,y-h,w,h,7,fill=1,stroke=0)
        c.setFillColor(ORANGE);c.rect(x,y-h,4,h,fill=1,stroke=0)
        draw_par(c,label.upper(),x+15,y-12,w-30,9 if not slide else 11,color=NAVY,font=BOLD)
        p.drawOn(c,x+15,y-31-ph)
        return y-h-16
    if typ=='table':
        rows=[b['headers']]+b['rows']; n=len(rows[0]); fs=13 if slide else 9.5
        widths=b.get('widths',[w/n]*n)
        if n==3 and rows[0][1]=='Durée': widths=[w*.2,w*.12,w*.68]
        cells=[[para(v,fs,fs*1.35,colors.white if i==0 else INK,BOLD if i==0 else BODY) for v in row] for i,row in enumerate(rows)]
        t=Table(cells,colWidths=widths,hAlign='LEFT')
        t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),NAVY),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,PALE]),('LINEBELOW',(0,0),(-1,0),.5,TEAL)]))
        _,h=t.wrap(w,2000);t.drawOn(c,x,y-h);return y-h-18
    if typ=='diagram':
        nodes=b.get('nodes',[]); n=len(nodes); cols=min(4 if not slide else 5,n); rows=math.ceil(n/cols); gap=18
        bw=(w-gap*(cols-1))/cols; bh=66 if not slide else 82
        for i,label in enumerate(nodes):
            row,col=divmod(i,cols); xx=x+col*(bw+gap); yy=y-row*(bh+20)
            c.setFillColor(NAVY if i%2==0 else DARK);c.roundRect(xx,yy-bh,bw,bh,8,fill=1,stroke=0)
            p=para(label,10 if not slide else 14,color=colors.white,font=BOLD);_,h=p.wrap(bw-20,bh-12);p.drawOn(c,xx+10,yy-bh/2-h/2)
            if col<cols-1 and i<n-1:
                c.setStrokeColor(ORANGE);c.setLineWidth(1.8); ay=yy-bh/2
                c.line(xx+bw+3,ay,xx+bw+gap-3,ay)
                c.line(xx+bw+gap-7,ay+3,xx+bw+gap-3,ay);c.line(xx+bw+gap-7,ay-3,xx+bw+gap-3,ay)
            elif i<n-1:
                # Explicit sequence number makes wrapped flow order unambiguous.
                pass
            c.setFont(BOLD,8 if not slide else 10);c.setFillColor(colors.HexColor('#C3E7DB'));c.drawRightString(xx+bw-7,yy-12,str(i+1))
        return y-rows*(bh+20)-2
    if typ=='image':
        p=Path(b['path']); h=b.get('height',210)
        c.drawImage(str(p),x,y-h,width=w,height=h,preserveAspectRatio=True,anchor='c',mask='auto')
        return y-h-18
    raise ValueError(f'Unknown block type {typ}')

def build(doc,out):
    slide=doc.get('landscape',False); W,H=(960,540) if slide else A4; m=45 if not slide else 52
    path=(out.parent if doc.get('root_document') else out)/doc['filename'];path.parent.mkdir(parents=True,exist_ok=True)
    c=canvas.Canvas(str(path),pagesize=(W,H),pageCompression=1)
    c.setTitle(doc['title']);c.setAuthor('Youssef Douma · Leaders University');c.setSubject(doc.get('subtitle',''))
    n=len(doc['pages']); errors=[]
    if n>2:c.showOutline()
    for i,p in enumerate(doc['pages'],1):
        c.bookmarkPage(f'p{i}');c.addOutlineEntry(p['title'],f'p{i}',level=0)
        if p.get('layout')=='cover':
            draw_cover(c,doc,p,W,H,m)
        else:
            y=draw_page_header(c,doc,p,i,n,W,H,m)
            for b in p['blocks']:y=block(c,b,m,y,W-2*m,slide)
            if y<54:errors.append((str(path),i,p['title'],round(y,1)))
            draw_footer(c,doc,i,n,W,H,m)
        c.showPage()
    c.save()
    if errors: raise RuntimeError('Page overflow: '+repr(errors))
    return {'file':str(path),'pages':n,'bytes':path.stat().st_size}

def main():
    a=argparse.ArgumentParser();a.add_argument('sources',nargs='+');a.add_argument('--out',required=True);args=a.parse_args()
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True);receipt=[]
    failures=[]
    for source in args.sources:
        for d in json.loads(Path(source).read_text())['documents']:
            try: receipt.append(build(d,out))
            except RuntimeError as e: failures.append(str(e))
    print(json.dumps(receipt,ensure_ascii=False,indent=2))
    if failures: raise RuntimeError('\n'.join(failures))

if __name__=='__main__':main()
