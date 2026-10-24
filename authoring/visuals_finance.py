"""Build exact vector mental models for the guided finance playbook.

These are labelled teaching examples; empirical charts are produced by R.
Run from anywhere: python authoring/visuals_finance.py [--data CSV]
"""
from pathlib import Path
import argparse, csv, json, os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle

ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'authoring/assets/v6/mental'
PREVIEW=ROOT/'outputs/mental_previews'
NAVY='#2B3180';DARK='#07152F';ORANGE='#FF9A3C';PALE='#F3F5FC';INK='#1A1F4D';BLUE='#4E73FF'
plt.rcParams.update({'svg.fonttype':'path','font.family':'DejaVu Sans','font.size':11})
records=[]

def canvas(height=190):
    fig=plt.figure(figsize=(505/72,height/72),facecolor='white')
    ax=fig.add_axes([0,0,1,1]);ax.set(xlim=(0,100),ylim=(0,100));ax.axis('off')
    ax.add_patch(FancyBboxPatch((.3,.3),99.4,99.4,boxstyle='round,pad=0,rounding_size=3',facecolor=PALE,edgecolor='none'))
    return fig,ax
def txt(ax,x,y,t,size=11,color=INK,weight='normal',ha='center'):
    ax.text(x,y,t,ha=ha,va='center',fontsize=size,color=color,fontweight=weight)
def box(ax,x,y,w,h,t,color=NAVY,size=12):
    ax.add_patch(FancyBboxPatch((x,y),w,h,boxstyle='round,pad=.4,rounding_size=2',facecolor=color,edgecolor='none'))
    txt(ax,x+w/2,y+h/2,t,size,'white','bold')
def arrow(ax,x1,y1,x2,y2):
    ax.annotate('',(x2,y2),(x1,y1),arrowprops={'arrowstyle':'->','color':ORANGE,'lw':2})
def save(fig,name,alt):
    OUT.mkdir(parents=True,exist_ok=True);PREVIEW.mkdir(parents=True,exist_ok=True)
    fig.savefig(OUT/(name+'.svg'),format='svg');fig.savefig(PREVIEW/(name+'.png'),dpi=110)
    records.append({'key':name,'path':'authoring/assets/v6/mental/'+name+'.svg','height':round(fig.get_figheight()*72),'alt':alt,'kind':'labelled teaching mental model'})
    plt.close(fig)
def flow(name,labels,caption,height=160):
    fig,ax=canvas(height);n=len(labels);w=84/n;gap=(90-w*n)/(n-1) if n>1 else 0
    for i,label in enumerate(labels):
        x=5+i*(w+gap);box(ax,x,36,w,43,label,NAVY if i%2==0 else DARK,10)
        if i<n-1:arrow(ax,x+w+1,58,x+w+gap-1,58)
    txt(ax,50,15,caption,10);save(fig,name,caption)

