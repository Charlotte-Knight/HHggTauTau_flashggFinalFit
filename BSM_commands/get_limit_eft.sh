#!/usr/bin/env bash

set -x

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=01May2023_EFT
trees=/home/users/fsetti/HHggTauTau/coupling_scan/CMSSW_10_2_13/src/flashggFinalFit/files_systs/$tag/

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
	procs=( "ggHHbm1ggtt" "ggHHbm2ggtt" "ggHHbm3ggtt" "ggHHbm4ggtt" "ggHHbm5ggtt" "ggHHbm6ggtt" "ggHHbm7ggtt" "ggHHbm8aggtt" "ggHHbm8ggtt" "ggHHbm9ggtt" "ggHHbm10ggtt" "ggHHbm11ggtt" "ggHHbm12ggtt" "ggHHbm1ggWWdi" "ggHHbm2ggWWdi" "ggHHbm3ggWWdi" "ggHHbm4ggWWdi" "ggHHbm5ggWWdi" "ggHHbm6ggWWdi" "ggHHbm7ggWWdi" "ggHHbm8aggWWdi" "ggHHbm8ggWWdi" "ggHHbm9ggWWdi" "ggHHbm10ggWWdi" "ggHHbm11ggWWdi" "ggHHbm12ggWWdi" "ggHHbm1ggWWs" "ggHHbm2ggWWs" "ggHHbm3ggWWs" "ggHHbm4ggWWs" "ggHHbm5ggWWs" "ggHHbm6ggWWs" "ggHHbm7ggWWs" "ggHHbm8aggWWs" "ggHHbm8ggWWs" "ggHHbm9ggWWs" "ggHHbm10ggWWs" "ggHHbm11ggWWs" "ggHHbm12ggWWs" "VH" "ggH" "VBFH" "ttH" )
	#procs=( "ttH")

	##for year in 2016 2017 2018
	#for year in 2018
	#do
	#	rm -rf $trees/ws_signal_$year
	#	mkdir -p $trees/ws_signal_$year
	#	for proc in "${procs[@]}"
	#	do

	#		rm -rf $trees/$year/ws_$proc

	#		pushd Trees2WS
  #      python trees2ws.py --inputConfig syst_config_ggtt.py --inputTreeFile $trees/$year/${proc}_125_13TeV.root --inputMass 125 --productionMode $proc --year $year --doSystematics
	#		popd

	#		mv $trees/$year/ws_$proc/${proc}_125_13TeV_$proc.root $trees/ws_signal_$year/output_${proc}_M125_13TeV_pythia8_${proc}.root 

	#	done

  #  pushd Signal
  #   rm -rf outdir_${tag}_$year
  #   sed -i "s/dummy/${tag}/g" syst_config_ggtt_${year}_eft.py

  #   #python RunSignalScripts.py --inputConfig syst_config_ggtt_${year}_eft.py --mode fTest --modeOpts "--doPlots"
  #   python RunSignalScripts.py --inputConfig syst_config_ggtt_${year}_eft.py --mode calcPhotonSyst
  #   python RunSignalScripts.py --inputConfig syst_config_ggtt_${year}_eft.py --mode signalFit --groupSignalFitJobsByCat --modeOpts "--skipVertexScenarioSplit --replacementThreshold 1000 --useDCB "
  #   #python RunSignalScripts.py --inputConfig syst_config_ggtt_${year}_eft.py --mode signalFit --groupSignalFitJobsByCat --modeOpts "--skipVertexScenarioSplit "

  #   sed -i "s/${tag}/dummy/g" syst_config_ggtt_${year}_eft.py
  #  popd
	#done

  pushd Signal
    rm -rf outdir_packaged
    python RunPackager.py --cats SR1 --exts ${tag}_2016,${tag}_2017,${tag}_2018 --batch local --massPoints 125 --mergeYears
    #python RunPlotter.py --procs all --cats SR1 --years 2016,2017,2018 --ext packaged
    python RunPackager.py --cats SR2 --exts ${tag}_2016,${tag}_2017,${tag}_2018 --batch local --massPoints 125 --mergeYears
    #python RunPlotter.py --procs all --cats SR2 --years 2016,2017,2018 --ext packaged
  popd
}

make_datacard(){
	mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards
	mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}_divide4
  pushd Datacard

	 procs=("ggHHbm1" "ggHHbm2" "ggHHbm3" "ggHHbm4" "ggHHbm5" "ggHHbm6" "ggHHbm7" "ggHHbm8" "ggHHbm8a" "ggHHbm9" "ggHHbm10" "ggHHbm11" "ggHHbm12")
	 #procs=("ggHHbm1")
	 for proc in "${procs[@]}"
	 do

		substr="ggHHbm"
		bm_tag=${proc#$substr}

    #python RunYields.py --inputWSDirMap 2016=${trees}/ws_signal_2016,2017=${trees}/ws_signal_2017,2018=${trees}/ws_signal_2018 --cats auto --procs "${proc}ggtt,${proc}ggWWdi,${proc}ggWWs,ggH,ttH,VH,VBFH" --batch local --mergeYears --ext ${tag}"_bm"${bm_tag} --doSystematics --skipZeroes 
    python makeDatacard.py --years 2016,2017,2018 --ext ${tag}"_bm"${bm_tag}  --prune --pruneThreshold 0.000000001 --doSystematics
	  python prepareDatacard_eft.py			#divide by 4 since we are using 4 NLO samples to generate the reweighting and need to scale by 1/N to maintain normalisation
		mv Datacard_updated.txt /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}_divide4/datacard_${bm_tag}.txt
	 done
  popd
}

copy_files(){
		mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/
		mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/signal/
		mkdir -p /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/background/

		cp Signal/outdir_packaged/CMS-HGG*.root /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/signal/
		cp Background/outdir_$tag/CMS-HGG*.root /home/users/fsetti/HHggTauTau/inference/datacards_run2/ggtt/EFT_cards/${tag}/Models/background/
}

#model_bkg
#model_sig
make_datacard
#copy_files
