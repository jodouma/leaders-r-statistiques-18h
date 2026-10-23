"""Rebuild the course's vector illustrations. Maintainer tool, not an R prerequisite."""
from pathlib import Path
import os
os.environ.setdefault('MPLCONFIGDIR',str(Path(__file__).parent/'.mpl-cache'))
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
import numpy as np

DEST=Path('authoring/assets/v2');DEST.mkdir(parents=True,exist_ok=True)
NAVY='#2B3180';TEAL='#4E73FF';ORANGE='#FF9A3C';PALE='#EDF0FF';MUTED='#52617D';LABEL_ORANGE='#A34A00'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'svg.fonttype':'path','axes.spines.top':False,'axes.spines.right':False,'axes.labelcolor':NAVY,'text.color':NAVY,'axes.edgecolor':'#9BB0B5'})

def finish(fig,name):
    fig.savefig(DEST/(name+'.svg'),format='svg',bbox_inches='tight',transparent=True)
    plt.close(fig)

def cells(ax,values,headers=None,row_labels=None,title=''):
    values=np.asarray(values,dtype=object);rows,cols=values.shape
    ax.set_xlim(-.8,cols+.05);ax.set_ylim(rows+.8,-.8);ax.axis('off');ax.set_title(title,loc='left',fontweight='bold',pad=12)
    for i in range(rows):
        for j in range(cols):
            color=PALE if (i+j)%2==0 else '#F4F7F5'
            ax.add_patch(Rectangle((j,i),1,1,facecolor=color,edgecolor='white',linewidth=2))
            ax.text(j+.5,i+.5,str(values[i,j]),ha='center',va='center',fontsize=12)
    if headers:
        for j,h in enumerate(headers):ax.text(j+.5,-.3,h,ha='center',va='center',fontsize=9,color=TEAL,fontweight='bold')
    if row_labels:
        for i,l in enumerate(row_labels):ax.text(-.2,i+.5,l,ha='right',va='center',fontsize=10,color=MUTED)

fig,ax=plt.subplots(figsize=(7.5,1.8));cells(ax,[[10,20,30]],headers=['x[1]','x[2]','x[3]'],title='Un vecteur numérique : 3 valeurs, un même type');finish(fig,'vecteur')
fig,axs=plt.subplots(1,2,figsize=(8,2.5))
cells(axs[0],[[1,3,5],[2,4,6]],headers=['col. 1','col. 2','col. 3'],row_labels=['ligne 1','ligne 2'],title='Matrice : 2 lignes × 3 colonnes')
axs[1].axis('off');axs[1].text(.05,.75,'m[2, 1] = 2',fontsize=19,color=TEAL);axs[1].text(.05,.47,'m[ligne, colonne]',fontsize=14);axs[1].text(.05,.22,'R remplit par colonnes par défaut.',fontsize=10)
finish(fig,'matrice')
fig,axs=plt.subplots(1,2,figsize=(7.5,2.4));cells(axs[0],[[1,3],[2,4]],title='jour 1 : a[ , , 1]');cells(axs[1],[[5,7],[6,8]],title='jour 2 : a[ , , 2]');fig.suptitle('array : deux matrices empilées — dimensions 2 × 2 × 2',fontsize=13,fontweight='bold',y=1.12);finish(fig,'array')
fig,ax=plt.subplots(figsize=(8,2.4));cells(ax,[[1,'A',10],[2,'B',20],[3,'A',30]],headers=['ticket_id : integer','workflow : character','resolution_minutes : numeric'],row_labels=['ticket 1','ticket 2','ticket 3'],title='data.frame : une colonne par variable, une ligne par observation');finish(fig,'dataframe')
fig,ax=plt.subplots(figsize=(8,2.2));ax.axis('off')
for j,(name,body) in enumerate([('donnees','vecteur : 10, 20, 30'),('titre','texte : "Noria"'),('valide','logique : TRUE')]):
    xx=.02+j*.33;ax.add_patch(Rectangle((xx,.22),.30,.55,transform=ax.transAxes,facecolor=PALE,edgecolor='white'))
    ax.text(xx+.15,.61,name,ha='center',transform=ax.transAxes,fontweight='bold',color=TEAL);ax.text(xx+.15,.39,body,ha='center',transform=ax.transAxes,fontsize=10)
