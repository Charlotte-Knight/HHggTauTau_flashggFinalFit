import ROOT

f = ROOT.TFile.Open("Models/signal/CMS-HGG_sigfit_packaged_SR1.root")
w = f.Get("wsig_13TeV")

norm = w.obj("hggpdfsmrel_ggf_2018_SR1_13TeV_norm")
xs = w.obj("fxs_ggf_13TeV")
br = w.obj("fbr_13TeV")
ea = w.obj("fea_ggf_2018_SR1_13TeV")
rate = w.obj("rate_ggf_2018_SR1_13TeV")

print ('RooFormulaVar::hggpdfsmrel_ggf_2018_SR1_13TeV_norm[ actualVars=(fxs_ggf_13TeV,fbr_13TeV,fea_ggf_2018_SR1_13TeV,rate_ggf_2018_SR1_13TeV) formula="@0*@1*@2*@3" ] = 0.000122463')
print ("norm: {}".format(norm.getVal()))
print ("xs: {}".format(xs.getVal()))
print ("br: {}".format(br.getVal()))
print ("ea: {}".format(ea.getVal()))
print ("rate: {}".format(rate.getVal()))
