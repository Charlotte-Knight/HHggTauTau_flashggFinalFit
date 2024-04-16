#!/usr/bin/env bash

#set -x
#set -e

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=SplitUncert_TauID_fix_rerun

trees=/vols/cms/mdk16/ggtt/NonResFinalFits/CMSSW_10_2_13/src/flashggFinalFit/Trees_${tag}

mh=125.38

cmsenv
source setup.sh

wait_batch() {
  while [[ -n $(qstat -xml | grep "${1}") ]]; do
    echo $(qstat -xml | grep "${1}" | wc -l) "batch jobs remaining..."
    echo $(qstat -xml -s r | grep "${1}" | wc -l) "batch jobs running..."
    sleep 10
  done
}

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
	#procs=("HHggTauTaukl1" "HHggWWdileptonickl1" "HHggWWsemileptonickl1" "VH" "ttH" "ggH" "VBFH")
	procs=("HHggTauTaukl1")
	#procs=("HHggWWdileptonic")
	#years=("2016" "2017" "2018")
        years=("2016")

	for year in "${years[@]}"; do
	  rm -rf $trees/ws_signal_$year
		mkdir -p $trees/ws_signal_$year
		for proc in "${procs[@]}"; do

			rm -rf $trees/$year/ws_$proc
			pushd Trees2WS
			  mkdir -p logs
				qsub -o ${PWD}/logs/trees2ws_${tag}_${proc}_${year}.out -e ${PWD}/logs/trees2ws_${tag}_${proc}_${year}.err trees2ws.sh $trees $proc $year
				#bash trees2ws.sh $trees $proc $year
			popd
		done
	done

	wait_batch trees2ws

	pushd Signal
		for year in "${years[@]}"; do
			rm -rf outdir_${tag}_$year
			sed -i "s/dummy/${tag}/g" syst_config_ggtt_$year.py
			python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode calcPhotonSyst
			#python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode fTest --modeOpts "--doPlots"
		done

		sleep 5
		wait_batch sub_fTest

		for year in "${years[@]}"; do
		  #python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode signalFit --groupSignalFitJobsByCat --modeOpts "--skipVertexScenarioSplit --replacementThreshold 1000 --skipSystematics" 
			python RunSignalScripts.py --inputConfig syst_config_ggtt_$year.py --mode signalFit --modeOpts "--skipVertexScenarioSplit --replacementThreshold 1000 --useDCB" 
		done

		sleep 5
		wait_batch sub_

		for year in "${years[@]}"; do
			sed -i "s/${tag}/dummy/g" syst_config_ggtt_$year.py
		done

		rm -rf outdir_packaged
		python RunPackager.py --cats SR1 --exts ${tag}_2016,${tag}_2017,${tag}_2018 --batch local --massPoints 125 --mergeYears
		python RunPackager.py --cats SR2 --exts ${tag}_2016,${tag}_2017,${tag}_2018 --batch local --massPoints 125 --mergeYears
		python RunPlotter.py --procs HHggTauTaukl1,HHggWWdileptonickl1,HHggWWsemileptonickl1 --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggTauTaukl1,HHggWWdileptonickl1,HHggWWsemileptonickl1 --cats SR2 --years 2016,2017,2018 --ext packaged

		python RunPlotter.py --procs HHggTauTaukl1 --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggTauTaukl1 --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWdileptonickl1 --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWdileptonickl1 --cats SR2 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWsemileptonickl1 --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggWWsemileptonickl1 --cats SR2 --years 2016,2017,2018 --ext packaged
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
	 rm Datacard_$tag.txt
	 mv Datacard.txt Datacard_$tag.txt

	popd
}

run_combine(){
	pushd Combine
		rm -rf Models
		mkdir -p Models
		mkdir -p Models/signal
		mkdir -p Models/background
		cp ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
		cp ../Background/outdir_$tag/CMS-HGG*.root ./Models/background/
		cp ../Datacard/Datacard_$tag.txt .
	
		text2workspace.py Datacard_${tag}.txt -o Datacard_${tag}.root -m 125.38 higgsMassRange=122,128
		#./t2w_jobs/t2w_ggtt_resBkg_syst.sh

		magic="--cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"

		combine --redefineSignalPOI r $magic -M AsymptoticLimits -m $mh -d Datacard_${tag}.root -n _AsymptoticLimit_r --freezeParameters MH > combine_results_${tag}.txt
		combine --redefineSignalPOI r $magic -M AsymptoticLimits -m $mh -d Datacard_${tag}.root -n _AsymptoticLimit_r --freezeParameters MH,QCDscale_ggHH,pdf_Higgs_ggHH > combine_results_${tag}_no_ggHH_theory.txt
		combine --redefineSignalPOI r $magic -M AsymptoticLimits -m $mh -d Datacard_${tag}.root -n _AsymptoticLimit_r --freezeParameters MH,allConstrainedNuisances > combine_results_${tag}_no_sys.txt

		#combine --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 -M AsymptoticLimits -m 125 -d Datacard_ggtt_resBkg_syst.root -n _AsymptoticLimit_r --freezeParameters MH --run=expected > combine_results_${tag}.txt
		#combine --expectSignal 1 -t -1 --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 -M MultiDimFit --algo grid --points 100 -m 125 -d Datacard_ggtt_resBkg_syst.root -n _Scan_r --freezeParameters MH --rMin 15 --rMax 27 > combine_results_${tag}_scan.txt
		#python plotLScan.py higgsCombine_Scan_r.MultiDimFit.mH125.root
		#cp NLL_scan* /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/

		#tail combine_results_${tag}.txt
		#tail combine_results_${tag}_scan.txt
	popd	
}

