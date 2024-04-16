#!/usr/bin/env bash

trees=$1
proc=$2
year=$3

cd /vols/cms/mdk16/ggtt/NonResFinalFits/CMSSW_10_2_13/src/flashggFinalFit/
source setup.sh
cd Trees2WS

#python trees2ws.py --inputConfig syst_config_ggtt.py --inputTreeFile $trees/$year/${proc}_125_13TeV.root --inputMass 125 --productionMode $proc --year $year --doSystematics
python trees2ws_new.py $trees/$year/${proc}_125_13TeV.root $trees/ws_signal_$year/output_${proc}_M125_13TeV_pythia8_${proc}.root 
#mv $trees/$year/ws_$proc/${proc}_125_13TeV_$proc.root $trees/ws_signal_$year/output_${proc}_M125_13TeV_pythia8_${proc}.root 