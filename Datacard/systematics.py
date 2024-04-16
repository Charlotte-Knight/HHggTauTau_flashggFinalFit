# Python file to store systematics: for STXS analysis

# Comment out all nuisances that you do not want to include

# THEORY SYSTEMATICS:

# For type:constant
#  1) specify same value for all processes
#  2) define process map json in ./theory_uncertainties (add process names where necessary!)

# For type:factory
# Tier system: adds different uncertainties to dataframe
#   1) shape: absolute yield of process kept constant, shape effects i.e. calc migrations across cats
#   2) ishape: as (1) but absolute yield for proc x cat is allowed to vary
#   3) norm: absolute yield of production mode (s0) kept constant but migrations across sub-processes e.g. STXS bins.Same value in each category.
#   4) inorm: as (3) but absolute yield of production mode (s0) can vary
#   5) inc: variations in production mode (s0), same value for each subprocess in each category
# Relations: shape = ishape/inorm
#            norm  = inorm/inc
# Specify as list in dict: e.g. 'tiers'=['inc','inorm','norm','ishape','shape']

theory_systematics = [
                # Normalisation uncertainties: enter interpretations
                {'name':'BR_hgg','title':'BR_hgg','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':"0.9791/1.0205"},
								{'name':'BR_htt','title':'BR_htt','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_gghh.json'},
 								{'name':'BR_hww','title':'BR_hww','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_gghh.json'},

                #{'name':'pho_idmvaSF','title':'pho_idmvaSF','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':"0.80/1.20"},

                #{'name':'ggHH_xsec','title':'ggHH_xsec','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':"theory_uncertainties/thu_gghh.json"},

								{'name':'QCDscale_ggHH','title':'QCDscale_ggHH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_gghh.json'},
								{'name':'QCDscale_ggH','title':'QCDscale_ggH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_ggh.json'},
								{'name':'QCDscale_qqH','title':'QCDscale_qqH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_qqh.json'},
								{'name':'QCDscale_VH','title':'QCDscale_VH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_vh.json'},
                {'name':'QCDscale_ttH','title':'QCDscale_ttH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_tth.json'},
								
								{'name':'pdf_Higgs_ggHH','title':'pdf_Higgs_ggHH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_gghh.json'},
								{'name':'pdf_Higgs_ggH','title':'pdf_Higgs_ggH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_ggh.json'},
								{'name':'pdf_Higgs_qqH','title':'pdf_Higgs_qqH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_qqh.json'},
								{'name':'pdf_Higgs_VH','title':'pdf_Higgs_VH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_vh.json'},
								{'name':'pdf_Higgs_ttH','title':'pdf_Higgs_ttH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_tth.json'},
																
								{'name':'alphaS_ggH','title':'alphaS_ggH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_ggh.json'},
								{'name':'alphaS_qqH','title':'alphaS_qqH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_qqh.json'},
								{'name':'alphaS_VH','title':'alphaS_VH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_vh.json'},
								{'name':'alphaS_ttH','title':'alphaS_ttH','type':'constant','prior':'lnN','correlateAcrossYears':1,'value':'theory_uncertainties/thu_tth.json'},
]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# EXPERIMENTAL SYSTEMATICS
# correlateAcrossYears = 0 : no correlation
# correlateAcrossYears = 1 : fully correlated
# correlateAcrossYears = -1 : partially correlated

