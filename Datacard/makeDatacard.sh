#!/usr/bin/env bash

tag=$1
bm=$2

cd /vols/cms/mdk16/ggtt/NonResFinalFits/CMSSW_10_2_13/src/flashggFinalFit
source setup.sh

pushd Datacard
  python makeDatacard.py --years 2016,2017,2018 --ext ${tag}_bm${bm} --prune --pruneThreshold 0.000001 --doSystematics --output Datacard_bm${bm}_unprepared
popd

