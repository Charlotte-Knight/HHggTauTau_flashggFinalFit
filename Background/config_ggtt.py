# Config file: options for signal fitting

_tag="dummy"

backgroundScriptCfg = {
  
  # Setup
  'inputWSDir':'/vols/cms/mdk16/ggtt/NonResFinalFits/CMSSW_10_2_13/src/flashggFinalFit/Trees_dummy/Data/ws/', # location of 'allData.root' file
  'cats':'auto', # auto: automatically inferred from input ws
  'catOffset':0, # add offset to category numbers (useful for categories from different allData.root files)  
  'ext':'%s'%(_tag), # extension to add to output directory
  'year':'combined', # Use combined when merging all years in category (for plots)

  # Job submission options
  'batch':'local', # [condor,SGE,IC,local]
  'queue':'hep.q' # for condor e.g. microcentury
  
}
