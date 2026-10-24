"""Draw before/after controls from actual R runs, plus the shared learning route."""
from pathlib import Path
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'authoring/assets/v7/visuals'
PREVIEW=ROOT/'outputs/guidance_previews'
NAVY='#2B3180';ORANGE='#D96D12';PALE='#F3F5FC';INK='#1A1F4D'
plt.rcParams.update({'svg.fonttype':'path','font.family':'DejaVu Sans'})


def number(value,digits=0):
    if isinstance(value,str):return value
    return f'{value:,.{digits}f}'.replace(',',' ').replace('.',',')


def frame(height=150):
    fig=plt.figure(figsize=(505/72,height/72),facecolor='white')
    ax=fig.add_axes([0,0,1,1]);ax.set(xlim=(0,100),ylim=(0,100));ax.axis('off')
    ax.add_patch(FancyBboxPatch((.2,.3),99.6,99.4,boxstyle='round,pad=0,rounding_size=3',facecolor=PALE,edgecolor='none'))
    return fig,ax


def label(ax,x,y,s,size=11,color=INK,weight='normal',ha='center'):
    ax.text(x,y,s,ha=ha,va='center',fontsize=size,color=color,fontweight=weight)


def main():
    OUT.mkdir(parents=True,exist_ok=True);PREVIEW.mkdir(parents=True,exist_ok=True)
    facts=json.loads((ROOT/'authoring/assets/v7/experiences/facts.json').read_text())
    journey=json.loads((ROOT/'authoring/journey.json').read_text())
    records=[]
    # Metric, plain-language label, units, decimals, and the invariant to notice.
    cards={
      '00':('final_capital_UM','Capital après le gain','UM',0,'Le gain reste fixé à 500 UM.'),
      '01':('compounded_UM','Capital après les deux périodes','UM',0,'La seconde variation reste −5 % ; sa base change.'),
      '02':('preview_rows','Lignes affichées dans l’aperçu','lignes',0,'Le fichier importé garde 1 862 lignes ; la source en garde 1 860.'),
      '03':('changed_observation','Rang rendu incomplet dans la copie','observation',0,'Deux lignes restent isolées : celle-ci et l’ajout 1861.'),
      '04':('market','Marché choisi dans le graphique','marché',0,'Toujours 1 859 rendements ; seul le marché affiché change.'),
      '05':('requested_classes','Réglage du nombre de classes','suggestion breaks',0,'R choisit les bornes ; les statistiques et les 1 859 valeurs restent identiques.'),
      '06':('curves','Courbes affichées','courbes',0,'Les séries commencent à 100 ; les corrélations ne changent pas.'),
      '07':('final_capital_UM','Capital final du panier historique','UM',2,'Même capital initial et même historique ; la pondération change.'),
      '08':('VaR_UM','Seuil de perte historique','UM',2,'Le drawdown reste −21,75 % ; une VaR n’est pas un maximum.'),
      '09':('final_capital_UM','Capital après le choc inventé','UM',0,'CAC reste à −2 % ; le rendement du panier passe de −6 % à −9,2 %.'),
      '10':('q50_UM','Médiane des capitaux simulés','UM',2,'Toujours 5 000 chemins ; horizon 20 puis 40 observations, sans prévision.'),
      '11':('model_RMSE_points','Erreur RMSE du modèle','point de %',3,'Tests différents : 372 puis 558 lignes ; pas une comparaison à test égal.'),
      '12':('same60_final_UM','Capital de la ligne de contrôle 60 % CAC','UM',2,'Le lot de poids change ; la ligne 60 % conserve le même résultat.'),
    }
    for record in facts['records']:
        step=record['id'];key,title,unit,digits,foot=cards[step]
        fig,ax=frame(145)
        label(ax,50,91,title,12,weight='bold')
        for x,phase,color in [(25,'reference',NAVY),(75,'variant',ORANGE)]:
            label(ax,x,72,'RÉFÉRENCE' if phase=='reference' else 'VARIANTE',9,color,'bold')
            label(ax,x,48,number(record[phase][key],digits),24,color,'bold')
            label(ax,x,30,unit,10,color)
        ax.annotate('',(57,49),(43,49),arrowprops={'arrowstyle':'->','color':NAVY,'lw':2})
        label(ax,50,10,foot,9.5)
        name='experience_'+step;fig.savefig(OUT/(name+'.svg'));fig.savefig(PREVIEW/(name+'.png'),dpi=120);plt.close(fig)
        records.append({'key':name,'path':'authoring/assets/v7/visuals/'+name+'.svg','height':145,
                        'kind':'observed R before/after','facts_record':step,'metric':key})
    fig,ax=frame(155)
    for i,(letter,title,body) in enumerate([
      ('A','OUVRIR','projet → scripts → fichier'),('B','OBSERVER','bloc Bxx → résultat'),
      ('C','ESSAYER','un paramètre → comparer'),('D','REVENIR','restaurer → vérifier')]):
        x=3+i*25
        ax.add_patch(FancyBboxPatch((x,25),22,52,boxstyle='round,pad=.2,rounding_size=2',facecolor=NAVY if i%2==0 else '#07152F',edgecolor='none'))
        label(ax,x+11,67,letter,18,'white','bold');label(ax,x+11,46,title,9,'white','bold')
        # Two short lines stay readable at the final A4 width.
        parts=body.split(' → ');label(ax,x+11,14,' → '.join(parts[:2]),8.5)
    label(ax,50,91,'La même boucle dans les treize fichiers',12,weight='bold')
    name='guidance_loop';fig.savefig(OUT/(name+'.svg'));fig.savefig(PREVIEW/(name+'.png'),dpi=120);plt.close(fig)
    records.append({'key':name,'path':'authoring/assets/v7/visuals/'+name+'.svg','height':155,'kind':'teaching route'})
    fig,ax=frame(170)
    groups=[('00–03','Explorer\net fiabiliser'),('04–06','Décrire\net visualiser'),('07–09','Pondérer\net tester'),('10–12','Simuler, valider\net automatiser')]
    for i,(ids,title) in enumerate(groups):
        x=4+i*24
        ax.add_patch(FancyBboxPatch((x,30),21,45,boxstyle='round,pad=.2,rounding_size=2',facecolor=NAVY,edgecolor='none'))
        label(ax,x+10.5,64,ids,12,'white','bold');label(ax,x+10.5,45,title,9.5,'white')
    label(ax,50,90,'Une même chaîne de travail pour les deux profils',12,weight='bold')
    label(ax,50,16,'Data Science : données et validation   |   Finance : mesures et interprétation',9.5)
    name='guidance_profiles';fig.savefig(OUT/(name+'.svg'));fig.savefig(PREVIEW/(name+'.png'),dpi=120);plt.close(fig)
    records.append({'key':name,'path':'authoring/assets/v7/visuals/'+name+'.svg','height':170,'kind':'teaching route'})
    for name,title,panels in [
      ('guidance_save','Enregistrer garde la recette ; relancer calcule',[
       ('RÉFÉRENCE','capital :10000','résultat :10500'),
       ('FICHIER MODIFIÉ','capital écrit :12000','mémoire avant relance :10000'),
       ('APRÈS B03','capital :12000','résultat :12500')]),
      ('guidance_restart','Une session peut repartir de ses fichiers',[
       ('AVANT RESTART','objets en mémoire','recette + CSV sur disque'),
       ('APRÈS RESTART','mémoire vidée','recette + CSV conservés'),
       ('REPRISE','B01 → B02 → B03 → B04','résultat reconstruit')])]:
        fig,ax=frame(145);label(ax,50,91,title,12,weight='bold')
        for i,(header,line1,line2) in enumerate(panels):
            x=3+i*33
            ax.add_patch(FancyBboxPatch((x,25),29,48,boxstyle='round,pad=.2,rounding_size=2',facecolor=NAVY,edgecolor='none'))
            label(ax,x+14.5,61,header,9,'white','bold');label(ax,x+14.5,43,line1.replace(':',': '),9.5,'white')
            label(ax,x+14.5,13,line2.replace(':',': '),8.6)
        fig.savefig(OUT/(name+'.svg'));fig.savefig(PREVIEW/(name+'.png'),dpi=120);plt.close(fig)
        records.append({'key':name,'path':'authoring/assets/v7/visuals/'+name+'.svg','height':145,'kind':'teaching model'})
    assert journey['start_minutes']+sum(s['minutes'] for s in journey['steps'])+journey['final_minutes']==270
    (OUT/'sources.json').write_text(json.dumps({'figures':records,'facts_source':'authoring/assets/v7/experiences/facts.json','route_source':'authoring/journey.json','note':'Before/after values are measured from the actual R objects; these are diagrams, not app screenshots.'},ensure_ascii=False,indent=2)+'\n')
    print('17 vector figures built; 13 use the observed R experience facts.')


if __name__=='__main__':main()
