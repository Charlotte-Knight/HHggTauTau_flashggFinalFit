#!/usr/bin/env bash

#set -x

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=SplitUncert_Paper_EFT

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
	procs=("HHggTauTau1" "HHggTauTau3" "HHggTauTau2" "HHggWWdileptonic12" "HHggTauTau4" "HHggWWdileptonic10" "HHggWWdileptonic11" "HHggTauTau9" "HHggTauTau8" "HHggWWdileptonic8a" "HHggTauTau5" "HHggTauTau7" "HHggTauTau6" "HHggWWdileptonic4" "HHggWWdileptonic5" "HHggWWdileptonic6" "HHggWWdileptonic7" "HHggWWdileptonic1" "HHggWWdileptonic2" "HHggWWdileptonic3" "HHggWWdileptonic8" "HHggWWdileptonic9" "HHggWWsemileptonic8a" "HHggTauTau11" "HHggTauTau10" "HHggTauTau12" "HHggWWsemileptonic11" "HHggWWsemileptonic10" "HHggWWsemileptonic12" "HHggWWsemileptonic9" "HHggWWsemileptonic8" "HHggTauTau8a" "HHggWWsemileptonic1" "HHggWWsemileptonic3" "HHggWWsemileptonic2" "HHggWWsemileptonic5" "HHggWWsemileptonic4" "HHggWWsemileptonic7" "HHggWWsemileptonic6" "VH" "ttH" "ggH" "VBFH")
	#procs=("HHggTauTau1" "HHggWWsemileptonic1" "HHggWWdileptonic1" "VH" "ttH" "ggH" "VBFH" ) 
	years=("2016" "2017" "2018")
	#years=("2018")

	for year in "${years[@]}"; do
	  rm -rf $trees/ws_signal_$year
		mkdir -p $trees/ws_signal_$year
		for proc in "${procs[@]}"; do

			rm -rf $trees/$year/ws_$proc
			pushd Trees2WS
			  mkdir -p logs
				qsub -l h_vmem=24G -o ${PWD}/logs/trees2ws_${tag}_${proc}_${year}.out -e ${PWD}/logs/trees2ws_${tag}_${proc}_${year}.err trees2ws.sh $trees $proc $year
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
		done

		sleep 5
		wait_batch sub_calcPhotonSyst

		for year in "${years[@]}"; do
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
		#python RunPlotter.py --procs HHggTauTaukl1,HHggWWdileptonickl1,HHggWWsemileptonickl1 --cats SR1 --years 2016,2017,2018 --ext packaged
		#python RunPlotter.py --procs HHggTauTaukl1,HHggWWdileptonickl1,HHggWWsemileptonickl1 --cats SR2 --years 2016,2017,2018 --ext packaged
	popd
}

make_datacard(){
	pushd Datacard
	  bms=("1" "2" "3" "4" "5" "6" "7" "8" "8a" "9" "10" "11" "12")
		#bms=("1")
	 
	  for bm in "${bms[@]}" ; do
			rm -rf yields_$tag_bm${bm}

			python RunYields.py --inputWSDirMap 2016=${trees}/ws_signal_2016,2017=${trees}/ws_signal_2017,2018=${trees}/ws_signal_2018 --cats auto --procs HHggTauTau${bm},HHggWWdileptonic${bm},HHggWWsemileptonic${bm},ggH,ttH,VH,VBFH --batch IC --mergeYears --ext ${tag}_bm${bm} --doSystematics --skipZeroes
		done

		sleep 5
		wait_batch sub_yields

	 for bm in "${bms[@]}" ; do		
		mkdir -p logs
		#bash makeDatacard.sh $tag $bm
		qsub -o ${PWD}/logs/${tag}_${bm}.out -e ${PWD}/logs/${tag}_${bm}.err -l h_vmem=24G makeDatacard.sh $tag $bm
	 done

	 sleep 5
	 wait_batch makeDatacard


	for bm in "${bms[@]}" ; do		
		python prepareDatacard_EFT.py Datacard_bm${bm}_unprepared.txt datacard_${bm}.txt
	done
		
  popd
}

copy_files(){
		mkdir -p ${tag}
		cp Datacard/datacard*.txt ${tag}/
		mkdir -p ${tag}/shapes
		cp Background/outdir_$tag/CMS-HGG*.root ${tag}/shapes
		cp Signal/outdir_packaged/CMS-HGG*.root ${tag}/shapes

		# mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/
		# mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/signal/
		# mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/background/

		# cp Signal/outdir_packaged/CMS-HGG*.root /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/signal/
		# cp Background/outdir_$tag/CMS-HGG*.root /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/background/
}

run_limits(){
	pushd ${tag}
	bms=("1" "2" "3" "4" "5" "6" "7" "8" "8a" "9" "10" "11" "12")
	#bms=("1")
		
	for bm in "${bms[@]}" ; do
		text2workspace.py datacard_${bm}.txt -m ${mh} higgsMassRange=100,180
		combine --redefineSignalPOI r --cminDefaultMinimizerStrategy 0 --X-rtd MINIMIZER_freezeDisassociatedParams --X-rtd MINIMIZER_multiMin_hideConstants --X-rtd MINIMIZER_multiMin_maskConstraints --X-rtd MINIMIZER_multiMin_maskChannels=2 -M AsymptoticLimits -m ${mh} -d datacard_${bm}.root --freezeParameters MH -n _bm${bm}
	done
}

#model_bkg
#model_sig
#make_datacard
copy_files
run_limits
