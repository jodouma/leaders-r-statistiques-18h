# Rebuild authoring facts after running scripts/00..12; Python standard library only.
from pathlib import Path
import csv,json,re,hashlib
root=Path(__file__).resolve().parents[1]
def read(name):
 with (root/'outputs'/name).open() as f:
  rows=list(csv.DictReader(f))
 for row in rows:
  for k,v in row.items():
   try:row[k]=float(v)
   except:pass
 return rows
experiments=[
 {'block':'B03','parameter':'capital','default':10000,'try':12000,'rerun':['B03','B04'],'expect':'Le capital final passe à 12500 UM.','expected_value':12500},
 {'block':'B02','parameter':'rate','default':0.05,'try':0.10,'rerun':['B02','B03','B04'],'expect':'Le gain passe à 1000 UM ; capital après la première période : 11000 UM.','expected_gain_UM':1000},
 {'block':'B04','parameter':'preview_rows','default':6,'try':10,'rerun':['B04'],'expect':'Dix lignes originales sont affichées au lieu de six ; le CSV ne change pas.'},
 {'block':'B05','parameter':'demo_row','default':10,'try':20,'rerun':['B05'],'expect':'La ligne artificielle incomplète et l’observation20 modifiée en mémoire partent en quarantaine ; total2. Les CSV restent intacts.','expected_quarantine_rows':2},
 {'block':'B04','parameter':'market','default':'CAC','try':'DAX','rerun':['B04'],'expect':'La courbe affiche DAX ; 1859 variations restent disponibles.'},
 {'block':'B04','parameter':'bins','default':30,'try':15,'rerun':['B04'],'expect':'La forme des barres change, mais les statistiques et les données restent identiques.'},
 {'block':'B03','parameter':'selected','default':['CAC','DAX','SMI','FTSE'],'try':['CAC','DAX'],'rerun':['B03'],'expect':'Deux courbes, toutes deux au départ 100.'},
 {'block':'B02','parameter':'cac_weight','default':0.6,'try':0.8,'rerun':['B02','B03','B04'],'expect':'Les poids deviennent 80 % CAC et 20 % DAX ; le chemin et le capital final changent.','expected_final_UM':read('12/comparaison_paniers.csv')[2]['final_capital_UM']},
 {'block':'B02','parameter':'confidence','default':0.95,'try':0.99,'rerun':['B02','B03','B04'],'expect':'Le seuil de VaR augmente ou reste identique ; le drawdown ne change pas.'},
 {'block':'B02','parameter':'dax_shock','default':-0.12,'try':-0.20,'rerun':['B02','B03','B04'],'expect':'Le panier perd 9,2 % ; le capital final vaut 9080 UM.','expected_return':-0.092,'expected_final_UM':9080},
 {'block':'B02','parameter':'horizon','default':20,'try':40,'rerun':['B02','B03','B04'],'expect':'Les quantiles et la dispersion simulés changent ; 5000 scénarios restent calculés.','note':'La graine est identique, mais le nombre de tirages et leur groupement changent.'},
 {'block':'B02','parameter':'train_fraction','default':0.8,'try':0.7,'rerun':['B02','B03','B04','B05'],'expect':'1301 observations pour ajuster, 558 pour tester ; les RMSE changent.','expected_train_rows':1301,'expected_test_rows':558},
 {'block':'B03','parameter':'weights','default':[0.4,0.6,0.8],'try':[0.2,0.6,1.0],'rerun':['B03','B04','B05'],'expect':'Le rapport est remplacé par trois nouvelles comparaisons ; la ligne 60 % CAC reste identique.'}
]
expected=[
 {'console':[300,10000,'UM',10500],'observation':'La valeur nommée capital est réutilisée ; outputs/00/premier_calcul.csv est créé.'},
 {'gain_UM':500,'first_final_UM':10500,'return_100_to_102_percent':2,'compounded_final_UM':9975,'observation':'+5 % puis −5 % ne ramène pas à 10000 UM.'},
 {'raw_rows':1862,'source_rows':1860,'columns':5,'observation':'Les deux fichiers ont les mêmes 1860 premières observations réelles.'},
 {'raw_rows':1862,'unique_rows':1861,'clean_rows':1860,'quarantine_rows':1,'duplicates':1,'observation':'Le doublon 100 est retiré ; la ligne artificielle 1861 part en quarantaine ; aucun extrême réel supprimé.'},
 {'returns_rows':1859,'first_CAC_old':1772.8,'first_CAC_new':1750.5,'first_CAC_return':read('04/rendements.csv')[0]['CAC'],'observation':'Le rendement CAC de la première paire est environ −1,258 %, soit −0,01258 en décimal.'},
 {'statistics':read('05/statistiques.csv')[0],'observation':'CAC : moyenne ≈0,050 % et écart-type ≈1,103 % par observation ; médiane 0 %.'},
 {'final_normalized':read('06/indices_base100.csv')[-1],'correlations':read('06/correlations.csv'),'observation':'Toutes les séries partent à 100 ; association positive CAC/DAX ≈0,733.'},
 {'CAC_weight':0.6,'DAX_weight':0.4,'capital_initial_UM':10000,'capital_final_UM':read('08/risque.csv')[0]['final_capital_UM'],'observation':'Le panier rééquilibré finit vers 26803,14 UM sur cet historique ancien.'},
 {'risk':read('08/risque.csv')[0],'observation':'VaR historique 95 % ≈153,05 UM par observation ; drawdown maximal ≈−21,75 %.'},
 {'scenario_return':-0.06,'final_capital_UM':9400,'CAC_contribution':-0.012,'DAX_contribution':-0.048,'observation':'Le choc inventé produit −6 %, soit une perte de 600 UM.'},
 {'seed':2026,'horizon_observations':20,'paths':5000,'quantiles':read('10/quantiles_simules.csv'),'observation':'Capital final simulé : quantiles 5/50/95 % ≈9381,10 / 10118,31 / 10863,21 UM.'},
 {'train_rows':1487,'test_rows':372,'last_train_observation':1488,'first_test_observation':1489,'RMSE_percent':read('11/erreurs_test.csv'),'observation':'RMSE test du modèle ≈0,831 point de % contre ≈1,341 pour la moyenne d’entraînement ; résultat limité à ce découpage.'},
 {'baskets':read('12/comparaison_paniers.csv'),'report':'outputs/12/rapport_noria.html','observation':'Trois comparaisons et un rapport HTML local ; les images restent dans le même dossier.'}
]
manifest={
 'schema_version':1,'scenario':'Noria Gestion','language':'fr','generated_from':'data/marches_source.csv et marches_brut.csv, exécutés sous R 4.6.1/macOS','student_packages':'R base >= 4.1 ; aucun package additionnel',
 'workflow':{'open':'course.Rproj','run':'Ouvrir scripts/<fichier>.R ; B01 puis B02… avec Run ou Ctrl+Enter ; Source optionnel.','independence':'Chaque fichier prépare ses propres entrées ; aucun fichier précédent requis.','destinations':{'text':'Console','objects':'Environment','interactive_plots':'Plots','files':'outputs/<étape>/'},'wrong_root':'Dossier incorrect : ouvrez course.Rproj (File > Open Project), puis relancez B01.'},
 'dataset':{'name':'datasets::EuStockMarkets','source_period':'1991–1998','source_rows':1860,'market_columns':['DAX','SMI','CAC','FTSE'],'identifier':'observation, entier 1…1860 ; ordre sans dates reconstituées','calendar':'business time, weekends et jours fériés omis','raw_rows':1862,'unique_rows':1861,'complete_rows':1860,'quarantined_rows':1,'return_rows':1859,'added_anomalies':['Une copie exacte de l’observation 100 ajoutée après les 1860 lignes.','Une observation éducative 1861 : derniers niveaux DAX/SMI/CAC conservés et FTSE manquante.'],'data_provenance':'data/sources.json'},
 'limitations':['Historique ancien illustratif, sans cours actuels ni recommandation d’investissement.','Niveaux d’indices, pas des prix TND ni des produits tradables.','Observation = ordre ; aucune date de marché inventée.','Comparaison en base 100 et rendements en devises locales. Séries d’indices utilisées telles quelles ; aucun traitement supplémentaire du change, des frais ou des dividendes. Conventions des indices potentiellement différentes.','Tout panier est pédagogique, pondéré et rééquilibré à chaque observation ; capital en UM.','VaR historique par observation, quantile type 7 ; ni perte maximale ni garantie future.','Drawdown calculé avec le capital initial dans le chemin et le sommet courant.','Simulation bootstrap avec remise, hypothèse iid simplificatrice, sans garantie future.','Régression simultanée CAC~DAX : association contemporaine, ni prévision du lendemain ni causalité ; entraînement avant test.','Exemples arithmétiques et choc explicitement inventés.'],
 'scripts':[]}
