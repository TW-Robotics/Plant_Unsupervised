# This script runs the GPLVM optimization script.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>

#!/bin/bash
#----------------#
#--- Ethiopia ---#
#----------------#
for ((ITERATION = 1 ; ITERATION <= 1 ; ITERATION++))
do
	mkdir Carrots
	../Python/VE/bin/python3 getGPLVM.py ../data/preproc/Carrots/design.csv
	mv *.csv Carrots/.
	mv *.pdf Carrots/.
	mv *.npy Carrots/.
	#mv Ethiopia Ethiopia_IT_$ITERATION
done
#--------------#
#--- Uganda ---#
#--------------#
for ((ITERATION = 1 ; ITERATION <= 1 ; ITERATION++))
do
	mkdir SugarB
	../Python/VE/bin/python3 getGPLVM.py ../data/preproc/Rueben/design.csv
	mv *.csv SugarB/.
	mv *.pdf SugarB/.
	mv *.npy SugarB/.
	#mv Uganda Uganda_IT_$ITERATION
done
