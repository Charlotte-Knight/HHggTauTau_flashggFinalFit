#!/usr/bin/env bash

set -x

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /vols/grid/cms/setup.sh

tag=09May2023_nonRes_SM_bkgOnly

cmsenv
source setup.sh

nToys=500

make_toys(){
	pushd Plots 
		rm -rf SplusBModels$tag
		python makeToys.py --inputWSFile ../Combine/Datacard_bkgOnly.root --ext $tag --dryRun --nToys $nToys
		#python makeToys.py --inputWSFile ../Combine/Datacard_ggtt_resBkg_syst.root --ext $tag --dryRun --nToys $nToys
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
		python makeSplusBModelPlot.py --inputWSFile ../Combine/Datacard_bkgOnly.root --cat "all" --doBands --ext $tag --parameterMap r:0
		#python makeSplusBModelPlot.py --inputWSFile ../Combine/Datacard_ggtt_resBkg_syst.root --cat "all" --doBands --ext $tag --doResonantBackground --unblind --parameterMap r:10

		mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag
		mkdir -p /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag/SplusBModels

		cp SplusBModels$tag/SR1_CMS_hgg_mass.png /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag/SplusBModels/SR1_CMS_hgg_mass_bkg.png
		cp SplusBModels$tag/SR2_CMS_hgg_mass.png /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag/SplusBModels/SR2_CMS_hgg_mass_bkg.png
		cp SplusBModels$tag/SR1_CMS_hgg_mass.pdf /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag/SplusBModels/SR1_CMS_hgg_mass_bkg.pdf
		cp SplusBModels$tag/SR2_CMS_hgg_mass.pdf /home/users/fsetti/public_html/HH2ggtautau/flashggFinalFit/Plots/$tag/SplusBModels/SR2_CMS_hgg_mass_bkg.pdf
	popd	

}

make_plot_ws(){
	pushd Combine
		#rm -rf Models
		#mkdir -p Models
		#mkdir -p Models/signal
		#mkdir -p Models/background
		#cp ../Signal/outdir_packaged/CMS-HGG*.root ./Models/signal/
		#cp ../Background/outdir_$tag/CMS-HGG*.root ./Models/background/
		cp ../Datacard/Datacard_$tag.txt Datacard.txt
		#echo "r_singleHiggs rateParam * VH_*_hgg 1" >> Datacard.txt
		#echo "r_singleHiggs rateParam * ttH_*_hgg 1" >> Datacard.txt
		#echo "r_singleHiggs rateParam * ggH_*_hgg 1" >> Datacard.txt
		#echo "r_singleHiggs rateParam * VBFH_*_hgg 1" >> Datacard.txt
		#echo "nuisance edit freeze r_singleHiggs" >> Datacard.txt
	
		python RunText2Workspace.py --mode  plots --dryRun
		./t2w_jobs/t2w_plots.sh
	popd
}


#make_toys
make_SpB
#make_plot_ws
