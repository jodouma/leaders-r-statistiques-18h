"""Deterministic café teaching diagrams. No learner Python dependency.

Run from repository root or provide --repo. All displayed facts are asserted
against the shipped CSV files. SVG letters are paths for PDF portability.
"""
from pathlib import Path
import argparse, csv, json
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle, FancyArrowPatch, Circle
from matplotlib.font_manager import FontProperties, fontManager

HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(); p.add_argument('--repo',type=Path,default=HERE.parent); args=p.parse_args()
ROOT=args.repo.resolve(); OUT=HERE/'assets/v5'; OUT.mkdir(parents=True,exist_ok=True); PREVIEW=ROOT/'outputs/visuals'; PREVIEW.mkdir(parents=True,exist_ok=True)
INK='#07152F'; NAVY='#2B3180'; BLUE='#4E73FF'; ORANGE='#FF9A3C'; RUST='#A34A00'; PALE='#F0EEFF'; WHITE='#FFFFFF'; LINE='#CDCDEC'; MUTED='#414B69'; GREEN='#17745A'; MINT='#DCF3E9'
for weight in (400,600,700): fontManager.addfont(str(ROOT/f'authoring/fonts/Inter-{weight}.ttf'))
FONT=FontProperties(fname=ROOT/'authoring/fonts/Inter-400.ttf').get_name()
plt.rcParams.update({'font.family':FONT,'font.size':10,'text.color':INK,'svg.fonttype':'path','axes.unicode_minus':False,'svg.hashsalt':'noria-v5'})

def read(name):
 with (ROOT/'data'/name).open(newline='',encoding='utf8') as f:return list(csv.DictReader(f))
raw=read('orders_raw.csv'); mini=read('orders_mini.csv'); week2=read('orders_week2_raw.csv')
def clean(rows):
 seen=set(); unique=[]
 for r in rows:
  key=tuple(r.items())
  if key not in seen:unique.append(r);seen.add(key)
 return [r for r in unique if r['quantite']!=''],[r for r in unique if r['quantite']==''],len(rows)-len(unique)
rows,missing,duplicates=clean(raw); rows2,missing2,duplicates2=clean(week2)
def calc(r):return int(r['quantite'])*int(r['prix_unitaire']),int(r['quantite'])*int(r['cout_unitaire'])
days=defaultdict(int); products=defaultdict(lambda:[0,0,0])
for r in rows:
 ca,cost=calc(r);days[r['date']]+=ca;products[r['produit']][0]+=ca;products[r['produit']][1]+=cost;products[r['produit']][2]+=int(r['quantite'])
CA=sum(x[0] for x in products.values());COST=sum(x[1] for x in products.values()); MARGIN=CA-COST
assert len(raw)==14 and len(rows)==12 and duplicates==1 and len(missing)==1
assert list(days.values())==[19,27,33,21] and CA==100 and COST==37 and MARGIN==63
assert {k:v[0] for k,v in products.items()}=={'Cafe':30,'The':30,'Sandwich':40}
assert {k:v[0]-v[1] for k,v in products.items()}=={'Cafe':20,'The':18,'Sandwich':25}
assert len(rows2)==6 and len(set(r['date'] for r in rows2))==2 and sum(calc(r)[0] for r in rows2)==48
assert sum(calc(r)[0] for r in mini)==19 and sum(calc(r)[1] for r in mini)==7
assert [calc(r)[0] for r in mini]==[6,5,8]

mapping=[]
def scene(name,height=185):
 fig=plt.figure(figsize=(505/72,height/72)); fig.patch.set_facecolor(PALE)
 ax=fig.add_axes([0,0,1,1]); ax.set_xlim(0,100);ax.set_ylim(0,40);ax.set_axis_off()
 return fig,ax

def txt(ax,x,y,s,size=10,color=INK,weight='normal',ha='center',va='center',**kw):
 return ax.text(x,y,s,fontsize=size,color=color,fontweight=weight,ha=ha,va=va,**kw)
def box(ax,x,y,w,h,fill=WHITE,edge=None,r=1.6,lw=.8):
 ax.add_patch(FancyBboxPatch((x,y),w,h,boxstyle=f'round,pad=0,rounding_size={r}',facecolor=fill,edgecolor=edge or fill,linewidth=lw))
