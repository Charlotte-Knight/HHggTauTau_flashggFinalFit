#!/bin/bash

cd /home/users/fsetti/ic_flashgg/CMSSW_10_2_13/src/flashggFinalFit/Combine

eval `scramv1 runtime -sh`

text2workspace.py Datacard.txt -o Datacard_ggtt_resBkg.root -m 125 higgsMassRange=122,128 -P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel   --PO "map=.*/HH2ggtautau.*:r[1,0,2]"