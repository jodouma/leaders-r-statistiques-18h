"""Resolve the guided playbook's facts/assets and balance readable PDF pages.

First run scripts/00..12, build_finance_manifest.py and visuals_finance.py.
Then python authoring/compose_finance.py ; build_pdfs.py content_finance.json.
"""
from pathlib import Path
from copy import deepcopy
from functools import lru_cache
from io import BytesIO
import importlib.util, json, re, shutil
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('pdf_engine',ROOT/'authoring/build_pdfs.py')
engine=importlib.util.module_from_spec(spec);spec.loader.exec_module(engine)
W,H=A4;M=45;WIDTH=W-2*M
manifest=json.loads((ROOT/'authoring/finance_manifest.json').read_text())
scripts={s['step']:s for s in manifest['scripts']}
mental=json.loads((ROOT/'authoring/assets/v6/mental/sources.json').read_text())['figures']
assets={f['key']:f for f in mental}
for alias,key in {'mental_project':'mental_files','pane_map':'mental_panes'}.items():assets[alias]=assets[key]

# These are genuine R-generated charts, retained with the reproducible sources.
rdir=ROOT/'authoring/assets/v6/r';rdir.mkdir(parents=True,exist_ok=True)
for p in sorted((ROOT/'outputs').glob('[0-9][0-9]/*.png')):
    key=p.relative_to(ROOT).as_posix();dest=rdir/(p.parent.name+'_'+p.name)
    shutil.copy2(p,dest);assets[key]={'path':dest.relative_to(ROOT).as_posix(),'kind':'actual R output'}

# UI captures are optional; never manufacture an application screenshot.
# When available, the capture manifest maps a key to a real cropped image.
screens=ROOT/'authoring/assets/v6/screens/provenance.json'
if screens.exists():
    loaded=json.loads(screens.read_text())
    for rec in loaded.get('captures',loaded.get('screens',[])):
        key=rec.get('asset_key',rec.get('key'))
        if key and rec.get('path'):assets[key]=rec
    for key,path in loaded.get('asset_key_to_path',{}).items():
        assets[key]={**loaded.get('assets',{}).get(key,{}),'path':path,'kind':'genuine RStudio capture'}

def text(t):return {'type':'text','text':t}
def note(label,t):return {'type':'callout','label':label,'text':t}
def fig(key,height=180,caption=''):
    return {'type':'figure','asset_key':key,'height':height,'caption':caption}

# Honest conceptual fallbacks. Actual captures, when present, supersede them.
for alias,key in {'run_block':'mental_route','edit_parameter':'mental_assignment',
                  'view_table':'mental_table','plots':'outputs/04/rendements.png'}.items():
    assets.setdefault(alias,assets[key])

def bind_block(block):
    b=deepcopy(block)
    if b.get('type')=='figurepair':
        for item in b['items']:
            item['path']=assets[item['asset_key']]['path']
    if b.get('type')=='figure':
        key=b.pop('asset_key');rec=assets[key];b['path']=rec['path'];b['asset_key']=key
        if rec.get('kind')=='actual R output':b.setdefault('height',220)
        if key in ('run_block','edit_parameter','pane_map','view_table') and rec.get('kind','').startswith('labelled'):
            b['caption']='Schéma de repérage · '+b.get('caption','')
    if b.get('run'):
        run=b['run'];script=scripts[run['script_id']]
        run['script_path']=script['path']
        run['block_refs']=[next(x for x in script['blocks'] if x['id']==ident) for ident in run['blocks']]
        labels=b.get('block_labels',[]);prefix=' ; '.join(labels)+'. '
        alt='; '.join(labels)+'. '
        for candidate in (prefix,alt):
            if b.get('text','').startswith(candidate):b['text']=b['text'][len(candidate):]
        b['text']='Run : '+' → '.join(run['blocks'])+'. '+b['text']
    if b.get('experiment'):
        exp=b['experiment'];exp['manifest']=scripts[exp['script_id']]['experiment']
    return b

@lru_cache(None)
def block_height(serialized):
    c=canvas.Canvas(BytesIO(),pagesize=A4)
    return 1000-engine.block(c,json.loads(serialized),M,1000,WIDTH)
def height(b):return block_height(json.dumps(b,ensure_ascii=False,sort_keys=True))
@lru_cache(None)
def capacity(title,kicker):
    c=canvas.Canvas(BytesIO(),pagesize=A4)
    return engine.draw_page_header(c,{},dict(title=title,kicker=kicker),1,1,W,H,M)-64

