import os

procs=["HHggTauTau", "HHggWWdileptonic", "HHggWWsemileptonic", "VBFH", "VH", "ggH", "ttH"] 
new_procs=["HHggTauTau", "HHggWWdileptonic", "HHggWWsemileptonic", "qqH", "VH", "ggH", "ttH"] 
years = [ '2016', '2017', '2018' ]

bkgs = ['qqH_', 'ttH_', 'ggH_', 'VH_', 'bkg', 'data', 'VBFH']

with open('Datacard.txt', 'r') as file:
	lines = file.readlines()
	lproc = -1
	for i in range(len(lines)-1):
		if "process" in lines[i].split("	")[0] and "process" in lines[i+1].split("  ")[0]:
			lproc = i
	lrate = lproc + 2
	bkg_idx = []
	bkg_n = [ n.strip() for n in lines[lproc].split("  ") if any( substring in n for substring in bkgs ) ]
	proc1 = [ x.strip() for x in lines[lproc].split("  ") if x.strip() ]
	for i in range(len(proc1)):
		if proc1[i] in bkg_n:
			bkg_idx += [ i ]
	new_proc2 = "process	"
	sig_proc_id = -1
	bkg_proc_id = 1
	for i in range(1,len(proc1)):
		if i in bkg_idx:
			new_proc2 +=str( bkg_proc_id )
			new_proc2 += "	"
			bkg_proc_id += 1
		else:
			new_proc2 +=str( sig_proc_id )
			new_proc2 += "	"
			sig_proc_id -= 1
	new_proc2 += "\n"

	#apply corrections to rate to account for different xsec at different couplings
	rates = [ x.strip() + "	" for x in lines[lrate].split("  ") if x.strip() ]
	for i in range(1,len(rates)):
		if proc1[i].split("_201")[0] in new_procs and "ggHH" in  proc1[i].split("_201")[0] :
			rates[i] = str(float(rates[i]) * xsec_corr_ggtt[proc1[i].split("_201")[0]])  + "	"
	rates += "\n"
	#apply corrections to rate to normalise all xsec to 1fb
	rates = [ x.strip() + "	" for x in lines[lrate].split("  ") if x.strip() ]
	for i in range(1,len(rates)):
		if proc1[i].split("_201")[0] in new_procs and "HHgg" in  proc1[i].split("_201")[0] :
			#print ("applying correction of: ", ( xsec_corr_eft[proc1[i].split("_201")[0]] / hgghtt / 1e-3 ) )
			rates[i] = str(float(rates[i]) * 1 )  + "	"
	rates += "\n"

	new_lines = lines
	new_lines[lproc+1] = new_proc2
	new_lines[lrate]	= "".join(rates)		#apply rate correction upstream
	with open('Datacard_tmp.txt', 'w') as datacard:
		for line in new_lines:
			datacard.write(line)

