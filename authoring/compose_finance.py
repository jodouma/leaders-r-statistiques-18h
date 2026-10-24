"""Compose the continuous guided route; audit bottom whitespace on every build.

Facts, screenshots and diagrams stay traceable to the actual scripts. The
composer never shrinks reading text to fill a page. It enlarges readable figures
and uses chapter-specific checks to make otherwise empty lower areas useful.
"""
from pathlib import Path
from copy import deepcopy
from functools import lru_cache
from io import BytesIO
from urllib.parse import urlparse
import importlib.util,json,re,shutil
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('pdf_engine',ROOT/'authoring/build_pdfs.py')
engine=importlib.util.module_from_spec(spec);spec.loader.exec_module(engine)
W,H=A4;M=45;WIDTH=W-2*M
manifest=json.loads((ROOT/'authoring/finance_manifest.json').read_text())
scripts={s['step']:s for s in manifest['scripts']}
journey=json.loads((ROOT/'authoring/journey.json').read_text())
steps={s['id']:s for s in journey['steps']}
experience=json.loads((ROOT/'authoring/assets/v7/experiences/facts.json').read_text())
experiences={s['id']:s for s in experience['records']}
assets={}
for name in ['v6/mental','v7/visuals']:
    for rec in json.loads((ROOT/'authoring/assets'/name/'sources.json').read_text())['figures']:assets[rec['key']]=rec
for alias,key in {'mental_project':'mental_files','pane_map':'mental_panes'}.items():assets[alias]=assets[key]
for name in ['v6','v7']:
    provenance=ROOT/'authoring/assets'/name/'screens/provenance.json'
    if provenance.exists():
        loaded=json.loads(provenance.read_text())
        for key,path in loaded['asset_key_to_path'].items():assets[key]={**loaded['assets'][key],'path':path,'kind':'genuine RStudio capture'}
rdir=ROOT/'authoring/assets/v6/r';rdir.mkdir(parents=True,exist_ok=True)
for p in sorted((ROOT/'outputs').glob('[0-9][0-9]/*.png')):
    dest=rdir/(p.parent.name+'_'+p.name);shutil.copy2(p,dest)
    assets[p.relative_to(ROOT).as_posix()]={'path':dest.relative_to(ROOT).as_posix(),'kind':'actual R output'}

def text(s):return {'type':'text','text':s}
def note(label,s):return {'type':'callout','label':label,'text':s}
def fig(key,height=180,caption=''):return {'type':'figure','asset_key':key,'height':height,'caption':caption}
def bind(block):
    b=deepcopy(block)
    if b['type']=='figurepair':
        for item in b['items']:item['path']=assets[item['asset_key']]['path']
    if b['type']=='figure':b['path']=assets[b['asset_key']]['path']
    if b.get('run'):
        r=b['run'];s=scripts[r['script_id']];r['script_path']=s['path']
        r['block_refs']=[next(v for v in s['blocks'] if v['id']==i) for i in r['blocks']]
        for separator in [' ; ','; ']:
            prefix=separator.join(b.get('block_labels',[]))+'. '
            if b.get('text','').startswith(prefix):b['text']=b['text'][len(prefix):]
        b['text']='Lancer '+' → '.join(r['blocks'])+' (Ctrl+Alt+T pour chaque bloc). '+b.get('text','')
    return b

def expand(block):
    if not block.get('experiment'):return [bind(block)]
    ident=block['experiment']['script_id'];j=steps[ident];f=experiences[ident]
    run=' → '.join(j['rerun_blocks'])
    return [
      {'type':'table','headers':['C · Essayer','Dans '+Path(j['path']).name], 'widths':[92,WIDTH-92],
       'rows':[['Revenir au code','Revenir à RStudio ; cliquer l’onglet '+Path(j['path']).name+' dans Source.'],
               ['Modifier',j['experiment_block']+' : '+f['variant_line']+'\nPuis Ctrl+S.'],
               ['Relancer',run+' : choisir chaque bloc, puis Ctrl+Alt+T.'],
               ['Observer',j['observation_area']+'. '+j['expected_variant']]],
       'experiment':block['experiment'],'_phase':'C'},
      bind(fig('experience_'+ident,145,'Contrôle visuel : valeurs réellement obtenues avec le script fourni, avant et après la modification.')),
      {**note('D · Restaurer avant de continuer','Revenir à RStudio → onglet '+Path(j['path']).name+'.\n'+f['default_line']+'\nCtrl+S ; relancer '+run+'. '+('Dans le navigateur, Ctrl+R après B05. ' if ident=='12' else '')+j['expected_base']), '_phase':'D'}]