experimental_systematics = [
                # Updated luminosity partial-correlation scheme: 13/5/21 (recommended simplified nuisances)
                {'name':'lumi_13TeV_Uncorrelated','title':'lumi_13TeV_uncorrelated','type':'constant','prior':'lnN','correlateAcrossYears':0,'value':{'2016':'1.010','2017':'1.020','2018':'1.015'}},
                {'name':'lumi_13TeV_Correlated','title':'lumi_13TeV_correlated','type':'constant','prior':'lnN','correlateAcrossYears':-1,'value':{'2016':'1.006','2017':'1.009','2018':'1.020'}},
                {'name':'lumi_13TeV_Correlated_1718','title':'lumi_13TeV_1718','type':'constant','prior':'lnN','correlateAcrossYears':-1,'value':{'2016':'-','2017':'1.006','2018':'1.002'}},
                {'name':'weight_electron_veto_sf_Diphoton_Photon','title':'CMS_eff_e_veto','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_electron_id_sf_SelectedElectron','title':'CMS_eff_e_id','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_muon_id_sfSTAT_SelectedMuon','title':'CMS_eff_m_id_stat','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_muon_id_sfSYS_SelectedMuon','title':'CMS_eff_m_id_sys','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_muon_iso_sfSTAT_SelectedMuon','title':'CMS_eff_m_iso_stat','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_muon_iso_sfSYS_SelectedMuon','title':'CMS_eff_m_iso_sys','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_trigger_sf','title':'CMS_hgg_TriggerWeight','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_puWeight','title':'CMS_pileup','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'JER','title':'CMS_res_j','type':'factory','prior':'lnN','correlateAcrossYears':0},
                
                # jet energy scale
                {'name':'Jet_jesAbsolute','title':'CMS_scale_j_Abs','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'Jet_jesAbsolute_year','title':'CMS_scale_j_Abs','type':'factory','prior':'lnN','correlateAcrossYears':0},
                
                {'name':'Jet_jesBBEC1','title':'CMS_scale_j_BBEC1','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'Jet_jesBBEC1_year','title':'CMS_scale_j_BBEC1','type':'factory','prior':'lnN','correlateAcrossYears':0},

                {'name':'Jet_jesEC2','title':'CMS_scale_j_EC2','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'Jet_jesEC2_year','title':'CMS_scale_j_EC2','type':'factory','prior':'lnN','correlateAcrossYears':0},

                {'name':'Jet_jesFlavorQCD','title':'CMS_scale_j_FlavQCD','type':'factory','prior':'lnN','correlateAcrossYears':1},

                {'name':'Jet_jesHF','title':'CMS_scale_j_HF','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'Jet_jesHF_year','title':'CMS_scale_j_HF','type':'factory','prior':'lnN','correlateAcrossYears':0},
                
                {'name':'Jet_jesRelativeBal','title':'CMS_scale_j_RelBal','type':'factory','prior':'lnN','correlateAcrossYears':1},
                              
                {'name':'Jet_jesRelativeSample_year','title':'CMS_scale_j_RelSample','type':'factory','prior':'lnN','correlateAcrossYears':0},

                # MET jet energy scale
                {'name':'MET_jesAbsolute','title':'CMS_MET_scale_j_Abs','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'MET_jesAbsolute_year','title':'CMS_MET_scale_j_Abs','type':'factory','prior':'lnN','correlateAcrossYears':0},
                
                {'name':'MET_jesBBEC1','title':'CMS_MET_scale_j_BBEC1','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'MET_jesBBEC1_year','title':'CMS_MET_scale_j_BBEC1','type':'factory','prior':'lnN','correlateAcrossYears':0},

                {'name':'MET_jesEC2','title':'CMS_MET_scale_j_EC2','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'MET_jesEC2_year','title':'CMS_MET_scale_j_EC2','type':'factory','prior':'lnN','correlateAcrossYears':0},

                {'name':'MET_jesFlavorQCD','title':'CMS_MET_scale_j_FlavQCD','type':'factory','prior':'lnN','correlateAcrossYears':1},

                {'name':'MET_jesHF','title':'CMS_MET_scale_j_HF','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'MET_jesHF_year','title':'CMS_MET_scale_j_HF','type':'factory','prior':'lnN','correlateAcrossYears':0},
                
                {'name':'MET_jesRelativeBal','title':'CMS_MET_scale_j_RelBal','type':'factory','prior':'lnN','correlateAcrossYears':1},
                              
                {'name':'MET_jesRelativeSample_year','title':'CMS_MET_scale_j_RelSample','type':'factory','prior':'lnN','correlateAcrossYears':0},

                # MET
                {'name':'MET_Unclustered','title':'CMS_unclusteredEnergy','type':'factory','prior':'lnN','correlateAcrossYears':0},


                {'name':'Muon_pt','title':'CMS_scale_m','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'Tau_pt','title' :'CMS_scale_t','type':'factory','prior':'lnN','correlateAcrossYears':0},

                {'name':'weight_btag_deepjet_sf_SelectedJet_jes','title':'CMS_btag_jes','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_btag_deepjet_sf_SelectedJet_LF','title':'CMS_btag_LF_2016_2017_2018','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'weight_btag_deepjet_sf_SelectedJet_HF','title':'CMS_btag_HF_2016_2017_2018','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'weight_btag_deepjet_sf_SelectedJet_lfstats1','title':'CMS_btag_lfstats1','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_btag_deepjet_sf_SelectedJet_lfstats2','title':'CMS_btag_lfstats2','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_btag_deepjet_sf_SelectedJet_hfstats1','title':'CMS_btag_hfstats1','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_btag_deepjet_sf_SelectedJet_hfstats2','title':'CMS_btag_hfstats2','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_btag_deepjet_sf_SelectedJet_cferr1','title':'CMS_btag_cferr1_2016_2017_2018','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'weight_btag_deepjet_sf_SelectedJet_cferr2','title':'CMS_btag_cferr2_2016_2017_2018','type':'factory','prior':'lnN','correlateAcrossYears':1},

                {'name':'weight_tau_idDeepTauVSe_sf_AnalysisTau','title':'CMS_eff_tau_idDeepTauVSe','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_tau_idDeepTauVSmu_sf_AnalysisTau','title':'CMS_eff_tau_idDeepTauVSmu','type':'factory','prior':'lnN','correlateAcrossYears':0},
                
                {'name':'weight_lhe_scale0_sf','title':'CMS_scale0_lhe','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'weight_lhe_scale1_sf','title':'CMS_scale1_lhe','type':'factory','prior':'lnN','correlateAcrossYears':1},
                {'name':'weight_lhe_scale2_sf','title':'CMS_scale2_lhe','type':'factory','prior':'lnN','correlateAcrossYears':1},
                #{'name':'weight_lhe_pdf_sf','title':'CMS_pdf_lhe','type':'factory','prior':'lnN','correlateAcrossYears':1},

                {'name':'weight_photon_id_sf_Diphoton_Photon','title':'CMS_eff_g_IDMVA','type':'factory','prior':'lnN','correlateAcrossYears':0},
                {'name':'weight_photon_presel_sf_Diphoton_Photon','title':'CMS_hgg_Presel_SF','type':'factory','prior':'lnN','correlateAcrossYears':0},
]

for i in range(1, 10):
  experimental_systematics.append({'name':'weight_idDeepTauVSjet_stat_ptbin%d'%i,'title':'CMS_eff_tau_idDeepTauVSjet_stat_bin%d'%i,'type':'factory','prior':'lnN','correlateAcrossYears':0})
for era in ["2016_preVFP", "2016_postVFP", "2017", "2018"]:
  experimental_systematics.append({'name':'weight_idDeepTauVSjet_syst_%s'%era,'title':'CMS_eff_tau_idDeepTauVSjet_syst_%s'%era,'type':'factory','prior':'lnN','correlateAcrossYears':1})
experimental_systematics.append({'name':'weight_idDeepTauVSjet_syst_alleras','title':'CMS_eff_tau_idDeepTauVSjet_syst_alleras','type':'factory','prior':'lnN','correlateAcrossYears':1})

for i in range(1, 3):
  experimental_systematics.append({'name':'weight_idDeepTauVSjet_stat_highpT_bin%d'%i,'title':'CMS_eff_tau_idDeepTauVSjet_stat_highpT_bin%d'%i,'type':'factory','prior':'lnN','correlateAcrossYears':0})
experimental_systematics.append({'name':'weight_idDeepTauVSjet_syst_highpT','title':'CMS_eff_tau_idDeepTauVSjet_syst_highpT','type':'factory','prior':'lnN','correlateAcrossYears':1})
experimental_systematics.append({'name':'weight_idDeepTauVSjet_SYST_highpT_extrap','title':'CMS_eff_tau_idDeepTauVSjet_syst_highpT_extrap','type':'factory','prior':'lnN','correlateAcrossYears':1})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Shape nuisances: effect encoded in signal model
# mode = (other,scalesGlobal,scales,scalesCorr,smears): match the definition in the signal models

signal_shape_systematics = [
                {'name':'MCScale_scale','title':'MCScale_scale','type':'signal_shape','mode':'scales','mean':'0.0','sigma':'1.0'},
                {'name':'MCSmear_smear','title':'MCSmear_smear','type':'signal_shape','mode':'smears','mean':'0.0','sigma':'1.0'},
                {'name':'material','title':'material','type':'signal_shape','mode':'scalesCorr','mean':'0.0','sigma':'1.0'},
                {'name':'fnuf','title':'fnuf','type':'signal_shape','mode':'scalesCorr','mean':'0.0','sigma':'1.0'},
]