def arrow(ax,x,y,x2,y2,color=NAVY,lw=1.3):
 ax.add_patch(FancyArrowPatch((x,y),(x2,y2),arrowstyle='-|>',mutation_scale=9,color=color,linewidth=lw,shrinkA=1,shrinkB=1))
def pill(ax,x,y,w,label,fill=NAVY,textcolor=WHITE):
 box(ax,x,y,w,6,fill,r=2.8);txt(ax,x+w/2,y+3,label,9,textcolor,'bold')
def save(fig,name,page,alt,height=185,kind='mental_model'):
 fig.savefig(OUT/f'{name}.svg',format='svg',facecolor=PALE,metadata={'Date':None});fig.savefig(PREVIEW/f'{name}.png',dpi=150,facecolor=PALE);plt.close(fig)
 mapping.append({'id':name,'path':f'authoring/assets/v5/{name}.svg','source':f'assets/{name}.svg','page_title':page,'width_pt':505,'height_pt':height,'kind':kind,'alt':alt})

# 1. A recurring journey, including the initial setup.
fig,ax=scene('parcours',165)
steps=[('0','Ouvrir R'),('1','Panier'),('2','Semaine'),('3','Importer'),('4','Nettoyer'),('5','Bilan'),('6','Dessiner'),('7','Décider'),('8','Fonction')]
for i,(n,label) in enumerate(steps):
 x=4+i*10.5
 ax.add_patch(Circle((x+4,24),3.4,facecolor=ORANGE if i in (0,8) else BLUE))
 txt(ax,x+4,24,n,11,INK if i in (0,8) else WHITE,'bold')
 txt(ax,x+4,14,label,8.4,weight='bold')
 if i<8:arrow(ax,x+7.7,24,x+10.7,24)
txt(ax,50,5,'Une même caisse devient un outil que vous savez réutiliser.',10,NAVY)
save(fig,'parcours','Huit portes, une seule histoire','Du dossier ouvert à la fonction : neuf étapes dans un seul café.',165)

# 2. Each unit is visible before the addition.
fig,ax=scene('panier')
items=[('Café',2,3,6),('Thé',1,5,5),('Sandwich',1,8,8)]
for i,(label,q,unit,subtotal) in enumerate(items):
 x=3+i*25
 box(ax,x,10,23,27,WHITE);txt(ax,x+11.5,33,label,11,weight='bold')
 for j in range(q):
  xx=x+5+(j*9 if q==2 else 4.5)
  box(ax,xx,20,7.5,7,BLUE);txt(ax,xx+3.75,23.5,str(unit),11,WHITE,'bold')
 txt(ax,x+11.5,14.5,f'{q} × {unit} = {subtotal}',11,weight='bold')
 if i<2:txt(ax,x+24,23,'+',14,NAVY,'bold')
arrow(ax,78,23,83,23);box(ax,84,14,13,18,NAVY)
txt(ax,90.5,25,'19',20,WHITE,'bold');txt(ax,90.5,19,'TND',9,WHITE)
txt(ax,40,4,'Chaque petite case est le prix d’une unité.',9,MUTED)
save(fig,'panier','Le tout premier ticket','Deux cafés à 3 TND, un thé à 5 TND et un sandwich à 8 TND donnent 19 TND.')

# 3. Cost is part of revenue; margin is what is left.
fig,ax=scene('cout_marge')
txt(ax,3,35,'Le ticket rapporte 19 TND',12,weight='bold',ha='left')
for i,(label,q,cost) in enumerate([('Café',2,1),('Thé',1,2),('Sandwich',1,3)]):
 x=3+i*23
 box(ax,x,22,21,8,WHITE);txt(ax,x+10.5,26,f'{q} × {cost} = {q*cost}',11,weight='bold');txt(ax,x+10.5,18,label,9)