def balance(pages,section):
    blocks=[]
    for p in pages:
        title=p['title'];blocks.append({'type':'section','text':title,'_origin':title,'_source':p['id']})
        for block in p.get('blocks',[]):
            b=bind_block(block);b['_origin']=title;b['_source']=p['id'];blocks.append(b)
    n=len(blocks);best={n:((0,0),[])}
    for i in range(n-1,-1,-1):
        options=[]
        for j in range(i+1,n+1):
            if blocks[j-1]['type']=='section':continue
            segment=deepcopy(blocks[i:j]);title=segment[0]['_origin']
            if segment[0]['type']=='section':segment=segment[1:]
            used=sum(height(b) for b in segment);cap=capacity(title,section)
            if used>cap or j not in best:continue
            cost_tail,tail=best[j]
            score=(cost_tail[0]+1,cost_tail[1]+(cap-used)**2)
            options.append((score,[{'title':title,'kicker':section,'blocks':segment}]+tail))
        if not options:raise RuntimeError('Cannot place '+str(blocks[i])[:180])
        best[i]=min(options,key=lambda x:x[0])
    return best[0][1]

source=json.loads((ROOT/'authoring/v6_playbook.json').read_text())
main={k:deepcopy(v) for k,v in source.items() if k in ('title','subtitle','author','filename')}
main['pages']=[];main['pages'].append(deepcopy(source['pages'][0]))
route=deepcopy(source['pages'][1]);route['blocks'].insert(1,fig('mental_route',145,'La méthode reste la même ; les questions financières grandissent.'))
main['pages'].append({**route,'blocks':[bind_block(b) for b in route['blocks']]})
index={'id':'v6.printed_map','title':'Votre carte : du premier Run au rapport','kicker':'RETROUVER UNE ÉTAPE',
       'blocks':[text('Commencer par les gestes RStudio des pages suivantes. Ensuite, suivre les scripts dans l’ordre ; les explorations 10–12 sont facultatives.'),
                 {'type':'table','headers':['Script','Question pratique','Page'],'rows':[
                     ['00','Lire, lancer et retrouver un objet','?'],['01','Comprendre gain et pourcentage','?'],
                     ['02','Lire un tableau historique réel','?'],['03','Contrôler la qualité des données','?'],
                     ['04','Passer du niveau au rendement','?'],['05','Décrire centre et dispersion','?'],
                     ['06','Comparer des évolutions','?'],['07','Composer un panier pédagogique','?'],
                     ['08','Lire VaR et drawdown','?'],['09','Tester un choc inventé','?'],
                     ['10','Explorer des simulations','?'],['11','Tester une relation linéaire','?'],
                     ['12','Automatiser un rapport local','?']],'widths':[55,395,55]},
                 note('Votre trace','À chaque essai : noter le paramètre changé, prévoir son effet, observer le résultat et expliquer la différence. Aucun code complet à recopier depuis le PDF.')]}
main['pages'].append(index)

# Installation stays self-contained. Adjacent gestures flow across pages, avoiding
# a half-empty page for a single screenshot followed by its detached explanation.
setup=[p for p in source['pages'][2:] if not re.match(r'v6\.\d\d\.',p['id']) and p['id'] not in ('v6.checkpoint','v6.final','v6.troubleshoot')]
gesture_pages=[]
for p in setup:
    q=deepcopy(p)
    # Keep platform provenance visible once instead of relabelling every figure.
    if p['id']=='v6.panes' and screens.exists():
        q['blocks'].append(note('À propos des captures','Les captures montrent une vraie session de RStudio Server sous Linux, ouverte dans un navigateur sur macOS. Les zones et commandes illustrées sont communes ; les raccourcis indiqués dans ce guide sont ceux de Windows.'))
    if p['id'] in ('v6.panes','v6.run','v6.edit','v6.recovery'):
        gesture_pages.append(q)
        continue
    q['blocks']=[bind_block(b) for b in q['blocks']]
    if sum(height(b) for b in q['blocks'])<=capacity(q['title'],q.get('kicker','')):main['pages'].append(q)
    else:main['pages']+=balance([q],p.get('kicker','DÉMARRER'))
main['pages']+=balance(gesture_pages,'LES GESTES RSTUDIO · UNE FOIS POUR TOUTES')

starts={}
for step in range(13):
    key=f'{step:02}';pages=[p for p in source['pages'] if p['id'].startswith('v6.'+key+'.')]
    starts[key]=len(main['pages'])+1
    main['pages']+=balance(pages,('SOCLE' if step<=6 else 'ANALYSE' if step<=9 else 'EXPLORATION FACULTATIVE')+' · SCRIPT '+key)
    if step==9:
        p=next(p for p in source['pages'] if p['id']=='v6.checkpoint');main['pages']+=balance([p],'FAIRE LE POINT')
for row in index['blocks'][1]['rows']:row[-1]=str(starts[row[0]])
for ident in ('v6.final','v6.troubleshoot'):
    p=next(p for p in source['pages'] if p['id']==ident);main['pages']+=balance([p],'GARDER LA MÉTHODE')