@lru_cache(None)
def height(serialized):
    c=canvas.Canvas(BytesIO(),pagesize=A4)
    return 1000-engine.block(c,json.loads(serialized),M,1000,WIDTH)
def bh(b):return height(json.dumps(b,ensure_ascii=False,sort_keys=True))
@lru_cache(None)
def capacity(title,kicker):
    c=canvas.Canvas(BytesIO(),pagesize=A4)
    return engine.draw_page_header(c,{},dict(title=title,kicker=kicker),1,1,W,H,M)-86

def balance(pages,kicker):
    blocks=[]
    for p in pages:
        title=p['title'];blocks.append({'type':'section','text':title,'_origin':title,'_source':p['id']})
        for b in p.get('blocks',[]):
            for item in expand(b):item['_origin']=title;item['_source']=p['id'];blocks.append(item)
    n=len(blocks);best={n:((0,0),[])}
    for i in range(n-1,-1,-1):
        options=[]
        for end in range(i+1,n+1):
            if blocks[end-1]['type']=='section':continue
            segment=deepcopy(blocks[i:end]);title=segment[0]['_origin']
            if segment[0]['type']=='section':segment=segment[1:]
            used=sum(bh(b) for b in segment);cap=capacity(title,kicker)
            if used>cap or end not in best:continue
            tailcost,tail=best[end];cost=(tailcost[0]+1,tailcost[1]+(cap-used)**2)
            options.append((cost,[{'title':title,'kicker':kicker,'blocks':segment}]+tail))
        if not options:raise RuntimeError('A block cannot fit: '+str(blocks[i])[:220])
        best[i]=min(options,key=lambda item:item[0])
    return best[0][1]

def bottom(p):
    return capacity(p['title'],p.get('kicker',''))+86-sum(bh(b) for b in p['blocks'])

def polish(pages,step=None):
    """Use space for legible figures and distinct, relevant reading checks.

    A check never tells students to run future blocks. Executable actions remain
    in the ordered reference/experiment/restore stream.
    """
    if step:
        j=steps[step]
        pool=[{'type':'learning_check','question':j['spot_check'],'answer':j['spot_check_answer']},
              note('Repère du résultat de référence',j['expected_base']),
              note('Si un message vous bloque',j['common_blocker']),
              note('Lire une preuve',j['recap']+' La trace correspondante est '+j['output_path']+'.'),
              {'type':'table','headers':['Paramètre de cette expérience','Valeur de référence'],'rows':[[j['parameter'],experiences[step]['default_line']]],'widths':[210,WIDTH-210]}]
        last_only=[note('À raconter avec votre trace','À partir de votre trace avant/après : '+' '.join(j['activity_tasks']))]
        if step=='03':last_only.append({'type':'table','headers':['Support','Pendant les essais'],'widths':[155,350],'rows':[
            ['data/marches_brut.csv','Fichier fourni : il reste intact.'],['demo','Copie en mémoire : la ligne choisie reçoit NA.'],['outputs/03/','Exports du contrôle de référence : B04 les reconstruit.']]})
        if step=='01':
            pool.extend([
              {'type':'learning_check','question':'Sur votre feuille : 10 % de 2000 UM donnent quel gain ?','answer':'200 UM, avec le taux 0.10 dans R.','_allowed_source':['v6.01.percentage']},
              {'type':'table','headers':['Même recul de 5 %','Base × facteur = capital après recul'],'widths':[170,335],
               'rows':[['Référence','10500 × 0.95 = 9975 UM'],['Variante','11000 × 0.95 = 10450 UM']], '_allowed_source':['v6.01.compound']}])
        if step=='04':pool.append({'type':'formula','latex':r'\frac{1750.5-1772.8}{1772.8}\times 100\approx -1.258\%',
                                    'caption':'Pour la première paire réelle du CAC : rapporter le changement à l’ancien niveau, puis multiplier par 100 pour lire le pourcentage.'})
    else:
        pool=[];last_only=[]
    for p in pages:
        # Expand empirical graphs and real screenshots to their natural A4 width.
        for b in p['blocks']:
            room=bottom(p)-160
            if room<=0:break
            if b['type']=='figure' and Path(b['path']).suffix.lower()!='.svg':
                iw,ih=ImageReader(str(ROOT/b['path'])).getSize();natural=WIDTH*ih/iw
                before=bh(b);candidate=deepcopy(b);candidate['height']=min(natural,b.get('height',180)+room,390)
                if bh(candidate)>before:b.update(candidate)
    # Give useful support to the sparsest pages first, rather than consuming
    # every chapter check on an already dense introductory page.
    for p in sorted(pages,key=bottom,reverse=True):
        candidates=pool+(last_only if p is pages[-1] else [])
        while bottom(p)>170 and candidates:
            room=bottom(p)-86
            present={b.get('_source') for b in p['blocks']}
            available=[b for b in candidates if bh(b)<=room and (not b.get('_allowed_source') or present.intersection(b['_allowed_source']))]
            candidate=max(available,key=bh) if available else None
            if candidate is None:break
            candidates.remove(candidate)
            if candidate in pool:pool.remove(candidate)
            if candidate in last_only:last_only.remove(candidate)
            pos=len(p['blocks'])-1 if p['blocks'] and p['blocks'][-1]['type']=='next_step' else len(p['blocks'])
            p['blocks'].insert(pos,deepcopy(candidate))
    return pages

