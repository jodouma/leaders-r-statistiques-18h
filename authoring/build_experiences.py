"""Execute the guide's reference → exact variant blocks → restore in private copies.

Produces observed before/after facts and vector verification cards. No learner
file or data source is changed. Called by rebuild.py with the same Rscript.
"""
from pathlib import Path
import argparse
import csv
import hashlib
import json
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'authoring/assets/v7/experiences'
PROOF = ROOT / 'outputs/experience_runs'

# Each expression reads the actual objects left by the supplied script.
METRICS = {
    '00': 'c(capital_UM=capital, final_capital_UM=capital_after_gain, gain_UM=500)',
    '01': 'c(gain_UM=gain, first_final_UM=final_capital, compounded_UM=compounded_capital)',
    '02': 'c(preview_rows=preview_rows, raw_rows=nrow(raw), source_rows=nrow(original))',
    '03': 'c(quarantine_rows=nrow(demo_cleaned$quarantine), changed_observation=demo_row, retained_observations=paste(demo_cleaned$quarantine$observation,collapse=" / "))',
    '04': 'c(market=market, returns=nrow(returns), first_percent=100*returns[[market]][1])',
    '05': 'c(requested_classes=bins, actual_classes=length(hist(100*series,breaks=bins,plot=FALSE)$counts), mean_percent=100*mean(series), observations=length(series))',
    '06': 'c(curves=length(selected), start=normalized[1,selected[1]], CAC_DAX_correlation=correlations["CAC","DAX"])',
    '07': 'c(CAC_percent=100*cac_weight, final_capital_UM=tail(wealth,1), observations=length(portfolio))',
    '08': 'c(confidence_percent=100*confidence, VaR_UM=var_amount, drawdown_percent=100*min(drawdown))',
    '09': 'c(DAX_shock_percent=100*dax_shock, return_percent=100*scenario_return, final_capital_UM=final_capital)',
    '10': 'c(horizon=horizon, paths=paths, q05_UM=summary$final_capital_UM[1], q50_UM=summary$final_capital_UM[2], q95_UM=summary$final_capital_UM[3])',
    '11': 'c(train_rows=nrow(train), test_rows=nrow(test), model_RMSE_points=100*model_rmse, baseline_RMSE_points=100*baseline_rmse)',
    '12': 'c(CAC_choices=paste(100*weights,collapse=" / "), baskets=nrow(summary), same60_final_UM=summary$final_capital_UM[summary$CAC_weight==0.60])',
}


def r_literal(value, original):
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, list):
        return 'c(' + ', '.join(r_literal(v, original) for v in value) + ')'
    if isinstance(value, float):
        digits = max((len(v) for v in re.findall(r'\.(\d+)', original)), default=2)
        return f'{value:.{digits}f}'
    return str(value)


def metric_rows(path):
    with path.open(newline='') as f:
        data = {r['key']:r['value'] for r in csv.DictReader(f)}
    for key, value in data.items():
        try:
            data[key] = float(value)
        except ValueError:
            pass
    return data


def hashes(folder):
    return {p.name:hashlib.sha256(p.read_bytes()).hexdigest()
            for p in folder.glob('*') if p.is_file()}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--r', default='Rscript')
    args=parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    PROOF.mkdir(parents=True, exist_ok=True)
    manifest=json.loads((ROOT/'authoring/finance_manifest.json').read_text())
    original_hashes=hashes(ROOT/'data')
    records=[]
    for script in manifest['scripts']:
        step=script['step'];experiment=script['experiment']
        original=(ROOT/script['path']).read_text()
        pattern=r'^'+re.escape(experiment['parameter'])+r' <- .+$'
        matches=re.findall(pattern, original, re.M)
        assert len(matches)==1, (step,matches)
        before_line=matches[0]
        after_line=experiment['parameter']+' <- '+r_literal(experiment['try'], before_line)
        variant=re.sub(pattern, lambda _:after_line, original, count=1, flags=re.M)
        with tempfile.TemporaryDirectory(prefix='noria-guide-'+step+'-') as tmp:
            tmp=Path(tmp)
            for name in ['R','data','scripts']:
                shutil.copytree(ROOT/name,tmp/name)
            shutil.copy2(ROOT/'course.Rproj',tmp/'course.Rproj')
            (tmp/'variant.R').write_text(variant)
            proof=PROOF/step;proof.mkdir(exist_ok=True)
            # Full section evaluation is the same boundary as RStudio's
            # Run Code Section, including a complete function definition.
            wrapper='''
.guide_run <- function(path, wanted=NULL) {
  code <- readLines(path, warn=FALSE, encoding="UTF-8")
  starts <- grep("^# B[0-9]{2} .*----$",code)
  ends <- c(starts[-1]-1L,length(code))
  ids <- substr(code[starts],3,5)
  for (i in seq_along(starts)) if (is.null(wanted) || ids[i] %in% wanted)
    eval(parse(text=code[starts[i]:ends[i]]),envir=.GlobalEnv)
}
.guide_snapshot <- function(phase) {
  values <- METRIC_EXPRESSION
  write.csv(data.frame(key=names(values),value=as.character(values)),
            paste0(phase,"-metrics.csv"),row.names=FALSE)
  dir.create(paste0(phase,"-artifacts"))
  file.copy(list.files("outputs/STEP",full.names=TRUE),paste0(phase,"-artifacts"))
}
.guide_run(SCRIPT_PATH)
.guide_snapshot("reference")
.guide_run("variant.R", RERUN_IDS)
.guide_snapshot("variant")
.guide_run(SCRIPT_PATH, RERUN_IDS)
.guide_snapshot("restore")
'''.replace('METRIC_EXPRESSION',METRICS[step]).replace('STEP',step)
            wrapper=wrapper.replace('SCRIPT_PATH',json.dumps(script['path']))
            wrapper=wrapper.replace('RERUN_IDS','c('+','.join(json.dumps(b) for b in experiment['rerun'])+')')
            (tmp/'guided-run.R').write_text(wrapper)
            result=subprocess.run([args.r,'--vanilla',str(tmp/'guided-run.R')],
                                  cwd=tmp,text=True,capture_output=True)
            (proof/'console.log').write_text(result.stdout+result.stderr)
            if result.returncode:
                raise RuntimeError(step+' failed; see '+str(proof/'console.log'))
            reference=metric_rows(tmp/'reference-metrics.csv')
            changed=metric_rows(tmp/'variant-metrics.csv')
            restored=metric_rows(tmp/'restore-metrics.csv')
            assert reference==restored, (step,'metric restoration')
            assert hashes(tmp/'reference-artifacts')==hashes(tmp/'restore-artifacts'), (step,'artifact restoration')
            assert hashes(tmp/'data')==original_hashes, (step,'immutable inputs')
            for phase in ['reference','variant','restore']:
                shutil.copy2(tmp/(phase+'-metrics.csv'),proof/(phase+'-metrics.csv'))
            records.append({'id':step,'path':script['path'],
                'source_sha256':hashlib.sha256(original.encode()).hexdigest(),
                'default_line':before_line,'variant_line':after_line,
                'rerun_blocks':experiment['rerun'],'reference':reference,'variant':changed,
                'restore_matches_reference':True,
                'restored_artifacts':len(hashes(tmp/'restore-artifacts'))})
    (OUT/'facts.json').write_text(json.dumps({'method':'13 isolated reference / exact variant sections / restored sections; actual R objects',
       'records':records,'input_files_preserved':True},ensure_ascii=False,indent=2)+'\n')
    print('13 reference runs, 13 variants and 13 restores verified; facts exported.')


if __name__=='__main__':
    main()