memo=json.loads((ROOT/'authoring/v6_reperes.json').read_text())
memo={k:deepcopy(v) for k,v in memo.items() if k in ('title','subtitle','author','filename','pages')}
memo['pages']=balance(memo['pages'],'MÉMO · UN REPÈRE À LA FOIS')

refs=source.get('source_refs',[])
rows=[]
for ref in refs:
    if isinstance(ref,str):rows.append(['Documentation',ref])
    else:rows.append([ref.get('title',ref.get('label','Source')),ref.get('url','')])
sources={'filename':'03_sources.pdf','title':'Sources et conventions · Noria Gestion','pages':[
 {'title':'Ce qui est réel, ce qui est pédagogique','kicker':'DONNÉES ET MÉTHODES','blocks':[
  text('Noria Gestion est fictive. Les niveaux historiques DAX, SMI, CAC et FTSE proviennent du jeu EuStockMarkets distribué avec le paquet datasets de R. La notice R crédite Erste Bank AG, Vienne, Autriche.'),
  {'type':'table','headers':['Élément','Convention'],'rows':[
   ['Historique réel','1991–1998 ; 1 860 observations et 4 indices. Les weekends et jours fériés sont omis dans l’ordre fourni.'],
   ['Entraînement au contrôle','Une copie exacte et une ligne incomplète ont été ajoutées volontairement. Elles sont décrites dans data/sources.json.'],
   ['Rendements','1 860 niveaux donnent 1 859 variations voisines. Une absence interne doit être examinée avant l’analyse ; aucun calendrier n’est inventé.'],
   ['Panier pédagogique','Poids rééquilibrés à chaque observation ; capital en UM. Séries utilisées telles quelles, sans traitement supplémentaire du change, des frais ou des dividendes.'],
   ['Scénarios et modèles','Les mini-exemples et le choc sont inventés ; bootstrap et régression sont des modèles sous hypothèses, pas des garanties futures.']]},
  note('Relire une conclusion','Un indice n’est pas un placement directement achetable. La VaR n’est pas une perte maximale, et une association simultanée n’est pas une prévision du lendemain.') ]},
 {'title':'Documentation officielle','kicker':'SOURCES PRIMAIRES','blocks':[
   text('Sources vérifiées le 24 octobre 2026. Les liens servent à approfondir ; le parcours ne dépend pas de leur ouverture pendant la séance.'),
   {'type':'table','headers':['Repère','Source'], 'rows':rows[:7],'widths':[155,350]}]},
 {'title':'Crédits, fichiers et réutilisation','kicker':'PROVENANCE','blocks':[
   {'type':'table','headers':['Repère','Source'],'rows':rows[7:],'widths':[155,350]},
   text('Données : les CSV éditables, la reconstruction et les notices d’origine sont conservés dans data/ et authoring/exporter_donnees.R. Les notices du paquet datasets, de R et les textes GPL-2/GPL-3 sont dans data/licenses/.'),
   text('Identité : logos Leaders University approuvés par Youssef Douma. Logo R : R Foundation, sous CC BY-SA 4.0 ou GPL-2, source r-project.org/logo/. Polices Inter et Plus Jakarta Sans : Google Fonts, SIL Open Font License ; notices incluses.'),
   text('Couverture : illustration décorative originale créée avec image_gen pour le cours, titre et logos composés séparément. Diagrammes : figures vectorielles pédagogiques. Graphiques : véritables sorties des scripts R. Aucune image générée ne remplace une capture de RStudio.'),
   note('Captures de l’application', 'Les captures éventuelles sont des vues réellement réalisées pendant le parcours. Le système, la version et le geste sont consignés dans authoring/assets/v6/screens/provenance.json ; elles ne prétendent pas montrer une installation Windows testée ici.' if screens.exists() else 'Cette édition illustre les gestes par des schémas de repérage et la documentation officielle Posit. Les graphiques et tableaux sont issus des exécutions réelles de R ; aucune interface simulée n’est présentée comme une capture.') ]}]}

# Preserve traceability from the semantic guide to the exact shipped code blocks.
content={'documents':[main,memo,sources]}
(ROOT/'authoring/content_finance.json').write_text(json.dumps(content,ensure_ascii=False,indent=2)+'\n')
used=set()
for d in content['documents']:
    for p in d['pages']:
        for b in p.get('blocks',[]):
            if b['type']=='figure':used.add(b['path'])
            if b['type']=='figurepair':used.update(i['path'] for i in b['items'])
receipt={'documents':{d['filename']:len(d['pages']) for d in content['documents']},'script_pages':starts,'assets_used':sorted(used),'has_real_ui':screens.exists()}
(ROOT/'outputs/composition_receipt.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(receipt,ensure_ascii=False,indent=2))
