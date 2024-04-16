#!/bin/bash

cd /vols/cms/mdk16/ggtt/NonResFinalFits/CMSSW_10_2_13/src/flashggFinalFit/Combine

eval `scramv1 runtime -sh`

text2workspace.py Datacard.txt -o Datacard_ggtt_resBkg_syst.root -m 125 higgsMassRange=122,128 -P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel   --PO "map=.*/HHgg*.*:r[1,0,30]"