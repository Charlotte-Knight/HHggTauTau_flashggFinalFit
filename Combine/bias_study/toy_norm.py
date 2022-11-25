import ROOT
import glob

files = glob.glob("BiasToys/*.root")
nToys	= 500

files = [ f for f in files if "split1" not in f ]
for f in files:

	toy_name = f.split("BiasToys/biasStudy_")[-1].split("_split")[0]
	h = ROOT.TH1D("%s" %(toy_name),"bkg events toy: %s" %(toy_name),80 ,200,60)

	#split0
	f = ROOT.TFile.Open(f)
	toys = f.GetDirectory("toys")
	for i in range(nToys):
		try:
			toy	= toys.Get("toy_%s"%(str(i+1)))
			h.Fill(toy.sumEntries())
		except:
			continue
	f.Close()

	#split1
	f = ROOT.TFile.Open(f.GetName().replace("split0","split1"))
	toys = f.GetDirectory("toys")
	for i in range(nToys):
		try:
			toy	= toys.Get("toy_%s"%(str(i+1)))
			h.Fill(toy.sumEntries())
		except:
			continue
	c = ROOT.TCanvas()
	c.cd()
	h.Draw()
	c.SaveAs("/home/users/fsetti/public_html/HH2ggtautau/bias_study/numEntries/SR1/%s.png"%(toy_name))
	c.Close()