ax.text(.02,.94,'Une list conserve des objets de formes et types différents',transform=ax.transAxes,fontsize=13,fontweight='bold');finish(fig,'liste')
fig,ax=plt.subplots(figsize=(8,2.4));x=np.array([10,20,30]);ax.scatter(x,np.zeros(3),s=120,color=TEAL,zorder=3);ax.axhline(0,color=MUTED,lw=1);ax.axvline(x.mean(),color=ORANGE,lw=2,ls='--');ax.set_yticks([]);ax.set_xticks([10,20,30]);ax.set_xlabel('Durée (minutes)');ax.set_ylim(-.5,1)
for v in x:ax.annotate(f'{v-x.mean():+.0f}',xy=((v+x.mean())/2,.25),ha='center',color=LABEL_ORANGE,fontsize=12)
ax.annotate('moyenne = 20 min',xy=(20,.75),ha='center',fontweight='bold',color=LABEL_ORANGE)
ax.set_title('La somme des écarts à la moyenne vaut zéro',loc='left',fontweight='bold');finish(fig,'moyenne')
fig,ax=plt.subplots(figsize=(8,2.5));deviations=np.array([-10,0,10]);ax.bar([0,1,2],deviations,color=[TEAL,'#AAA',TEAL]);ax.axhline(0,color=MUTED,lw=1);ax.set_xticks([0,1,2],['10 − 20','20 − 20','30 − 20']);ax.set_ylabel('Écart à la moyenne (min)');ax.set_title('Écarts : −10, 0, +10 min → carrés : 100, 0, 100 min²',loc='left',fontweight='bold');finish(fig,'dispersion')
fig,ax=plt.subplots(figsize=(8,2.5));xx=np.linspace(0,100,500)
for mu,n,color in [(50,4,ORANGE),(50,100,TEAL)]:
    se=10/np.sqrt(n);yy=np.exp(-.5*((xx-mu)/se)**2)/(se*np.sqrt(2*np.pi));ax.plot(xx,yy,color=color,lw=2,label=f'n = {n}, SE = {se:g} min')
ax.set_xlim(30,70);ax.set_xlabel('Moyennes répétées dans ce modèle illustratif (min)');ax.set_ylabel('Densité');ax.set_title('Même dispersion des tickets (s = 10 min), précision différente',loc='left',fontweight='bold');ax.legend(frameon=False);finish(fig,'se')
fig,ax=plt.subplots(figsize=(8,2.2));ax.set_xlim(-11,3);ax.set_ylim(0,2);ax.set_yticks([]);ax.axvline(0,color=NAVY,ls='--');ax.axvline(-5,color=ORANGE,ls=':');ax.plot([-9.1476483068,.0180785301],[1,1],color=TEAL,lw=4);ax.scatter([-4.5647848883],[1],s=100,color=TEAL,zorder=3);ax.set_xlabel('Différence moyenne B − A (minutes)');ax.set_title('Noria : estimation −4,565 min ; IC 95 % [−9,148 ; 0,018]',loc='left',fontweight='bold');ax.text(-5,1.6,'−5 min : seuil illustratif',ha='center',color=LABEL_ORANGE,fontsize=10);finish(fig,'welch_noria')
fig,ax=plt.subplots(figsize=(8,3.0))
x=[10,20,30,40,50,60,70,80,150]
ax.boxplot(x,vert=False,positions=[1],widths=.28,
           patch_artist=True,boxprops={'facecolor':PALE,'edgecolor':TEAL},
           medianprops={'color':ORANGE,'linewidth':2},
           whiskerprops={'color':TEAL},capprops={'color':TEAL},
           flierprops={'marker':'o','markerfacecolor':ORANGE,'markeredgecolor':ORANGE})
ax.set_yticks([]);ax.set_ylim(.35,1.8);ax.set_xlim(0,163)
ax.set_xlabel('Durée (minutes)');ax.set_xticks([10,30,50,70,80,130,150])
for xx,label,yy in [(30,'Q1 = 30',1.5),(50,'médiane = 50',.45),(70,'Q3 = 70',1.5),(10,'moustache = 10',.68),(80,'moustache = 80',.68),(150,'point isolé = 150',1.5)]:
    ax.annotate(label,xy=(xx,1),xytext=(xx,yy),ha='center',fontsize=9,
                arrowprops={'arrowstyle':'-','color':MUTED},color=NAVY)
ax.axvline(130,color=ORANGE,ls=':',lw=1);ax.text(130,.38,'limite 130',ha='center',fontsize=8,color=LABEL_ORANGE)
ax.set_title('Boîte Q1–Q3 ; moustaches jusqu’aux valeurs admissibles',loc='left',fontweight='bold')
finish(fig,'boxplot')
print('Vector illustrations generated:' ,len(list(DEST.glob('*.svg'))))
