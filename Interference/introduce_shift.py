import ROOT
import sys
import numpy as np

f=ROOT.TFile(sys.argv[1], "read")
w = f.Get("wsig_13TeV")
w.Print()

dm_original = w.function("dm_dcb_HHggTauTaukl1_2016_SR1_13TeV")

GammaH = ROOT.RooRealVar("GammaH", "GammaH", 0.0)

# create spline for GammaH dependence
# this will need to be replaced with the actual model
x = np.linspace(0, 1, 100)
y = x**2
width_spline = ROOT.RooSpline1D("width_spline", "width_spline", GammaH, len(x), x, y)

# just test the spline works
for xi in x:
 GammaH.setVal(xi)
 width_spline.Print()

# create new dm shift which is MH + GammaH dependence
dm_shift = ROOT.RooFormulaVar("dm_shift_dcb_HHggTauTaukl1_2016_SR1_13TeV", "dm_shift_HHggTauTaukl1_2016_SR1_13TeV", "@0 + @1", ROOT.RooArgList(dm_original, width_spline))
imp = getattr(w, "import")
imp(dm_shift, ROOT.RooFit.RecycleConflictNodes())

# use w.factory to create a new signal model with GammaH dependence included
original_model_name = "hggpdfsmrel_HHggTauTaukl1_2016_SR1_13TeV"
new_model_name = "hggpdfsmrel_shift_HHggTauTaukl1_2016_SR1_13TeV"

original_dm_name = "dm_dcb_HHggTauTaukl1_2016_SR1_13TeV"
new_dm_name = "dm_shift_dcb_HHggTauTaukl1_2016_SR1_13TeV"

factory_string = "EDIT::%s(%s, %s=%s )"%(new_model_name, original_model_name, original_dm_name, new_dm_name)
print(factory_string)
w.factory(factory_string)

# print out workspace again
w.Print()

# the new dcb mean is called "mean_dcb_HHggTauTaukl1_2016_SR1_13TeV_hggpdfsmrel_shift_HHggTauTaukl1_2016_SR1_13TeV"
# how does that change as a function of GammaH?
for xi in x:
  w.var("GammaH").setVal(xi)
  print(xi, w.function("mean_dcb_HHggTauTaukl1_2016_SR1_13TeV_hggpdfsmrel_shift_HHggTauTaukl1_2016_SR1_13TeV").getVal())

w.writeToFile("new_model.root")
