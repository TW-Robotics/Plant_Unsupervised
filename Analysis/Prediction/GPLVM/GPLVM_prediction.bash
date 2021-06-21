# This script loads the GPLVM model and do a prediction with the whole
# dataset.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
#!/bin/bash
set -e #Abort if any error occured
#--- Carrots ---#
carrot_path="../../../GPLVM/Carrots"
carrot_design="../../../data/preproc/Carrots/design.csv"
carrot_pos="../../../data/preproc/Carrots/pos_design.csv"
carrot_neg="../../../data/preproc/Carrots/neg_design.csv"
../../../Python/VE/bin/python ./predictGPLVM.py $carrot_path $carrot_design 57 57 $carrot_pos $carrot_neg 
mkdir Carrots 
mv *.csv Carrots/.
#--- Sugar beets ---#
SB_path="../../../GPLVM/SugarB"
SB_design="../../../data/preproc/Rueben/design.csv"
SB_pos="../../../data/preproc/Rueben/pos_design.csv"
SB_neg="../../../data/preproc/Rueben/neg_design.csv"
../../../Python/VE/bin/python ./predictGPLVM.py $SB_path $SB_design 62 62 $SB_pos $SB_neg 
mkdir SugarB
mv *.csv SugarB/.