txt(ax,74,26,'=',14,weight='bold');pill(ax,79,23,18,'7 TND',NAVY)
# proportional stack 7+12=19
x=3; y=4; width=94
box(ax,x,y,width*7/19,9,NAVY,r=0);box(ax,x+width*7/19,y,width*12/19,9,ORANGE,r=0)
txt(ax,x+width*7/38,y+4.5,'Coût : 7',11,WHITE,'bold');txt(ax,x+width*7/19+width*12/38,y+4.5,'Marge : 19 − 7 = 12 TND',11,INK,'bold')
save(fig,'cout_marge','Première porte ouverte : calculer','Le coût du panier est 2 × 1 + 1 × 2 + 1 × 3 = 7 TND ; sa marge est 19 − 7 = 12 TND.')

# 4. Position is not the value.
fig,ax=scene('vecteur')
pill(ax,3,30,40,'ventes_journalieres',NAVY);txt(ax,72,33,'4 valeurs, un seul objet',10)
ax.plot([24,24,90,90],[25.5,27.2,27.2,25.5],color=NAVY,lw=1.2)
for i,val in enumerate(days.values()):
 x=24+i*17
 box(ax,x,10,15,15,BLUE);txt(ax,x+7.5,18,str(val),20,WHITE,'bold');txt(ax,x+7.5,5.5,f'position {i+1}',9)
txt(ax,6,18,'TND',10,weight='bold',ha='left')
save(fig,'vecteur','Un vecteur, quatre valeurs','ventes_journalieres contient 19, 27, 33 et 21 TND aux positions 1 à 4.')

# 5. Equal-share model; distinguish from the observed days.
fig,ax=scene('moyenne')
box(ax,3,10,22,23,NAVY);txt(ax,14,25,'100',23,WHITE,'bold');txt(ax,14,17,'TND au total',9,WHITE)
arrow(ax,27,22,38,22);txt(ax,32,31,'÷ 4',13,NAVY,'bold')
for i in range(4):
 x=40+i*14
 box(ax,x,13,12,17,ORANGE);txt(ax,x+6,24,'25',17,INK,'bold');txt(ax,x+6,17,'TND',9)
 txt(ax,x+6,8,f'part {i+1}',8.5)
txt(ax,50,3,'La moyenne partage le total en quatre parts égales.',10,NAVY)
save(fig,'moyenne','Quatre jours dans la même boîte','La moyenne 100 ÷ 4 = 25 TND est un partage égal ; les quatre jours observés restent 19, 27, 33 et 21 TND.')

# 6. CSV grid with row/column/cell landmarks.
fig,ax=scene('tableau_csv',210)
xs=[4,14,35,55,69,83]; ws=[10,21,20,14,14,14]
headers=['id','date','produit','quantite','prix_unitaire','cout_unitaire']
labels=['id','date','produit','quantite','prix\nunitaire','coût\nunitaire']
for j,label in enumerate(labels):
 box(ax,xs[j],28,ws[j],9,NAVY,r=0);txt(ax,xs[j]+ws[j]/2,32.5,label,8.2,WHITE,'bold')
for i,row in enumerate(mini):
 y=20-i*8
 for j,key in enumerate(headers):
  fill=ORANGE if (i,j)==(1,3) else ('#DCDFFF' if j==3 else WHITE)
  box(ax,xs[j],y,ws[j],8,fill,edge=PALE,r=0)
  txt(ax,xs[j]+ws[j]/2,y+4,row[key],8.6,weight='bold' if (i,j)==(1,3) else 'normal')
txt(ax,4,39,'1 ligne = 1 vente enregistrée',9,NAVY,'bold',ha='left')
txt(ax,62,39,'1 colonne = 1 information',9,NAVY,'bold',ha='center')
txt(ax,50,1.5,'La cellule orange : quantité du thé = 1.',9,RUST,'bold')
save(fig,'tableau_csv','Les mots du fichier','Une ligne décrit une vente, une colonne une information ; la cellule orange est la quantité 1 du thé.',210)

