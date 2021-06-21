# This scripts analyses all m models of the CNN visualization and extracts
# the best model from all iterations. We use that model for LRP.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
library(readr)
path.images <- "../../../data/preproc/" #Path to training images
path.carrot <- "../CNN/Carrot" #path to carrot CNN data
path.sugarB <- "../CNN/SugarB" #path to sugar B CNN data
k.fold <- 5 #K of k fold cross validation
iterations <- 10 #Number of iteration 
paths <- c(path.carrot, path.sugarB)
#---------------------#
#--- Do processing ---#
#---------------------#
for(PATH in paths){
  acc.mem <- c() #Memory for accuracy, iteration and k
  for(ITERATION in seq(1,iterations)){
    for(K in seq(1,k.fold)){
      CM <- suppressMessages(as.matrix(read_table2(paste(PATH,"/I_",ITERATION,"_k_",K,"/CM.csv",sep = ""), col_names = FALSE))) #Load confusion matrix
      ACC <- sum(diag(CM))/sum(CM) #Classification result on test data
      acc.mem <- rbind(acc.mem, matrix(c(ITERATION,K,ACC),nrow = 1,ncol = 3)) #Store results
    }#End k fold loop
  }#End iteration loop
  #--- Analyse best model ---#
  index.best <- which.max(acc.mem[,3]) #Get model with highest acuracy (or first model with highest accuracy)
  best.ITERATION <- acc.mem[index.best,1] #Best iteration
  best.K <- acc.mem[index.best,2] #Best fold
  test.image.file <- paste("I_",best.ITERATION,"_k_",best.K,"_test.csv",sep = "") #Get image file from best model
  #---------------------------#
  #--- Create CNN Vis data ---#
  #---------------------------#
  dataset <- unlist(strsplit(PATH,"/"))[3] #Get dataset name
  system(paste("mkdir ",dataset,"; cd ",dataset,"; mkdir pos; mkdir neg"))
  system(paste("cp -rf ",PATH,"/I_",best.ITERATION,"_k_",best.K,"/CNNmodel ./", dataset,"/.",sep = "" ))
  image.file <- suppressMessages(as.matrix(read_table2(paste(PATH,"/",test.image.file,sep = ""), col_names = FALSE))) #Load best images
  #--- Copy test images ---#
  for(IMAGE in image.file){
    if(grepl("pos",IMAGE)){
      system(paste("cp ",path.images,dataset,"/",IMAGE,".png ",dataset,"/pos/.",sep = ""))
    }else if(grepl("neg",IMAGE)){
      system(paste("cp ",path.images,dataset,"/",IMAGE,".png ",dataset,"/neg/.",sep = ""))
    }
  }#End copy all images
}#End loop over all datasets