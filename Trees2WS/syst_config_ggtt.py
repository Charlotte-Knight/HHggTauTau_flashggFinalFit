# Input config file for running trees2ws

trees2wsCfg = {

  # Name of RooDirectory storing input tree
  'inputTreeDir':'',

  # Variables to be added to dataframe: use wildcard * for common strings
  'mainVars':["CMS_hgg_mass","weight","weight_central_initial", "dZ", "*sigma*"], # Var for the nominal RooDataSets
  'dataVars':["CMS_hgg_mass","weight"], # Vars to be added for data
  'stxsVar':'',
  'notagVars':["weight"], # Vars to add to NOTAG RooDataset
  'systematicsVars':["CMS_hgg_mass","weight"], # Variables to add to sytematic RooDataHists
  'theoryWeightContainers':{},

  # List of systematics: use string YEAR for year-dependent systematics
  'systematics':["fnuf","material","MCScale_scale", "MCSmear_smear", "JER", "JES", "MET_JES", "MET_Unclustered", "Muon_pt", "Tau_pt"],
  #'systematics':[],

  # Analysis categories: python list of cats or use 'auto' to extract from input tree
  'cats':'auto'

}
