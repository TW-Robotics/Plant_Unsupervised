# All the classification experiments are based on the same images. The 
# experiments are performed in 10 iterations in a k-fold cross validation.
# This script generates the sequence of image labels used for the experiments.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
rm(list=ls())
library(readr)
iterations <- 10
#--------------------------#
#--- Path to basic data ---#
#--------------------------#
path_pos_Carrots <- "../../../data/preproc/Carrots/pos_label.csv"
path_neg_Carrots <- "../../../data/preproc/Carrots/neg_label.csv"
path_pos_SugarB <- "../../../data/preproc/Rueben/pos_label.csv"
path_neg_SugarB <- "../../../data/preproc/Rueben/neg_label.csv"
#-------------------#
#--- Load labels ---#
#-------------------#
#Carrot
lab.pos.Carrot <- suppressMessages(as.matrix(read_csv(path_pos_Carrots, col_names = FALSE)))
lab.neg.Carrot <- suppressMessages(as.matrix(read_csv(path_neg_Carrots, col_names = FALSE)))
lab.Carrot <- c(lab.pos.Carrot,lab.neg.Carrot)
#SugarB
lab.pos.SugarB <- suppressMessages(as.matrix(read_csv(path_pos_SugarB, col_names = FALSE)))
lab.neg.SugarB <- suppressMessages(as.matrix(read_csv(path_neg_SugarB, col_names = FALSE)))
lab.SugarB <- c(lab.pos.SugarB,lab.neg.SugarB)
#--------------------------#
#--- Create the indices ---#
#--------------------------#
indices.Carrots <- array(0,dim=c(length(lab.Carrot),iterations)) #Matrix to store the interations for carrots
indices.SugarB <- array(0,dim=c(length(lab.SugarB),iterations)) #Matrix to store the interations for SugarBs
for(i in seq(1,iterations)){#Indices creation loop
  sample.index.Carrots <- sample(seq(1,length(lab.Carrot)),length(lab.Carrot)) #Sample the indices
  sample.index.SugarB <- sample(seq(1,length(lab.SugarB)),length(lab.SugarB)) #Sample the indices
  #--- Store results ---#
  indices.Carrots[,i] <- lab.Carrot[sample.index.Carrots]
  indices.SugarB[,i] <- lab.SugarB[sample.index.SugarB]
}#end indices creation loop
write.table(indices.Carrots,"indicesCarrots.csv",row.names = F,col.names = F,quote = F)
write.table(indices.SugarB,"indicesSugarB.csv",row.names = F,col.names = F,quote = F)