import os

#correct xsec of non-SM processes
xsec_corr_bbbb	= { "ggHH_kl_0_kt_1" : 0.023618, "ggHH_kl_1_kt_1" : 0.010517, "ggHH_kl_2p45_kt_1": 0.004455, "ggHH_kl_5_kt_1": 0.031072, "qqHH_CV_0p5_C2V_1_kl_1": 0.003656, "qqHH_CV_1_C2V_0_kl_1": 0.009169, "qqHH_CV_1_C2V_1_kl_0": 0.001558, "qqHH_CV_1_C2V_1_kl_1": 0.000585, "qqHH_CV_1_C2V_1_kl_2": 0.000482, "qqHH_CV_1_C2V_2_kl_1": 0.004823, "qqHH_CV_1p5_C2V_1_kl_1": 0.004823}
xsec_corr_ggtt = {}
for key, value in xsec_corr_bbbb.items():
	value_tmp = 0
	if "ggHH" in key:
		value_tmp = value / xsec_corr_bbbb["ggHH_kl_1_kt_1"]
	elif "qqHH" in key:
		value_tmp = value / xsec_corr_bbbb["qqHH_CV_1_C2V_1_kl_1"]
	xsec_corr_ggtt[key] = value_tmp

#print xsec_corr_ggtt

hgg = 0.00227
htt = 0.0627
hgghtt = 2 * hgg * htt

xsec_corr_eft = {
"ggHHbm1" : 4.4195e-05,
"ggHHbm2" : 3.128122099999997e-06,
"ggHHbm3" : 0.0002341336193,
"ggHHbm4" : 0.0020139330037499997,
"ggHHbm5" : 1.3629737999999998e-05,
"ggHHbm6" : 5.473108799999994e-06,
"ggHHbm7" : 3.442967280000001e-05,
"ggHHbm8" : 3.87148200000001e-05,
"ggHHbm9" : 2.819641000000002e-05,
"ggHHbm10" : 0.00012543093437500009,
"ggHHbm11" : 3.5850983999999996e-05,
"ggHHbm12" : 0.0007834005700000001
}

procs=["ggHHkl0kt1", "ggHHkl1kt1", "ggHHkl2p45kt1", "ggHHkl5kt1", "ggHHkl0kt1WWdilep", "ggHHkl1kt1WWdilep", "ggHHkl2p45kt1WWdilep", "ggHHkl5kt1WWdilep", "ggHHkl0kt1WWsemilep", "ggHHkl1kt1WWsemilep", "ggHHkl2p45kt1WWsemilep", "ggHHkl5kt1WWsemilep", "VBFH", "ggHHbm1", "ggHHbm2", "ggHHbm3", "ggHHbm4", "ggHHbm5", "ggHHbm6", "ggHHbm7", "ggHHbm8", "ggHHbm9", "ggHHbm10", "ggHHbm11", "ggHHbm12"] 
new_procs=["ggHH_kl_0_kt_1", "ggHH_kl_1_kt_1", "ggHH_kl_2p45_kt_1", "ggHH_kl_5_kt_1", "ggHH_kl_0_kt_1", "ggHH_kl_1_kt_1", "ggHH_kl_2p45_kt_1", "ggHH_kl_5_kt_1", "ggHH_kl_0_kt_1", "ggHH_kl_1_kt_1", "ggHH_kl_2p45_kt_1", "ggHH_kl_5_kt_1", "qqH", "ggHHbm1", "ggHHbm2", "ggHHbm3", "ggHHbm4", "ggHHbm5", "ggHHbm6", "ggHHbm7", "ggHHbm8", "ggHHbm9", "ggHHbm10", "ggHHbm11", "ggHHbm12"] 
years = [ '2016', '2017', '2018' ]

bkgs = ['qqH_', 'ttH_', 'ggH_', 'VH_', 'bkg', 'data']
for i in range(len(procs)):
	for year in years:
		if "WWdilep" in procs[i] :
			os.system('sed -i "s/%s_%s_hgg/%s_%s_hgghwwll/g" Datacard.txt'%(procs[i],year,new_procs[i],year))
		elif "WWsemilep" in procs[i] :
			os.system('sed -i "s/%s_%s_hgg/%s_%s_hgghwwql/g" Datacard.txt'%(procs[i],year,new_procs[i],year))
		elif "ggHHbm" in procs[i] :
			os.system('sed -i "s/%s_%s_hgg/%s_%s_hgghtt/g" Datacard.txt'%(procs[i],year,procs[i],year))
		elif procs[i] != "VBFH":
			os.system('sed -i "s/%s_%s_hgg/%s_%s_hgghtt/g" Datacard.txt'%(procs[i],year,new_procs[i],year))
		else:
			os.system('sed -i "s/%s_%s_hgg/%s_%s_hgg/g" Datacard.txt'%(procs[i],year,new_procs[i],year))

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

	'''
	#apply corrections to rate to account for different xsec at different couplings
	rates = [ x.strip() + "	" for x in lines[lrate].split("  ") if x.strip() ]
	for i in range(1,len(rates)):
		if proc1[i].split("_201")[0] in new_procs and "ggHH" in  proc1[i].split("_201")[0] :
			rates[i] = str(float(rates[i]) * xsec_corr_ggtt[proc1[i].split("_201")[0]])  + "	"
	rates += "\n"
	#apply corrections to rate to normalise all xsec to 1fb
	rates = [ x.strip() + "	" for x in lines[lrate].split("  ") if x.strip() ]
	for i in range(1,len(rates)):
		if proc1[i].split("_201")[0] in new_procs and "ggHH" in  proc1[i].split("_201")[0] :
			#print ("applying correction of: ", ( xsec_corr_eft[proc1[i].split("_201")[0]] / hgghtt / 1e-3 ) )
			rates[i] = str(float(rates[i]) / ( xsec_corr_eft[proc1[i].split("_201")[0]] / hgghtt ) * 1e-3 )  + "	"
	rates += "\n"
	'''

	new_lines = lines
	new_lines[lproc+1] = new_proc2
	#new_lines[lrate]	= "".join(rates)		#apply rate correction upstream
	with open('/home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/Datacard.txt', 'w') as datacard:
		for line in new_lines:
			datacard.write(line)