syst_plots(){
	pushd Combine
		magic="--cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2"

		# index_names=$(grep 'discrete' Datacard.txt | cut -d' ' -f1 | sed -z 's/\n/,/g')
    # combine -t -1 --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 $magic -M MultiDimFit -m ${mh} --rMin 0 --rMax 100 -d Datacard_ggtt_resBkg_syst.root -n _find_indices --freezeParameters MH,r --setParameters r=22.5 --saveSpecifiedIndex $index_names
    # index_values=$(python getSavedIndices.py higgsCombine_find_indices.MultiDimFit.mH${mh}.root)

		# combineTool.py -t -1 --setParameters r=22.5${index_values} -M Impacts -d Datacard_ggtt_resBkg_syst.root --redefineSignalPOI r --rMin 0 --rMax 100 --cminDefaultMinimizerStrategy 0 $magic -m $mh --freezeParameters MH --doInitialFit #--robustFit 1 --robustHesse 1
		# combineTool.py -t -1 --setParameters r=22.5${index_values} -M Impacts -d Datacard_ggtt_resBkg_syst.root --redefineSignalPOI r --rMin 0 --rMax 100 --cminDefaultMinimizerStrategy 0 $magic -m $mh --freezeParameters MH --doFits --parallel 10 #--robustFit 1  --robustHesse 1
		# combineTool.py -M Impacts -d Datacard_ggtt_resBkg_syst.root $magic -m $mh -o impacts_expected.json 
		# plotImpacts.py -i impacts_expected.json -o impacts_expected
		# rm higgsCombine_*

		index_names=$(grep 'discrete' Datacard.txt | cut -d' ' -f1 | sed -z 's/\n/,/g')
    combine --redefineSignalPOI r $magic -M MultiDimFit -m ${mh} --rMin 0 --rMax 100 -d Datacard_${tag}.root -n _find_indices --freezeParameters MH,r --setParameters r=29.9 --saveSpecifiedIndex $index_names
    index_values=$(python getSavedIndices.py higgsCombine_find_indices.MultiDimFit.mH${mh}.root)

		combineTool.py --setParameters r=29.9${index_values} -M Impacts -d Datacard_${tag}.root --redefineSignalPOI r --rMin 0 --rMax 100 $magic -m $mh --freezeParameters MH --doInitialFit #--robustFit 1 --robustHesse 1
		combineTool.py --setParameters r=29.9${index_values} -M Impacts -d Datacard_${tag}.root --redefineSignalPOI r --rMin 0 --rMax 100 $magic -m $mh --freezeParameters MH --doFits --parallel 10 #--robustFit 1  --robustHesse 1
		combineTool.py -M Impacts -d Datacard_${tag}.root $magic -m $mh -o impacts_observed.json 
		plotImpacts.py -i impacts_observed.json -o impacts_observed
		rm higgsCombine_*

		#mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/
		#cp impacts.pdf /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/$tag/impacts.pdf
	popd	
}

copy_plot(){
	mkdir -p ${tag}
	mkdir -p $tag/Data
	mkdir -p ${tag}/Signal
	mkdir -p ${tag}/Results
	mkdir -p ${tag}/Impacts
	mkdir -p ${tag}/Combine/Models
	
	cp Background/outdir_$tag/bkgfTest-Data/* $tag/Data
	cp Signal/outdir_packaged/Plots/* ${tag}/Signal
	cp Combine/combine_results* ${tag}/Results
	cp Combine/impacts* ${tag}/Impacts
	cp Combine/Datacard_${tag}* ${tag}/Combine
	cp -r Combine/Models ${tag}/Combine/Models
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
			mv Datacard.txt ../Combine/Datacard.txt

		popd

		pushd Combine
			text2workspace.py Datacard_${tag}.txt -o Datacard_${tag}.root -m 125.38 higgsMassRange=122,128
			#python RunText2Workspace.py --mode  ggtt_resBkg_syst --dryRun
			#./t2w_jobs/t2w_ggtt_resBkg_syst.sh
			#mv Datacard_ggtt_resBkg_syst.root Datacard_${sr}.root

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
model_sig
#make_datacard
#run_combine
#syst_plots
#copy_plot
#bias_study
