#!/usr/bin/env bash

set -x

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=18Nov2022_fullRun2
trees=/home/users/fsetti/ic_flashgg/CMSSW_10_2_13/src/flashggFinalFit/files_systs/$tag/

cmsenv
source setup.sh

nToys=500

make_toys(){
	pushd Plots 
		rm -rf SplusBModels$tag
		python makeToys.py --inputWSFile ../Combine/Datacard.root --ext $tag --dryRun --nToys $nToys
		iter=0
		while [ $iter -lt $nToys ]
		do			
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+1)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+2)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+3)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+4)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+5)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+6)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+7)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+8)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$(($iter+9)).sh	&
			./SplusBModels${tag}/toys/jobs/sub_toy_$iter.sh					
			iter=$(($iter+10))
		done
	popd	
}

make_SpB(){
	pushd Plots 
		python makeSplusBModelPlot.py --inputWSFile ../Combine/Datacard_ggtt_resBkg_syst.root --cat "SR1" --doBands --ext $tag --parameterMap ".*/HH2ggtautau.*:r[1,0,2]"

		cp SplusBModels$tag/SR1_CMS_hgg_mass.png /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag/SplusBModels/SR1_CMS_hgg_mass.png
	popd	

}

make_SpB
