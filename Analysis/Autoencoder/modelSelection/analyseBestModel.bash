# Thius script controls the cAE best model analysis. It is based on the 
# result of the cAEAnalysis.R script result (these fancy csv file).
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at
#!/bin/bash
#--- Basic infos ---#
path_cAE="../../../Autoencoder" #Path to cAE data
#img_size='96 224' #Size of the training images
#-------------------------------------#
#--- Check if analysis file exists ---#
#-------------------------------------#
if [ -f "./bestModels.csv" ]
then
    echo "Found bestModels.csv file - can proceed"
else
    echo "Please run cAEAnalysis.R before running the visualization"
fi
#--------------------------------------------#
#--- Create symbolic link magic for Keras ---#
#--------------------------------------------#
rm -rf data
mkdir data
cd data
mkdir Carrots
mkdir SugarB
cd Carrots
ln -s ../../../../../data/preproc/Carrots/ .
cd ../SugarB
ln -s ../../../../../data/preproc/Rueben/ SugarB
cd ../../
#-------------------------#
#--- Sample from model ---#
#-------------------------#
cat bestModels.csv | while read line
do
	echo "Process $line"
	POP=$(echo $line | awk -F"/" '{print $2}') #Get population
	CODE_SIZE=$(echo $line | awk -F"/" '{print $3}') #Get code size
	#echo $line | grep SugarB
	#if [ "$?" = "1" ]
	#then 
	#	echo "Proc Carrots "
		../../../Python/VE_DL/bin/python samples_cAE.py ./data/$POP "$path_cAE"/"$line" 64 64 &> sample.log #Get heatmaps
	#else
	#	echo "Proc SugarB "
	#	../../../Python/VE_DL/bin/python samples_cAE.py ./data/$POP "$path_cAE"/"$line" 62 62 &> sample.log #Get heatmaps
	#fi
	../../../Python/VE_DL/bin/python Heatmap_pval.py ./ &> pval.log #Get Sykacek's p val map
	#--- Move folder ---#
	mv *.log Heatmaps/.
	mv Heatmaps "$POP"_"$CODE_SIZE"
done
