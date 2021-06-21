# This script runs the visualization and p value calculation
# for GPLVM features.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
#!/bin/bash
#--- For Ethiopia ---#
folder="./Carrots"
#../Python/VE/bin/python ./FeatureVariance.py $folder ../data/preproc/Carrots/design.csv 57 57
#mv Heatmaps $folder/.
ln -s ./Carrots/Heatmaps .
../Python/VE/bin/python ./GPLVM_pval.py 57 57
rm ./Heatmaps
#--- For Uganda ---#
folder="SugarB/"
#../Python/VE/bin/python ./FeatureVariance.py $folder ../data/preproc/Rueben/design.csv 62 62
#mv Heatmaps $folder/.
ln -s ./SugarB/Heatmaps .
../Python/VE/bin/python ./GPLVM_pval.py 62 62
rm ./Heatmaps
##-------------------------------------------#
##--- Run the feature selection procedure ---#
##-------------------------------------------#
##../Python/VE/bin/python ../Python/visFeatureSelector.py Ethiopia_IT_1/Heatmaps
##mv selection.csv Ethiopia_IT_1/.
##../Python/VE/bin/python ../Python/visFeatureSelector.py Uganda_IT_1/Heatmaps
##mv selection.csv Uganda_IT_1/Uganda/.