def polish_topics(pages,supports):
    for p in sorted(pages,key=bottom,reverse=True):
        ids=list(dict.fromkeys(b.get('_source') for b in p['blocks']))
        while bottom(p)>170:
            candidates=[(ident,b) for ident in ids for b in supports.get(ident,[]) if bh(b)<=bottom(p)-86]
            if not candidates:break
            ident,b=max(candidates,key=lambda v:bh(v[1]));supports[ident].remove(b);p['blocks'].append(deepcopy(b))
    return pages

def polish_setup(pages):
    return polish_topics(pages,{
      'v6.setup_project':[bind(fig('mental_files',140,'Le dossier extrait reste entier : projet, scripts et données ensemble.'))],
      'v6.panes':[{'type':'learning_check','question':'Où se trouvent un objet et un fichier enregistré ?','answer':'L’objet est dans Environment ; le fichier est dans Files. Un redémarrage vide la mémoire et conserve les fichiers.'}],
      'v6.run':[bind(fig('guidance_profiles',165,'Les gestes restent identiques ; la question et les données grandissent.')),
                {'type':'learning_check','question':'B01 prépare les outils sans afficher 300. Est-ce un échec ?','answer':'Non : le calcul 300 est dans B02. L’invite > signifie que R attend le prochain bloc.'}],
      'v6.edit':[bind(fig('guidance_save',145)),
                 {'type':'learning_check','question':'Ctrl+S change-t-il déjà le résultat en mémoire ?','answer':'Non : il enregistre la recette. Le bloc choisi avec Run Code Section recalcule ensuite le résultat.'}],
      'v6.recovery':[bind(fig('guidance_restart',145,'À 00, les blocs B01 à B04 reconstruisent le calcul et le CSV après un redémarrage.'))]
    })

source=json.loads((ROOT/'authoring/v6_playbook.json').read_text())
main={k:deepcopy(v) for k,v in source.items() if k in ['title','subtitle','author','filename']}
main.update(page_navigation=True,toc_page=3,max_body_bottom=175,enforce_density=True)
main['pages']=[deepcopy(source['pages'][0])]
route=deepcopy(source['pages'][1])
route['blocks']=[b for b in route['blocks'] if b['type']!='table']
route['blocks'].insert(1,fig('guidance_loop',155,'Les mêmes quatre gestes reviennent dans les treize étapes.'))
route['blocks'].insert(2,{'type':'transfer','ds':'Construire une chaîne fiable : contrôler les données, lire les graphiques, valider un modèle et reproduire les calculs.','finance':'Lire les marchés, relier les poids au rendement et au risque, puis défendre une interprétation chiffrée.'})
main['pages']+=balance([route],'LA MISSION COMMUNE')
index_position=len(main['pages']);main['toc_page']=index_position+1
index={'id':'v7.index','title':'Votre parcours guidé : 4 h 30','kicker':'UN MÊME CHEMIN POUR LES DEUX PROFILS','blocks':[
 text('Un budget de travail planifié : lire les images, lancer les blocs, comparer, expliquer et restaurer. Hors installation et pauses ; votre rythme peut demander plus de temps.'),
 {'type':'table','headers':['Étape','Ce que vous faites','Minutes','Page'],'widths':[45,330,60,70],
  'rows':[[j['id'],j['question'],str(j['minutes']),'00'] for j in journey['steps']]},
 note('Les 270 minutes','15 min de prise en main + 240 min d’activités guidées + 15 min de synthèse. Les treize fichiers suivent le même chemin ; les dérivations mathématiques avancées restent facultatives.') ]}