# 7. Explicit branch, missing never becomes zero.
fig,ax=scene('nettoyage',190)
box(ax,3,14,20,20,NAVY);txt(ax,13,27,'14',22,WHITE,'bold');txt(ax,13,20,'lignes importées',8.5,WHITE)
arrow(ax,24,24,35,24);txt(ax,29,34,'− 1 doublon',8.8,NAVY,'bold')
box(ax,36,14,21,20,BLUE);txt(ax,46.5,27,'13',22,WHITE,'bold');txt(ax,46.5,20,'lignes uniques',9,WHITE)
arrow(ax,58,25,70,30);arrow(ax,58,23,70,11)
box(ax,71,23,26,14,MINT);txt(ax,84,32,'12 complètes',12,GREEN,'bold');txt(ax,84,27,'→ calculer',9,GREEN)
box(ax,71,3,26,15,ORANGE);txt(ax,84,13,'1 incomplète',11,INK,'bold');txt(ax,84,7,'→ isoler, vérifier',9)
txt(ax,30,5,'Quantité absente : inconnue, donc pas 0.',9,RUST,'bold')
save(fig,'nettoyage','Une règle visible pour chaque ligne','14 lignes deviennent 13 lignes uniques, puis 12 lignes complètes et 1 ligne isolée pour quantité manquante.',190)

# 8. Reading across first, then applying down.
fig,ax=scene('calcul_lignes',200)
cols=[(4,22,'quantite'),(27,25,'prix_unitaire'),(58,19,'ca'),(81,15,'marge')]
for x,w,label in cols:box(ax,x,28,w,8,NAVY,r=1);txt(ax,x+w/2,32,label,10,WHITE,'bold')
for i,r in enumerate(mini):
 y=19-i*8;ca,cost=calc(r)
 for x,w,v in [(4,22,int(r['quantite'])),(27,25,int(r['prix_unitaire'])),(58,19,ca),(81,15,ca-cost)]:
  box(ax,x,y,w,7,WHITE if x<58 else '#DDE3FF',r=1);txt(ax,x+w/2,y+3.5,str(v),12,weight='bold')
 txt(ax,26, y+3.5,'×',11,NAVY,'bold');txt(ax,55,y+3.5,'=',11,NAVY,'bold')
txt(ax,50,1.2,'R répète la même règle sur toutes les lignes.',9,NAVY)
save(fig,'calcul_lignes','Calculer sans recopier douze fois','Chaque ligne calcule quantité × prix unitaire ; les trois premières donnent 6, 5 et 8 TND de chiffre d’affaires.',200)

# 9. Group then sum, with exact intermediate totals.
fig,ax=scene('regrouper',215)
for i,(key,label) in enumerate([('Cafe','Café'),('Sandwich','Sandwich'),('The','Thé')]):
 x=3+i*32
 box(ax,x,3,30,34,WHITE);pill(ax,x+2,29,26,label,fill=NAVY)
 vals=[calc(r)[0] for r in rows if r['produit']==key]
 txt(ax,x+15,24,' + '.join(map(str,vals)),10,weight='bold')
 arrow(ax,x+15,21,x+15,17)
 ca,cost,qty=products[key]
 txt(ax,x+15,14,f'CA : {ca} TND',12,BLUE,'bold')
 txt(ax,x+15,8,f'Coût {cost} · marge {ca-cost}',9,MUTED)
save(fig,'regrouper','Réunir les ventes par produit','Les chiffres d’affaires regroupés valent 6 + 9 + 12 + 3 = 30 TND pour le café, 8 + 8 + 16 + 8 = 40 pour le sandwich et 5 + 10 + 5 + 10 = 30 pour le thé.',215)

# 10. Scale and denominator are explicit.
fig,ax=scene('composition')
txt(ax,3,34,'100 TND encaissés',13,weight='bold',ha='left')
box(ax,3,14,94*.37,13,NAVY,r=0);box(ax,3+94*.37,14,94*.63,13,ORANGE,r=0)
txt(ax,3+94*.37/2,20.5,'Coût : 37 TND',12,WHITE,'bold');txt(ax,3+94*.37+94*.63/2,20.5,'Marge : 63 TND',12,INK,'bold')
arrow(ax,50,12,50,6);txt(ax,50,3,'Marge = chiffre d’affaires − coût',10,NAVY,'bold')
save(fig,'composition','Trois mesures, un seul résumé','Le chiffre d’affaires de 100 TND se décompose en 37 TND de coût et 63 TND de marge.')

