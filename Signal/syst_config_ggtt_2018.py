# Config file: options for signal fitting

_tag='dummy'
_year = '2018'

signalScriptCfg = {
  
  # Setup
  'inputWSDir':'/home/users/fsetti/ic_flashgg/CMSSW_10_2_13/src/flashggFinalFit/files_systs/%s/ws_signal_%s/'%(_tag,_year),
  'procs':'auto', # if auto: inferred automatically from filenames
  'cats':'auto', # if auto: inferred automatically from (0) workspace
  'ext':'%s_%s'%(_tag,_year),
  'analysis':'ggtt_nonRes', # To specify which replacement dataset mapping (defined in ./python/replacementMap.py)
  'year':'%s'%_year, # Use 'combined' if merging all years: not recommended
  'massPoints':'125',

  #Photon shape systematics  
  'scales':'_scale', # separate nuisance per year
  'scalesCorr':'fnuf,material', # correlated across years
  'scalesGlobal':'', # affect all processes equally, correlated across years
  'smears':'_smear', # separate nuisance per year

  # Job submission options
  'batch':'local', # ['condor','SGE','IC','local']
  'queue':'hep.q'
  #'batch':'condor', # ['condor','SGE','IC','local']
  #'queue':'espresso',

}
