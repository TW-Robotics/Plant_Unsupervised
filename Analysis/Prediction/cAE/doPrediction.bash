# This script controls the cAE prediction.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
#!/bin/bash
path_cAEs="../../../Autoencoder/"
#-----------------------------#
#--- Create data for Keras ---#
#-----------------------------#
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
#--- Carrots ---#
best_cAE_carrots=$(cat ../../Autoencoder/modelSelection/best_model_Carrots.csv) #Get best model for carrots
../../../Python/VE_DL/bin/python predict_cAE.py ./data/Carrots "$path_cAEs""$best_cAE_carrots" 64 64
mkdir Carrots
mv *.csv Carrots/.
#--- Sugar B ---#
best_cAE_sugarB=$(cat ../../Autoencoder/modelSelection/best_model_SugarB.csv) #Get best model for sugar beets
../../../Python/VE_DL/bin/python predict_cAE.py ./data/SugarB "$path_cAEs""$best_cAE_sugarB" 64 64
mkdir SugarB
mv *.csv SugarB/.
#--- Remove old data ---#
rm -rf data
