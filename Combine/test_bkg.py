import ROOT

f = ROOT.TFile.Open("Models/background/CMS-HGG_multipdf_SR1.root")
w = f.Get("multipdf")

norm = w.obj("CMS_hgg_SR1_13TeV_bkgshape_norm")

print ("norm: {}".format(norm.getVal()))