main['pages'].append({**index,'blocks':[bind(b) for b in index['blocks']]})
setup=[p for p in source['pages'][2:] if not re.match(r'v6\.\d\d\.',p['id']) and p['id'] not in ['v6.checkpoint','v6.final','v6.troubleshoot']]
# Setup can flow across pages, keeping every genuine gesture close to its action.
setup_pages=balance(setup,'PRISE EN MAIN · 15 MIN PLANIFIÉES')
main['pages']+=polish_setup(polish(setup_pages))
starts={}
for ident,j in steps.items():
    pages=deepcopy([p for p in source['pages'] if p['id'].startswith('v6.'+ident+'.')])
    opening=note('A · Ouvrir '+Path(j['path']).name,'Files → petit bouton R (Go to project directory) → scripts → '+Path(j['path']).name+'. Vérifier le nom de l’onglet Source. Les explications indiquent ensuite les blocs à lancer.')
    pages[0]['blocks'].insert(0,opening)
    pages[0]['blocks'].insert(1,{'type':'transfer','ds':j['transfer_ds'],'finance':j['transfer_finance']})
    if ident=='09':pages.append(deepcopy(next(p for p in source['pages'] if p['id']=='v6.checkpoint')))
    # Proof must follow the experience, including the restored state. A recap
    # in a previous scene (notably12) is not a safe place for before/after proof.
    flat=[b for p in pages for b in p['blocks']]
    last_experiment=max(i for i,b in enumerate(flat) if b.get('experiment'))
    recap=next((b for i,b in reversed(list(enumerate(flat))) if i>last_experiment and b.get('label','').startswith('À ce stade')),None)
    if recap:
        recap['text']+='\nPreuve à montrer : '+j['proof_prompt'];recap['_phase']='proof'
    else:pages[-1]['blocks'].append({**note('Vérifier et expliquer',j['proof_prompt']),'_phase':'proof'})
    pages[-1]['blocks'].append({'type':'next_step','label':'Étape suivante · page 00','text':j['next_instruction'],'next_id':j['next_id']})
    starts[ident]=len(main['pages'])+1
    rendered=balance(pages,('SOCLE' if int(ident)<=6 else 'ANALYSE' if int(ident)<=9 else 'DÉCOUVERTE GUIDÉE')+' · '+ident+' · '+str(j['minutes'])+' MIN')
    sequence=[b for p in rendered for b in p['blocks']]
    restored=max(i for i,b in enumerate(sequence) if b.get('_phase')=='D')
    assert all(i>restored for i,b in enumerate(sequence) if b.get('_phase')=='proof'),ident+' proof precedes restoration'
    for p in rendered:p['step']=ident
    main['pages']+=polish(rendered,ident)
final_page=len(main['pages'])+1
for ident in ['v6.final','v6.troubleshoot']:
    main['pages']+=balance([next(p for p in source['pages'] if p['id']==ident)],'SYNTHÈSE · 15 MIN PLANIFIÉES' if ident=='v6.final' else 'REPRENDRE SEREINEMENT')
for p in main['pages']:
    for b in p.get('blocks',[]):
        if b['type']=='next_step':
            target=starts.get(b.get('next_id'),final_page)
            b['target_page']=target;b['label']='Continuer · page '+str(target)
for b in main['pages'][index_position]['blocks']:
    if b['type']=='table':
        for row in b['rows']:row[-1]=str(starts[row[0]])
        b['row_targets']=[starts[row[0]] for row in b['rows']]

memo_source=json.loads((ROOT/'authoring/v6_reperes.json').read_text())
memo={k:deepcopy(v) for k,v in memo_source.items() if k in ['title','subtitle','author','filename']}
memo.update(page_navigation=True,max_body_bottom=175,enforce_density=True)
memo['pages']=balance(memo_source['pages'],'MÉMO · RETROUVER UN GESTE OU UN MOT')
memo['pages']=polish_topics(memo['pages'],{
  'v6.memo.gestures':[note('Tableau puis code','Le dernier bloc ouvre le CSV automatiquement. Pour lire, rester sur l’onglet CSV ; pour modifier, cliquer le nom exact du fichier .R dans Source.')],
  'v6.memo.functions':[bind(fig('mental_function',180,'Une fonction reçoit des entrées, réutilise la méthode et rend un résultat.')),
    {'type':'learning_check','question':'La définition seule doit-elle produire un rapport ?','answer':'Non : B02 enregistre la recette ; B03 l’appelle. B04 et B05 produisent et retrouvent le rapport.'}],
  'v6.memo.units':[text('Vérification rapide : 0.02 est une fraction ; après multiplication par 100, on lit 2 %. Une unité reste attachée au nombre dans votre explication.')],
  'v6.memo.files_core':[note('Retrouver le bon onglet','Le tableau CSV et le script peuvent être ouverts ensemble. Le nom exact du fichier .R dans Source indique le code que vous modifiez.')]
})