def main():
    p=argparse.ArgumentParser();p.add_argument('--data',type=Path,default=ROOT/'data/marches_source.csv');args=p.parse_args()
    # Assignment: the console display is deliberately distinct from storage.
    fig,ax=canvas(180);box(ax,6,36,24,39,'3',ORANGE,25);arrow(ax,33,56,49,56)
    box(ax,52,29,39,53,'x\n3',NAVY,22);txt(ax,18,21,'la valeur',10);txt(ax,72,15,'un nom pour la retrouver',10)
    txt(ax,50,88,'x <- 3 : conserver la valeur 3 sous le nom x',12,weight='bold')
    save(fig,'mental_assignment','Une affectation conserve une valeur ; print(x) permet ensuite de la voir.')

    fig,ax=canvas(190)
    for i in range(100):
        row,col=divmod(i,20);ax.add_patch(Rectangle((6+col*3,27+row*10),2.6,8,facecolor=ORANGE if i<5 else '#DDE2F4',edgecolor='none'))
    txt(ax,80,59,'5 %',27,NAVY,'bold');txt(ax,80,36,'5 sur 100',11)
    txt(ax,50,88,'5 % = 0,05',15,weight='bold');txt(ax,50,12,'10 000 × 0,05 = 500 ; capital final = 10 500 UM',11)
    assert 10000*.05==500
    save(fig,'mental_percentage','Cinq cases sur cent représentent 5 %, soit 500 sur 10 000 unités monétaires.')

    with args.data.open(newline='') as f:rows=list(csv.DictReader(f))
    assert len(rows)==1860 and all(k in rows[0] for k in ('observation','DAX','SMI','CAC','FTSE'))
    fig,ax=canvas(190);headers=['observation','DAX','CAC'];xx=[7,36,68];ww=[27,30,25]
    for x,w,h in zip(xx,ww,headers):box(ax,x,69,w,17,h,NAVY,11)
    for j,row in enumerate(rows[:3]):
        for x,w,h in zip(xx,ww,headers):
            ax.add_patch(Rectangle((x,47-j*17),w,16,facecolor='white' if j%2==0 else '#E4E9FC',edgecolor='none'))
            txt(ax,x+w/2,55-j*17,str(row[h]),11)
    txt(ax,50,9,'Une ligne = une observation ; une colonne = une information.',10)
    save(fig,'mental_table','Trois premières observations réelles : les niveaux d’indice ont des échelles différentes.')

    flow('mental_cleaning',['1 862 lignes\nbrutes','1 861 lignes\nuniques','1 860 complètes\n+ 1 isolée'],'Le doublon exact part ; la valeur absente reste à vérifier.',180)
    fig,ax=canvas(180);box(ax,6,37,25,36,'100',NAVY,23);arrow(ax,34,55,64,55);box(ax,68,37,25,36,'102',NAVY,23)
    txt(ax,49,79,'+ 2 points',13,weight='bold');txt(ax,50,18,'(102 − 100) / 100 = 0,02 = 2 %',14,NAVY,'bold')
    save(fig,'mental_return','Mini-exemple : rapporter le gain de 2 au niveau initial de 100 donne 2 %.')

    fig,ax=canvas(185)
    for x,value in [(5,'10 000'),(38,'10 500'),(71,'9 975')]:box(ax,x,38,24,35,value,NAVY,19)
    arrow(ax,30,55,36,55);arrow(ax,63,55,69,55)
    txt(ax,33,83,'+ 5 %',12);txt(ax,67,83,'− 5 %',12)
    txt(ax,50,17,'10 000 × 1,05 × 0,95 = 9 975 ; au total : − 0,25 %',11,NAVY,'bold')
    assert abs(10000*1.05*.95-9975)<1e-10
    save(fig,'mental_compounding','Les pourcentages successifs s’appliquent à un capital qui change.')

    fig,ax=canvas(190)
    for x0,vals,label in [(6,[1,1,1],'A : 1 %, 1 %, 1 %'),(55,[-2,1,4],'B : −2 %, 1 %, 4 %')]:
        ax.plot([x0,x0+38],[43,43],color='#B1BADA',lw=1)
        for j,v in enumerate(vals):
            x=x0+5+j*11;ax.add_patch(Rectangle((x,min(43,43+v*8)),6,abs(v)*8,facecolor=BLUE if v>=0 else ORANGE,edgecolor='none'))
        txt(ax,x0+19,15,label,10);txt(ax,x0+19,88,'moyenne = 1 %',12,NAVY,'bold')
    save(fig,'mental_spread','Trois rendements inventés : la même moyenne peut cacher des fluctuations différentes.')

    flow('mental_normalize',['niveau initial\n200','nouveau niveau\n250','250 / 200 × 100\n= 125'],'Base 100 : comparer une évolution, pas les niveaux bruts.',175)
    fig,ax=canvas(185)
    for i in range(10):box(ax,6+i*8.8,53,7.5,23,'C' if i<6 else 'D',NAVY if i<6 else ORANGE,13)
    txt(ax,50,89,'60 % CAC + 40 % DAX',15,NAVY,'bold');txt(ax,50,34,'Exemple inventé : CAC +2 % ; DAX −1 %',11)
    txt(ax,50,14,'0,60 × 2 % + 0,40 × (−1 %) = +0,8 %',13,NAVY,'bold')
    save(fig,'mental_weights','Dix parts : six CAC et quatre DAX. Les poids servent à calculer le rendement du panier.')

    fig,ax=canvas(185)
    for i in range(100):
        row,col=divmod(i,20);ax.add_patch(Rectangle((6+col*3,26+row*10),2.6,8,facecolor=ORANGE if i>=95 else NAVY,edgecolor='none'))
    txt(ax,80,65,'95 %',23,NAVY,'bold');txt(ax,80,41,'≈ 5 %\nau-delà',11,ORANGE,'bold')
    txt(ax,50,88,'Lire un seuil historique de perte',13,NAVY,'bold');txt(ax,50,11,'Image de lecture : ce seuil n’est pas une perte maximale garantie.',10)
    save(fig,'mental_var','La VaR historique situe un seuil ; certaines pertes observées le dépassent.')

    fig,ax=canvas(190);xs=[9,48,88];ys=[35,75,31]
    ax.plot(xs,ys,color=NAVY,lw=3,marker='o',markersize=8)
    for x,y,v in zip(xs,ys,[100,110,99]):txt(ax,x,y+10,str(v),14,NAVY,'bold')
    ax.plot([48,88],[75,75],color=ORANGE,lw=1.5,ls='--');arrow(ax,88,71,88,35)
    txt(ax,50,8,'Du sommet 110 au creux 99 : 11 / 110 = 10 % de baisse',11)
    save(fig,'mental_drawdown','Le drawdown compare la valeur à son sommet précédent, en incluant le capital initial.')

    flow('mental_stress',['CAC : −2 %\npoids 60 %','DAX : −12 %\npoids 40 %','panier : −6 %\n10 000 → 9 400 UM'],'Un choc inventé mesure une sensibilité ; il ne prédit pas demain.',180)
    flow('mental_bootstrap',['rendements\nhistoriques','tirer avec remise\n20 observations','recommencer\n5 000 fois'],'On explore des scénarios sous une hypothèse de répétition indépendante.',180)
    fig,ax=canvas(175);box(ax,6,43,69,29,'80 % : ajuster la relation',NAVY,13);box(ax,76,43,18,29,'20 %\ntester',ORANGE,12)
    txt(ax,50,88,'L’ordre des observations est conservé',13,NAVY,'bold');arrow(ax,8,29,92,29)
    txt(ax,50,12,'CAC et DAX de la même observation : association, pas prévision suivante.',9.7)
    save(fig,'mental_regression_split','Apprendre sur le début et évaluer sur la fin ; une relation contemporaine n’est pas une prévision.')
    fig,ax=canvas(190)
    ax.plot([13,92],[18,18],color=INK,lw=1);ax.plot([13,13],[18,86],color=INK,lw=1)
    xs=[22,31,37,44,50,58,63,69,77,84];ys=[32,30,45,39,55,49,64,61,70,80]
    ax.scatter(xs,ys,s=45,color=BLUE,zorder=3);ax.plot([20,86],[27,78],color=ORANGE,lw=2)
    txt(ax,53,7,'DAX, même observation',10);txt(ax,54,94,'Chaque point associe deux rendements ; la droite résume.',11,NAVY,'bold')
    ax.text(4,54,'CAC',rotation=90,ha='center',va='center',fontsize=10,color=INK)
    save(fig,'mental_regression','Schéma illustratif de lecture d’une régression ; les vrais points et coefficients sont calculés dans R.')
    flow('mental_function',['un chemin\nCSV entre','lire → contrôler\n→ calculer','un bilan\nsort'],'Même recette, entrée différente : la fonction réutilise la méthode.',180)
    flow('mental_report',['plusieurs\npondérations','répéter les\nmêmes calculs','un rapport\nHTML local'],'Les résultats et les hypothèses restent ensemble dans un document relisible.',180)
    flow('mental_route',['ouvrir le\nscript fourni','Run : une ligne\nou un bloc','observer puis\nmodifier un paramètre'],'Le code est prêt ; votre travail consiste à interpréter et expérimenter.',170)
    fig,ax=canvas(200)
    for x,y,w,h,label in [(5,49,51,43,'Source\ncode déjà prêt'),(5,5,51,39,'Console\ncommandes et réponses'),(59,49,36,43,'Environment\nobjets en mémoire'),(59,5,36,39,'Files / Plots\nfichiers et graphiques')]:box(ax,x,y,w,h,label,NAVY if y>45 else DARK,12)
    save(fig,'mental_panes','Schéma de repérage des quatre zones usuelles de RStudio ; ce n’est pas une capture d’écran.')
    flow('mental_files',['course.Rproj\nouvre le projet','scripts/ + data/\nentrées du cours','outputs/\nvotre travail produit'],'Extraire tout le ZIP et conserver les dossiers ensemble.',160)
    (OUT/'sources.json').write_text(json.dumps({'figures':records,'source_data':'data/marches_source.csv','facts_checked':{'source_rows':1860,'gain_example':500,'compound_example':9975},'note':'Empirical charts are generated by the R scripts. These mental models are explicitly illustrative except the three-row source-table excerpt.'},ensure_ascii=False,indent=2))
    print(json.dumps({'figures':len(records),'folder':str(OUT)},indent=2))
if __name__=='__main__':main()