# 11. Two distinct quantities: no ambiguous bar comparison.
fig,ax=scene('unites')
for x,value,unit,caption,fill in [(4,'30','TND','Chiffre d’affaires du café',NAVY),(53,'10','cafés','Quantité de café vendue',BLUE)]:
 box(ax,x,7,43,29,fill);txt(ax,x+21.5,26,value,28,WHITE,'bold');txt(ax,x+21.5,17,unit,12,WHITE,'bold');txt(ax,x+21.5,11,caption,8.7,WHITE)
txt(ax,50,3,'Même produit, deux questions : combien d’argent ? combien d’unités ?',9,NAVY)
save(fig,'unites','Un regard suffit pour comparer','Le café représente 30 TND de chiffre d’affaires pour 10 unités vendues ; une somme d’argent et une quantité ont des unités différentes.')

# 12. Both product questions, equal baseline/units.
fig=plt.figure(figsize=(505/72,210/72));fig.patch.set_facecolor(PALE)
for n,(measure,title) in enumerate([(0,'Chiffre d’affaires (TND)'),(1,'Marge (TND)')]):
 ax=fig.add_axes([.07+n*.5,.21,.4,.62]);ax.set_facecolor(PALE)
 keys=['Cafe','Sandwich','The'];vals=[products[k][0] if measure==0 else products[k][0]-products[k][1] for k in keys]
 bars=ax.bar(['Café','Sandwich','Thé'],vals,color=[BLUE,ORANGE,BLUE],width=.56)
 ax.set_ylim(0,46);ax.set_yticks([0,20,40]);ax.tick_params(length=0,labelsize=9,pad=5,colors=INK)
 ax.set_title(title,fontsize=10,fontweight='bold',loc='left',pad=15)
 ax.set_axisbelow(True);ax.grid(axis='y',color=LINE,lw=.7)
 for sp in ax.spines.values():sp.set_visible(False)
 for b,v in zip(bars,vals):ax.text(b.get_x()+b.get_width()/2,v+1,str(v),ha='center',va='bottom',fontsize=12,fontweight='bold')
save(fig,'produits','Deux graphiques, deux questions','Le chiffre d’affaires vaut 30, 40 et 30 TND ; la marge vaut 20, 25 et 18 TND pour Café, Sandwich, Thé.',210,'data_chart')

# 13. Hundred-square percentage means exactly 40 in a hundred.
fig,ax=scene('pourcentage',210)
for row in range(10):
 for col in range(10):
  ax.add_patch(Rectangle((5+col*3.5,3+row*3.5),3,3,facecolor=ORANGE if row>=6 else WHITE,edgecolor='none'))
box(ax,46,21,49,15,NAVY);txt(ax,70.5,30,'40 ÷ 100 × 100',16,WHITE,'bold');txt(ax,70.5,24,'= 40 %',13,WHITE,'bold')
txt(ax,70.5,14,'Sandwich : 40 TND',11,weight='bold');txt(ax,70.5,8,'Tous les produits : 100 TND',9.5)
txt(ax,22,39,'1 case = 1 % du total',9,NAVY,'bold')
save(fig,'pourcentage','Sélectionner, puis calculer la part','40 cases orange sur 100 représentent la part du sandwich : 40 TND sur 100 TND, soit 40 %.',210)

# 14. File device must close; durable image vs temporary plot.
fig,ax=scene('png_cycle')
for x,n,title,sub in [(3,'1','Ouvrir','png(...)'),(37,'2','Dessiner','barplot(...)'),(71,'3','Fermer','dev.off()')]:
 box(ax,x,10,26,25,WHITE);pill(ax,x+2,28,7,n,fill=BLUE);txt(ax,x+13,23,title,12,weight='bold');txt(ax,x+13,16,sub,10,NAVY,'bold')
 if x<70:arrow(ax,x+27,22,x+32,22)
pill(ax,19,1,62,'Le PNG est terminé et présent sur disque.',fill=NAVY)
save(fig,'png_cycle','Une image qui reste après la séance','Pour enregistrer un PNG : ouvrir avec png(), dessiner avec barplot(), puis terminer avec dev.off().')

