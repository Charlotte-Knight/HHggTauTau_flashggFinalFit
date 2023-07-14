#!/usr/bin/env bash

set -x

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=09May2023_nonRes_SM_final
trees=/home/users/fsetti/ic_flashgg/CMSSW_10_2_13/src/flashggFinalFit/files_systs/$tag/

cmsenv
source setup.sh

model_bkg(){
	pushd Trees2WS
	 python trees2ws_data.py --inputConfig syst_config_ggtt.py --inputTreeFile $trees/Data/allData.root
	popd
	
	pushd Background
	 	rm -rf outdir_$tag
		sed -i "s/dummy/${tag}/g" config_ggtt.py 

	  python RunBackgroundScripts.py --inputConfig config_ggtt.py --mode fTestParallel

		sed -i "s/${tag}/dummy/g" config_ggtt.py
	popd
}

#Construct Signal Models (one per year)
model_sig(){
	procs=("HHggTauTau" "HHggWWdileptonic" "HHggWWsemileptonic" "VH" "ttH" "ggH" "VBFH")
	#procs=("ttH")

	for year in 2016 2017 2018
	#for year in 2018
	do
		rm -rf $trees/ws_signal_$year
		mkdir -p $trees/ws_signal_$year
		for proc in "${procs[@]}"
		do

			rm -rf $trees/$year/ws_$proc

			pushd Trees2WS
				python trees2ws.py --inputConfig syst_config_ggtt.py --inputTreeFile $trees/$year/${proc}_125_13TeV.root --inputMass 125 --productionMode $proc --year $year --doSystematics
			popd

			mv $trees/$year/ws_$proc/${proc}_125_13TeV_$proc.root $trees/ws_signal_$year/output_${proc}_M125_13TeV_pythia8_${proc}.root 

		done

		pushd Signal	
		 rm -rf outdir_${tag}_$year
		 sed -i "s/dummy/${tag}/g" syst_config_ggtt_$year.py

     #python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode fTest --modeOpts "--doPlots"
		 python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode calcPhotonSyst
		 python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode signalFit --groupSignalFitJobsByCat --modeOpts "--skipVertexScenarioSplit --replacementThreshold 1000 --useDCB "
		 #python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode signalFit --groupSignalFitJobsByCat --modeOpts "--skipVertexScenarioSplit --replacementThreshold 1000 "

		 sed -i "s/${tag}/dummy/g" syst_config_ggtt_$year.py
		popd
	done

	pushd Signal	
		rm -rf outdir_packaged
		python RunPackager.py --cats SR1 --exts ${tag}_2016,${tag}_2017,${tag}_2018 --batch local --massPoints 125 --mergeYears
		python RunPackager.py --cats SR2 --exts ${tag}_2016,${tag}_2017,${tag}_2018 --batch local --massPoints 125 --mergeYears
		python RunPlotter.py --procs HHggTauTau --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggTauTau --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWdileptonic --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWdileptonic --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWsemileptonic --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWsemileptonic --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs VH --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs VH --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs ttH --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs ttH --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs ggH --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs ggH --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs VBFH --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs VBFH --cats SR2 --years 2016,2017,2018 --ext packaged
	popd
}

make_datacard(){
	pushd Datacard
	 rm -rf yields_$tag

	 python RunYields.py --inputWSDirMap 2016=${trees}/ws_signal_2016,2017=${trees}/ws_signal_2017,2018=${trees}/ws_signal_2018 --cats auto --procs auto --batch local --mergeYears --ext $tag --doSystematics --skipZeroes 
	 python makeDatacard.py --years 2016,2017,2018 --ext $tag --prune --pruneThreshold 0.000001 --doSystematics
	 mv Datacard.txt Datacard_$tag.txt

	popd
}

run_combine(){
	pushd Combine
		#rm -rf Models
		#mkdir -p Models
		#mkdir -p Models/signal
		#mkdir -p Models/background
		#cp ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
		#cp ../Background/outdir_$tag/CMS-HGG*.root ./Models/background/
		#cp ../Datacard/Datacard_$tag.txt Datacard.txt
	
		#python RunText2Workspace.py --mode  ggtt_resBkg_syst --dryRun
		#./t2w_jobs/t2w_ggtt_resBkg_syst.sh

		combine --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 -M AsymptoticLimits -m 125 -d Datacard_ggtt_resBkg_syst.root -n _AsymptoticLimit_r --freezeParameters MH > combine_results_${tag}_unblind_06072023.txt

		combine --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 -M AsymptoticLimits -m 125 -d Datacard_ggtt_resBkg_syst.root -n _AsymptoticLimit_r --freezeParameters MH --run=expected > combine_results_${tag}.txt
		#combine --expectSignal 1 -t -1 --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 -M MultiDimFit --algo grid --points 100 -m 125 -d Datacard_ggtt_resBkg_syst.root -n _Scan_r --freezeParameters MH --rMin 15 --rMax 27 > combine_results_${tag}_scan.txt
		#python plotLScan.py higgsCombine_Scan_r.MultiDimFit.mH125.root
		#cp NLL_scan* /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/

		#tail combine_results_${tag}.txt
		#tail combine_results_${tag}_scan.txt
	popd	
}

