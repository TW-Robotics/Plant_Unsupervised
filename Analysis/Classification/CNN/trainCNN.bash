# This script creates the training and test files and starts the CNN 
# training and testing.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
#!/bin/bash
set -e
plants=(./Carrot ./SugarB) #Possible image sources
#--- Training info ---#
epochs=500 #Epochs for CNN training
k_fold=5 #Number of folds
iterations=10 #Number of iterations
#--- Make a link to the images ---#
rm -rf data
mkdir data
ln -s ../../../../data/preproc/Carrots data/Carrot
ln -s ../../../../data/preproc/Rueben data/SugarB
#------------------------------#
#--- Prepare data and train ---#
#------------------------------#
#rm -rf Carrot SugarB
#Rscript foldCreator.R
for p in "${plants[@]}"
do
	echo "Process $(basename $p)"
	currentFolder=$(basename $p) #Get name of folder without ./
	for ((ITERATION = 1 ; ITERATION <= $iterations ; ITERATION++)) #Iteration loop
	do
		for ((K = 1 ; K <= $k_fold ; K++)) #k loop
		do
			echo "K "$K" in iteration" $ITERATION
			train_file="$p""/I_""$ITERATION""_k_""$K""_train.csv" #Create name for train file
			test_file="$p""/I_""$ITERATION""_k_""$K""_test.csv" #Create name for test file (obviously)
			#--- Move the files according to the files ---#
			rm -rf CNNData
			mkdir CNNData
			mkdir CNNData/Train
			mkdir CNNData/Test
			cat $train_file | while read line
			do
				cp ./data/$currentFolder/"$line"".png" CNNData/Train/.
			done
			cd CNNData/Train
			mkdir POS NEG
			mv neg* NEG/.; mv pos* POS/.
			cd ../..
			cat $test_file | while read line
			do
				cp ./data/$currentFolder/"$line"".png" CNNData/Test/.
			done
			cd CNNData/Test
			mkdir POS NEG
			mv neg* NEG/.; mv pos* POS/.
			cd ../..
			#--- Do the CNN stuff ---#
			../../../Python/VE_DL/bin/python trainModel.py &> logfile.log
			#--- Store results ---#
			mkdir "I_""$ITERATION""_k_""$K"
			mv *.csv "I_""$ITERATION""_k_""$K"/.
			mv *.log "I_""$ITERATION""_k_""$K"/.
			mv CNNmodel "I_""$ITERATION""_k_""$K"/.
			mv "I_""$ITERATION""_k_""$K" $currentFolder/.
		done #End k fold
	done #End iteration loop
done #End plant loop