# 15. Function wraps the same known steps.
fig,ax=scene('fonction',215)
box(ax,3,12,20,17,NAVY);txt(ax,13,23,'Un CSV',13,WHITE,'bold');txt(ax,13,17,'chemin reçu',8.8,WHITE)
arrow(ax,24,21,30,21)
box(ax,31,3,40,34,WHITE,edge=LINE)
txt(ax,51,33,'resumer_commandes(chemin)',10,NAVY,'bold')
for i,label in enumerate(['Importer','Nettoyer','Calculer']):
 y=22-i*8;box(ax,36,y,30,6,BLUE);txt(ax,51,y+3,label,10,WHITE,'bold')
 if i<2:arrow(ax,51,y,51,y-2)
arrow(ax,72,21,78,21)
box(ax,79,8,18,25,ORANGE);txt(ax,88,28,'Un bilan',11,weight='bold');txt(ax,88,20,'1 ligne',13,weight='bold');txt(ax,88,13,'CA · coût\nmarge',8.5)
save(fig,'fonction','Recevoir un fichier, rendre un bilan','La fonction reçoit un chemin CSV, importe, nettoie et calcule, puis renvoie un bilan d’une ligne.',215)

# 16. Plain cards prevent a false performance bar comparison.
fig,ax=scene('deux_fichiers',205)
for x,label,src,ndays,rev,nlines in [(3,'Première caisse','orders_raw.csv',4,100,12),(52,'Nouvelle caisse','orders_week2_raw.csv',2,48,6)]:
 box(ax,x,8,45,29,WHITE);pill(ax,x+2,29,41,label,fill=NAVY)
 txt(ax,x+22.5,24,src,8.3,MUTED)
 txt(ax,x+14,17,str(rev),23,BLUE,'bold');txt(ax,x+14,11,'TND au total',8.8)
 txt(ax,x+34,18,f'{ndays} jours',11,weight='bold');txt(ax,x+34,12,f'{nlines} lignes',9)
txt(ax,50,3,'La recette est identique. Les périodes couvertes sont différentes.',9,NAVY,'bold')
save(fig,'deux_fichiers','La même recette, une autre caisse','Le premier fichier couvre 4 jours et 100 TND ; le second couvre 2 jours et 48 TND. Les totaux ne comparent pas des périodes de même durée.',205)

# 17. Assigning names is a durable mental model.
fig,ax=scene('objets')
for y,name,value in [(26,'total_panier','19'),(13,'cout_panier','7')]:
 pill(ax,4,y,34,name,fill=NAVY);txt(ax,47,y+3,'←',20,NAVY,'bold');box(ax,57,y-1,18,8,ORANGE);txt(ax,66,y+3,value,15,INK,'bold');txt(ax,84,y+3,'TND',10,ha='left')
txt(ax,21,8,'le nom',9,MUTED);txt(ax,66,8,'la valeur',9,MUTED)
txt(ax,50,2,'Le nom permet de retrouver le résultat et de le réutiliser.',10,NAVY)
save(fig,'objets','Donner un nom à un résultat','total_panier reçoit la valeur 19 et cout_panier reçoit la valeur 7 ; un nom permet de retrouver et réutiliser un résultat.')

(HERE/'visual_mapping.json').write_text(json.dumps({'figures':mapping,'facts':{'raw_rows':len(raw),'clean_rows':len(rows),'days':dict(days),'products':dict(products),'total':CA,'cost':COST,'margin':MARGIN}},ensure_ascii=False,indent=2)+'\n',encoding='utf8')
# A publication-independent contact sheet for direct visual inspection.
from PIL import Image,ImageDraw
import io
thumbs=[]
for item in mapping:
 im=Image.open(PREVIEW/(item['id']+'.png')).convert('RGB');im.thumbnail((808,355));thumbs.append((item['id'],im))
w=1680;rows_n=(len(thumbs)+1)//2;canvas=Image.new('RGB',(w,rows_n*390),'#FFFFFF');d=ImageDraw.Draw(canvas)
for i,(name,im) in enumerate(thumbs):
 x=20+(i%2)*830;y=(i//2)*390+25;d.text((x,y-18),name,fill=INK);canvas.paste(im,(x,y))
canvas.save(ROOT/'outputs/visual_contact_sheet.png')
print(f'Generated {len(mapping)} asserted SVGs in {OUT}')