syst_plots(){
	pushd Combine
	
		#text2workspace.py Datacard.txt -m 125

		#combineTool.py  -t -1 --setParameters r=23 -M Impacts -d Datacard.root --redefineSignalPOI r --autoMaxPOIs "r" --rMin -40 --rMax 100 --squareDistPoiStep --cminDefaultMinimizerStrategy 0 -m 125 --freezeParameters MH --doInitialFit --robustFit 1 --robustHesse 1
		#combineTool.py  -t -1 --setParameters r=23 -M Impacts -d Datacard.root --redefineSignalPOI r --autoMaxPOIs "r" --rMin -40 --rMax 100 --squareDistPoiStep --cminDefaultMinimizerStrategy 0 -m 125 --freezeParameters MH --robustFit 1   --robustHesse 1 --doFits --parallel 10

		combineTool.py  --setParameters r=25 -M Impacts -d Datacard_ggtt_resBkg_syst.root --redefineSignalPOI r --autoMaxPOIs "r" --rMin -40 --rMax 100 --squareDistPoiStep --cminDefaultMinimizerStrategy 0 -m 125 --freezeParameters MH --doInitialFit --robustFit 1 --robustHesse 1
		combineTool.py  --setParameters r=25 -M Impacts -d Datacard_ggtt_resBkg_syst.root --redefineSignalPOI r --autoMaxPOIs "r" --rMin -40 --rMax 100 --squareDistPoiStep --cminDefaultMinimizerStrategy 0 -m 125 --freezeParameters MH --robustFit 1   --robustHesse 1 --doFits --parallel 10

		combineTool.py -M Impacts -d Datacard_ggtt_resBkg_syst.root --redefineSignalPOI r --autoMaxPOIs "r" --rMin -40 --rMax 100 --squareDistPoiStep --cminDefaultMinimizerStrategy 0 -m 125 --freezeParameters MH -o impacts.json 

		plotImpacts.py -i impacts.json -o impacts --blind
		mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/
		cp impacts.pdf /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/impacts.pdf
	popd	
}

copy_plot(){
	mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/${tag}
	mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/Data
	mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/${tag}/Signal

	cp /home/users/fsetti/public_html/HH2ggtautau/niceplots/index.php /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/Data
	cp Background/outdir_$tag/bkgfTest-Data/* /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/Data
	cp Signal/outdir_packaged/Plots/* /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/${tag}/Signal
	cp /home/users/fsetti/public_html/HH2ggtautau/niceplots/index.php /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/${tag}/Signal
}

bias_study(){

	mkdir -p /home/users/fsetti/public_html/HH2ggtautau/bias_study/${tag}
	mkdir -p /home/users/fsetti/public_html/HH2ggtautau/bias_study/${tag}/${sr}

	pushd Combine
		rm -rf Models
		mkdir -p Models
		mkdir -p Models/signal
		mkdir -p Models/background
		cp ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
		cp ../Background/outdir_$tag/CMS-HGG*.root ./Models/background/
	popd

	srs=("SR1" "SR2")
	#srs=("SR1")
	for sr in "${srs[@]}"
	do
		pushd Datacard	
			rm -rf yields_${tag}_${sr}
			python RunYields.py --inputWSDirMap 2016=${trees}/ws_signal_2016,2017=${trees}/ws_signal_2017,2018=${trees}/ws_signal_2018 --cats ${sr} --procs auto --batch local --mergeYears --skipZeroes --ext ${tag}_${sr} --doSystematics 
			python makeDatacard.py --years 2016,2017,2018 --ext ${tag}_${sr} --prune --pruneThreshold 0.00001 --doSystematics
			#python prepareDatacard.py
			#mv Datacard_tmp.txt ../Combine/Datacard_${sr}.txt
			#mv Datacard.txt ../Combine/Datacard_${sr}.txt
			mv Datacard.txt ../Combine/Datacard.txt

		popd

		pushd Combine
			#text2workspace.py Datacard_${sr}.txt -m 125
			python RunText2Workspace.py --mode  ggtt_resBkg_syst --dryRun
			./t2w_jobs/t2w_ggtt_resBkg_syst.sh
			mv Datacard_ggtt_resBkg_syst.root Datacard_${sr}.root

			cd bias_study

			rm -rf Bias*

			./RunBiasStudy.py -d ../Datacard_${sr}.root -t -n 10000 -e 23
			#./RunBiasStudy.py -d ../Datacard_${sr}.root -f -c "--cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2 --freezeParameters MH --rMin -100 --rMax 100" -n 5000 -e 23
			./RunBiasStudy.py -d ../Datacard_${sr}.root -f -c "--cminDefaultMinimizerStrategy 0 --freezeParameters MH --rMin -40 --rMax 100" -n 10000 -e 23
			./RunBiasStudy.py -d ../Datacard_${sr}.root -p --gaussianFit -n 10000 -e 23

			cp -r BiasPlots /home/users/fsetti/public_html/HH2ggtautau/bias_study/${tag}/${sr}/
			cp /home/users/fsetti/public_html/HH2ggtautau/niceplots/index.php /home/users/fsetti/public_html/HH2ggtautau/bias_study/${tag}/${sr}/

			cd ..
		popd
	done
}


#model_bkg
#model_sig
#make_datacard
run_combine
#syst_plots
#copy_plot
#bias_study
