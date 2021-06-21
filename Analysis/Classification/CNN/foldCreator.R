# We generate in this script the iteration k fold indices for the CNN
# training. Thes results are stored in textfiles.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
rm(list=ls())
library(readr)
indices.Carrots <- suppressMessages(as.matrix(read_table2("../indexCreation/indicesCarrots.csv", col_names = FALSE))) #Indices for carrots
indices.SugarB <- suppressMessages(as.matrix(read_table2("../indexCreation/indicesSugarB.csv", col_names = FALSE))) #Indices for carrots
#LST.indices <- list(indices.Carrots,indices.SugarB)
#---------------------#
#--- Do processing ---#
#---------------------#
#Creates the filenames for the CNN training
iterations <- 10
k.fold <- 5
createFiles <- function(file.names,iterations,k.folds,folder.name){
  system(paste("mkdir ",folder.name)) #Create the folder for the data
  #--- Create the files ---#
  for(ITERATION in seq(1,iterations)){ #Iteration loop, in each iteration, the curren k folds are created
    index <- seq(1,nrow(file.names)) #The rows are the samples
    folds <- split(index, ceiling(seq_along(index)/(length(index)/k.folds))) #Create folds with same lien of code as for SVM
    #--- Get train/test indices ---#
    for(K in seq(1,k.folds)){ #k fold loop
      test.indices <- folds[[toString(K)]] 
      train.indices <- unlist(lapply( #Get the training indices over all folds
        seq(1,k.folds), 
        function(x){
          if(x!=K){
            return(folds[[toString(x)]])  
          }
        }))#End create training indices
      #--- Store results ---#
      write.table(file.names[test.indices,ITERATION],paste(folder.name,"/I_",ITERATION,"_k_",K,"_test.csv",sep = ""),row.names = F,col.names = F,quote = F)
      write.table(file.names[train.indices,ITERATION],paste(folder.name,"/I_",ITERATION,"_k_",K,"_train.csv",sep = ""),row.names = F,col.names = F,quote = F)
    }#end k.fold loop
  }#End iteration loop
}#End Training/Test file creation
createFiles(file.names = indices.Carrots,iterations = iterations, k.folds = k.fold,folder.name = "Carrot")
createFiles(file.names = indices.SugarB,iterations = iterations, k.folds = k.fold,folder.name = "SugarB")