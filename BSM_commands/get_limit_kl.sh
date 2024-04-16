#!/usr/bin/env bash

#set -x

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=SplitUncert_TauID_fix_kl_rerun
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
	procs=("HHggTauTaukl1" "HHggTauTaukl2p45" "HHggTauTaukl5" "HHggWWdileptonickl1" "HHggWWdileptonickl2p45" "HHggWWdileptonickl5" "HHggWWsemileptonickl1" "HHggWWsemileptonickl2p45" "HHggWWsemileptonickl5" "VH" "ttH" "ggH" "VBFH")
	#procs=("VBFH" "ttH" "HHggTauTaukl1")

	years=("2016" "2017" "2018")

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

    python RunPlotter.py --procs HHggTauTaukl1 --cats SR1 --years 2016,2017,2018 --ext packaged
		python RunPlotter.py --procs HHggTauTaukl1 --cats SR2 --years 2016,2017,2018 --ext packaged
	popd
}

make_datacard(){
  pushd Datacard
   rm -rf yields_$tag

   python RunYields.py --inputWSDirMap 2016=${trees}/ws_signal_2016,2017=${trees}/ws_signal_2017,2018=${trees}/ws_signal_2018 --cats auto --procs auto --batch local --mergeYears --ext $tag --skipZeroes --doSystematics 
   python makeDatacard.py --years 2016,2017,2018 --ext $tag --prune --pruneThreshold 0.000000001 --doSystematics
   cp Datacard.txt Datacard_${tag}.txt
	 cp Datacard_${tag}.txt Datacard_${tag}_unprepared.txt
	 python prepareDatacard2.py Datacard_${tag}.txt Datacard_${tag}.txt
  popd
}

copy_plot(){
	pushd Combine
		rm -rf Models
		mkdir -p Models
		mkdir -p Models/signal
		mkdir -p Models/background
		cp ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
		cp ../Background/outdir_$tag/CMS-HGG*.root ./Models/background/
		cp ../Datacard/Datacard_$tag.txt .
	popd

	mkdir -p ${tag}
	mkdir -p $tag/Data
	mkdir -p ${tag}/Signal
	mkdir -p ${tag}/Combine/Models
	
	cp Background/outdir_$tag/bkgfTest-Data/* $tag/Data
	cp Signal/outdir_packaged/Plots/* ${tag}/Signal
	cp Combine/Datacard_${tag}* ${tag}/Combine
	cp -r Combine/Models ${tag}/Combine/Models
}

model_bkg
model_sig
make_datacard
copy_plot
