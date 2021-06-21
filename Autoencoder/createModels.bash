# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
#!/bin/bash
set -e
populations=(./data/Carrots ./data/SugarB) #Possible populations
img_res_actual=('57 57' '62 62') #Image resolutions
img_res=('64 64' '64 64') #Image resolutions
codeSize=(10 20 50 75 100)	#Same as GPLVM
#codeSize=(10 20)	#Same as GPLVM
epochs=1000 #Number of epochs used for cAE training
#--------------------------#
#--- Create data folder ---#
#--------------------------#
for ((ITERATION = 1 ; ITERATION <= 10 ; ITERATION++))
do
	mkdir data
	cd data
	mkdir Carrots
	mkdir SugarB
	cd Carrots
	mkdir data
	cp ../../../data/preproc/Carrots/*.png ./data/
	#cp ../../../data/Carrots/pos* ./data/	
#	ln -s ../../../Data/Images/Ethiopia/ .
	cd ../SugarB
	mkdir data
	cp ../../../data/preproc/Rueben/*.png ./data/
#	ln -s ../../../Data/Images/Uganda/ .
	cd ../../
	#--------------------------#
	#--- Do main processing ---#
	#--------------------------#
	looper=0
	for p in "${populations[@]}"
	do
	    #--- Train the cAE set ---#
	    for i in "${codeSize[@]}"	#Loop over code sizes
	    do
	    	../Python/VE_DL/bin/python cAE.py $p $epochs $i ${img_res[$looper]} &> logfile_$i.log
	    	#--- Move data ---#
	    	mkdir $i
	    	mv  ./my_model $i/.
	    	mv  ./reconstruction $i/.
	    	mv *.csv $i/.
	    	mv *.png $i/.
	    	sleep 10
	    done
	    #../Python/VE_DL/bin/python lossAnalysis.py #This produces the bestModel.csv file
	    #../Python/VE_DL/bin/python samples_cAE.py $p bestModel.csv ${img_res[$looper]} &> logfile_sampling.log #Create Heatmaps
	    ##--- move all files ---#
	    FOLDER_NAME=$(basename $p) #Get population name
	    #mv Heatmaps ./data/$FOLDER_NAME/.
	    #mv bestModel.csv ./data/$FOLDER_NAME/.
	    mv *.log ./data/$FOLDER_NAME/.
	    for i in "${codeSize[@]}"	#Loop over code sizes
	    do
	        mv $i ./data/$FOLDER_NAME/.	#Move trained cAE model and results
	    done
	    #--- Update system ---#
	    looper=$(($looper + 1))
	done
	mv data IT_$ITERATION
done
exit
#--------------------------------#
#--- Get best iteration model ---#
#--------------------------------#
#best_model=$(cat bestcAE.csv)
#echo "Best cAE:" $best_model
#-------------------#
#--- Do sampling ---#
#-------------------#
#../Python/VE_DL/bin/python ./Heatmap_pval.py $best_model/ #Do Sykacek's sampling
#echo "You can now create the selection.csv file for $best_model"
