"""Build the offline student workbook and optional ZIP. Maintainer tool only."""
from pathlib import Path
from urllib.parse import unquote,parse_qs
import argparse,zipfile
from pypdf import PdfReader,PdfWriter
from pypdf.generic import DictionaryObject,NameObject,ArrayObject,TextStringObject
ORDER=['00_LIRE_MOI.pdf','COMMENCER_ICI.pdf','pdf/00_demarrer.pdf','pdf/00_premiers_pas.pdf','pdf/01_parcours_18h.pdf','pdf/diagnostic_entree.pdf','pdf/03_donnees_et_sources.pdf','pdf/02_cours_visuel.pdf','pdf/06_exemples_guides.pdf','pdf/07_aides_progressives.pdf','pdf/10_TP01_demarrer.pdf','pdf/11_TP02_preparer.pdf','pdf/12_TP03_comparer.pdf','pdf/13_TP04_projet.pdf','pdf/14_memo_R.pdf','pdf/80_corriges_et_preuves.pdf','pdf/99_sources_visuelles.pdf']
BASE_URL='https://github.com/jodouma/leaders-r-statistiques-18h/blob/main/'
def package(root,zip_path=None):
 root=Path(root).resolve();w=PdfWriter();offsets={};origins=[];lengths={}
 for name in ORDER:
  f=root/name;r=PdfReader(f);offsets[f]=len(w.pages);lengths[f]=len(r.pages)
  w.append(r,outline_item=(r.metadata.title if r.metadata else None) or f.stem,import_outline=True)
  origins.extend([f]*len(r.pages))
 converted=0
 for page,source in zip(w.pages,origins):
  for ref in page.get('/Annots',[]):
   ann=ref.get_object();action=ann.get('/A')
   if not action or action.get('/S')!='/URI':continue
   uri=str(action.get('/URI',''))
   if '://' in uri or uri.startswith('mailto:'):continue
   rel,_,fragment=uri.partition('#');target=(source.parent/unquote(rel)).resolve()
   if target in offsets:
    jump=int(parse_qs(fragment).get('page',['1'])[0])-1
    if not 0<=jump<lengths[target]:raise ValueError('Bad page link '+uri)
    dest=ArrayObject([w.pages[offsets[target]+jump].indirect_reference,NameObject('/Fit')])
    ann[NameObject('/A')]=DictionaryObject({NameObject('/S'):NameObject('/GoTo'),NameObject('/D'):dest});converted+=1
   else:action[NameObject('/URI')]=TextStringObject(BASE_URL+target.relative_to(root).as_posix()+('#'+fragment if fragment else ''))
 w.add_metadata({'/Title':'Statistiques avec R · à votre rythme','/Author':'Youssef Douma · Leaders University','/Subject':'Autoformation accompagnée · 4 TP'})
 w.page_mode='/UseOutlines';w.write(root/'Dossier_etudiant_R_18h.pdf')
 receipt={'pages':len(w.pages),'internal_links':converted,'chapters':len(ORDER)}
 if zip_path:
  zip_path=Path(zip_path).resolve();zip_path.parent.mkdir(parents=True,exist_ok=True)
  with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as z:
   for f in sorted(root.rglob('*')):
    if not f.is_file() or f.resolve()==zip_path:continue
    rel=f.relative_to(root)
    if any(a in rel.parts for a in ('.git','results','__pycache__','.mpl-cache','.Rproj.user')):continue
    if f.name in ('Rplots.pdf','.DS_Store','.Rhistory','.RData','.Ruserdata'):continue
    z.write(f,'r-statistiques-18h/'+rel.as_posix())
  receipt['zip_bytes']=zip_path.stat().st_size
 return receipt
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--root',default='.');parser.add_argument('--zip');args=parser.parse_args()
 print(package(args.root,args.zip))
