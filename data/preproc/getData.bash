# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
#!/bin/bash
processingFolder=("../Carrots" "../Rueben") #Possible databases
ending=(	  ".png" ".png")
#-----------------------#
#--- Process folders ---#
#-----------------------#
looper=0
for data in "${processingFolder[@]}"
do
	ENDING=${ending[$looper]}	#Get img ending
	FOLDER=$(basename $data)	#Get folder name
	mkdir $FOLDER	#Create folder
	../../Python/VE/bin/python3 getDesign.py $data $ENDING > logfile.log
	#--- Move data and update system ---#
	mv *.csv $FOLDER/.
	mv *.png $FOLDER/.
	mv *.log $FOLDER/.
	#looper=$(bc <<< $looper+1)
	num=$(($looper + 1))
done