refs=[]
for ref in source['source_refs']:
    refs.append({'title':ref['title'],'url':ref['url'],'short':urlparse(ref['url']).netloc+' → ouvrir'})
sources={'filename':'03_sources.pdf','title':'Sources et conventions · Noria Gestion','page_navigation':True,'max_body_bottom':175,'enforce_density':True,'pages':[
 {'title':'Données et provenance','kicker':'PROVENANCE ET RÈGLES DE LECTURE','blocks':[
  text('Noria Gestion est fictive. Les quatre séries historiques EuStockMarkets proviennent de R ; la notice datasets crédite Erste Bank AG, Vienne, Autriche.'),
  {'type':'table','headers':['Élément','Convention'],'widths':[125,380],'rows':[
   ['Source réelle','1991–1998 ; 1 860 observations et 4 indices : DAX, SMI, CAC, FTSE. Ordre ouvré fourni, sans calendrier fabriqué.'],
   ['Deux ajouts pédagogiques','Une copie exacte de l’observation 100 ; une ligne 1861 avec FTSE manquante. La source réelle reste intacte.'],
   ['Rendements','1 860 niveaux produisent 1 859 variations voisines. Une absence interne doit être examinée avant calcul.'],
   ['Panier en UM','Rééquilibrage à chaque observation. Séries utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Les conventions des indices peuvent différer.'],
   ['Conclusions','VaR : seuil, pas maximum ; stress : hypothèse choisie ; bootstrap : hypothèses iid ; régression : association simultanée, pas prévision du lendemain.']]},
  bind(fig('mental_cleaning',165,'Le fichier d’entraînement est fabriqué pour exercer des contrôles précis, pas pour prétendre découvrir des défauts dans la source.')),
  note('Vérifier une provenance','data/sources.json décrit l’origine, les modifications et les empreintes des CSV. authoring/exporter_donnees.R reconstruit des copies dans outputs/reconstruction_source/ sans modifier data/.') ]},
 {'title':'Documentation et crédits','kicker':'SOURCES OFFICIELLES · VÉRIFIÉES LE 24 OCTOBRE 2026','blocks':[
  text('Les liens ci-dessous servent à approfondir ; le parcours principal se suit sans les ouvrir. Les zones « ouvrir » sont cliquables dans le PDF téléchargé.'),
  {'type':'references','items':refs},
  text('Données : notices R/datasets, attribution et textes GPL-2/GPL-3 dans data/licenses/. CSV éditables et reconstruction fournis.'),
  text('Identité : logos Leaders approuvés par Youssef Douma. Logo R : R Foundation, CC BY-SA 4.0 ou GPL-2. Inter et Plus Jakarta Sans : SIL Open Font License, notices incluses.'),
  text('Images : couverture originale image_gen, titres et logos composés séparément. Diagrammes explicitement pédagogiques ; graphiques et comparaisons issus des exécutions R. Captures réelles RStudio Server/Linux, navigateur sur macOS ; consignes Windows, sans prétendre à une installation Windows rejouée ici.'),
  text('Les notices de police, l’origine des données et les coordonnées des captures restent incluses avec les sources éditables.') ]}]}
content={'documents':[main,memo,sources]}
(ROOT/'authoring/content_finance.json').write_text(json.dumps(content,ensure_ascii=False,indent=2)+'\n')
quality=[]
for d in content['documents']:
    for i,p in enumerate(d['pages'],1):
        if p.get('layout')=='cover':continue
        y=bottom(p);quality.append({'file':d['filename'],'page':i,'title':p['title'],'body_bottom':round(y,1),'whitespace_flag':y>d['max_body_bottom']})
receipt={'documents':{d['filename']:len(d['pages']) for d in content['documents']},'script_pages':starts,'planned_minutes':journey['planned_total_minutes'],'whitespace_pages':[r for r in quality if r['whitespace_flag']],'layout':quality}
(ROOT/'outputs/composition_receipt.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(receipt,ensure_ascii=False,indent=2))