for idx,p in enumerate(sorted((root/'scripts').glob('*.R'))):
 lines=p.read_text().splitlines();marks=[]
 for i,line in enumerate(lines,1):
  m=re.match(r'# (B\d+) — (.*?) ----$',line)
  if m:marks.append({'id':m[1],'title':m[2],'line_start':i})
 for j,b in enumerate(marks):b['line_end']=marks[j+1]['line_start']-1 if j+1<len(marks) else len(lines)
 outputs=[str(x.relative_to(root)) for x in sorted((root/'outputs'/f'{idx:02}').iterdir())]
 manifest['scripts'].append({'step':f'{idx:02}','path':str(p.relative_to(root)),'title':lines[0].split('—',1)[1].strip(),'route':'socle' if idx<=6 else 'analyse' if idx<=9 else 'decouverte','blocks':marks,'outputs':outputs,'expected':expected[idx],'experiment':experiments[idx]})
(root/'authoring/finance_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
# Notices d'origine conservées avec les sources éditables en CSV et leur reconstruction.
provenance={'title':'Daily Closing Prices of Major European Stock Indices, 1991–1998','object':'datasets::EuStockMarkets','R_version_exported':'4.6.1','package':'datasets 4.6.1','attribution':'R Core Team and contributors worldwide ; données fournies par Erste Bank AG, Vienna, Austria (notice R).','official_documentation':'https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/EuStockMarkets.html','R_source':'https://cran.r-project.org/src/base/R-4/','license_package_description':'Part of R 4.6.1','license_R_copyright_notice':'R as a whole is distributed under GPL version 2 or 3.','license_notices':['data/licenses/datasets-DESCRIPTION.txt','data/licenses/R-COPYRIGHTS.txt','data/licenses/GPL-2.txt','data/licenses/GPL-3.txt'],'redistribution':'CSV source éditable, attribution et notices d’origine conservées. Les modifications pédagogiques sont signalées séparément ; aucune garantie.','conversion':'as.matrix(datasets::EuStockMarkets), ajout de observation=1:1860, export write.csv(row.names=FALSE). Les valeurs de marché originales sont inchangées.','reconstruction_script':'authoring/exporter_donnees.R ; écrit seulement outputs/reconstruction_source/','source_rows':1860,'market_columns':['DAX','SMI','CAC','FTSE'],'order':'business time : weekends et jours fériés omis ; aucun calendrier fabriqué','training_modifications_date':'2026-10-24','training_modifications':['copie exacte de la ligne observation=100 ajoutée en position 1861','ligne observation=1861 ajoutée en position 1862, derniers niveaux DAX/SMI/CAC, FTSE=NA'],'files':[]}
for name in ['marches_source.csv','marches_brut.csv']:
 p=root/'data'/name;provenance['files'].append({'path':'data/'+name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size})
(root/'data/sources.json').write_text(json.dumps(provenance,ensure_ascii=False,indent=2)+'\n')
