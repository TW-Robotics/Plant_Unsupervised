# This scripts loads the results for CNN, cAE and GPLVM classification. The
# metrices are calculated and visualized.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
rm(list=ls())
library(readr) #CSV file handling
source("./metrics.R")
iterations <- 10
k_folds <- 5
#-------------#
#--- GPLVM ---#
#-------------#
LST.GPLVM.carrot <- list(
                          ACC = suppressMessages(as.matrix(read_csv("../Classification/Carrot_GPLVM_ACC.csv", col_names = FALSE))),
                          PROB = suppressMessages(as.matrix(read_table2("../Classification/Carrot_GPLVM_PROB.csv", col_names = FALSE))),
                          LAB = suppressMessages(as.matrix(read_table2("../Classification/Carrot_GPLVM_LAB.csv", col_names = FALSE)))
                        )#Load the parameters for GPLVM based carrot classification
LST.GPLVM.sugarB <- list(
                        ACC = suppressMessages(as.matrix(read_csv("../Classification/sugarB_GPLVM_ACC.csv", col_names = FALSE))),
                        PROB = suppressMessages(as.matrix(read_table2("../Classification/sugarB_GPLVM_PROB.csv", col_names = FALSE))),
                        LAB = suppressMessages(as.matrix(read_table2("../Classification/sugarB_GPLVM_LAB.csv", col_names = FALSE)))
                        )#Load the parameters for GPLVM based sugar B classification
#-----------#
#--- cAE ---#
#-----------#
LST.cAE.carrot <- list(
  ACC = suppressMessages(as.matrix(read_csv("../Classification/Carrot_cAE_ACC.csv", col_names = FALSE))),
  PROB = suppressMessages(as.matrix(read_table2("../Classification/Carrot_cAE_PROB.csv", col_names = FALSE))),
  LAB = suppressMessages(as.matrix(read_table2("../Classification/Carrot_cAE_LAB.csv", col_names = FALSE)))
)#Load the parameters for GPLVM based carrot classification
LST.cAE.sugarB <- list(
  ACC = suppressMessages(as.matrix(read_csv("../Classification/sugarB_cAE_ACC.csv", col_names = FALSE))),
  PROB = suppressMessages(as.matrix(read_table2("../Classification/sugarB_cAE_PROB.csv", col_names = FALSE))),
  LAB = suppressMessages(as.matrix(read_table2("../Classification/sugarB_cAE_LAB.csv", col_names = FALSE)))
)#Load the parameters for GPLVM based sugar B classification
#-----------#
#--- CNN ---#
#-----------#
loadCNNdata <- function(path,iterations,k.folds){
  mem.ACC <- array(0,dim = c(iterations,1)) #Memory for accuracy
  mem.PROB<- c() #We do not know the dimension jet
  mem.ID <- c() 
  #---------------------#
  #--- Load the data ---#
  #---------------------#
  for(ITERATION in seq(1,iterations)){ #Loop over all iterations
    GT.local <- c() #Memory for this iteration
    lab.local <- c() #Memory for this iteration
    prob.local <- c() #Memory for this iteration
    ID.local <- c() #Memory for label (e.g.: id of image = name)
    for(K in seq(1,k.folds)){ #Loop over all ks
      GT <- suppressMessages(as.matrix(read_csv(paste(path,"I_",ITERATION,"_k_",K,     "/label_groundTruth.csv", sep = ""),col_names = FALSE))) #The ground truth of the prediction
      predL <- suppressMessages(as.matrix(read_csv(paste(path,"I_",ITERATION,"_k_",K,  "/label_prediction.csv", sep = ""),col_names = FALSE))) #The predicted label
      prob <- suppressMessages(as.matrix(read_table2(paste(path,"I_",ITERATION,"_k_",K,"/label_predProb.csv", sep = ""),col_names = FALSE)))[,2] #The predicted label
      ID.raw <- suppressMessages(as.matrix(read_table2(paste(path,"I_",ITERATION,"_k_",K,"/label_predIDs.csv", sep = ""),col_names = FALSE))) #The ID of the image
      ID <- unlist(lapply(ID.raw,function(x){
                                              name.with.ending <- unlist(strsplit(x,"/"))[2]
                                              name.no.ending <- unlist(strsplit(name.with.ending,".png"))[1]
                                              return(name.no.ending)
                                            })) #Remove XYZ/
      #--- Store results ---#
      GT.local <- c(GT.local,GT) #Store ground truth
      lab.local <- c(lab.local,predL) #Store predicted label
      prob.local <- c(prob.local,prob) #Store estimated probability
      ID.local <- c(ID.local, ID) #Store ID of image
    }#End k fold iteration
    CM <- table(GT.local,lab.local)
    mem.ACC[ITERATION] <- sum(diag(CM))/sum(CM)
    if(length(mem.PROB) == 0){
      mem.PROB <- prob.local  
      mem.ID <- ID.local
    }else{
      mem.PROB <- cbind(mem.PROB,prob.local)
      mem.ID <- cbind(mem.ID, ID.local)
    }
  }#End iteration loop 
  return(list(ACC=mem.ACC,PROB=mem.PROB,ID=mem.ID))
}
LST.CNN.carrot <- loadCNNdata(path = "../CNN/Carrot/",iterations = iterations,k.folds = k_folds)
LST.CNN.sugarB <- loadCNNdata(path = "../CNN/SugarB/",iterations = iterations,k.folds = k_folds)
#------------------------------------#
#--- Visualization of the results ---#
#------------------------------------#
# Accuracy of carrots
pdf("ACC.pdf",width=7, height=4)
par(mfrow=c(1,2))
ACC.DF.carrots <- array(0,dim = c(iterations,3))
ACC.DF.carrots[,1] <- LST.GPLVM.carrot$ACC
ACC.DF.carrots[,2] <- LST.cAE.carrot$ACC
ACC.DF.carrots[,3] <- LST.CNN.carrot$ACC*100
colnames(ACC.DF.carrots) <- c("B-GP-LVM","cAE","CNN")
boxplot(ACC.DF.carrots, xlab = "Model", ylab="Accuracy [%]", main="Daucus carota Accuracy", cex.axis=0.85)
# Accuracy of sugar Bs
ACC.DF.sugarB <- array(0,dim = c(iterations,3))
ACC.DF.sugarB[,1] <- LST.GPLVM.sugarB$ACC
ACC.DF.sugarB[,2] <- LST.cAE.sugarB$ACC
ACC.DF.sugarB[,3] <- LST.CNN.sugarB$ACC*100
colnames(ACC.DF.sugarB) <- c("B-GP-LVM","cAE","CNN")
boxplot(ACC.DF.sugarB, xlab = "Model", ylab="Accuracy [%]", main="Beta vulgaris Accuracy", cex.axis=0.85)
dev.off()
# Mutual information
pdf("MI.pdf",width=7, height=4)
par(mfrow=c(1,2))
# We need to initially load the true labels for the MI implementation
GT.carrot.lab <- suppressMessages(as.matrix(read_table2("../indexCreation/indicesCarrots.csv", col_names = FALSE))) #Get img name
GT.sugarB.lab <- suppressMessages(as.matrix(read_table2("../indexCreation/indicesSugarB.csv", col_names = FALSE))) #Get img name
#Convert iamge name to target value
lab2tar <- function(labs){
  target <- c() #Memory for taget values
  for(L in labs){ #For all labels
    if(grepl("pos",L)){ #Check if positive
      target <- c(target,1) #Add positive
    }else{#Check if negative
      target <- c(target,0) #Add negative 
    }#End neg 
  }#End lab looper
  return(target)
}
GT.carrot.target <- apply(GT.carrot.lab,2,lab2tar) #Get GT target
GT.sugarB.target <- apply(GT.sugarB.lab,2,lab2tar) #Get GT target
#----------------------#
#--- MI calculation ---#
#----------------------#
#Carrot
MI.carrot.GPLVM <- getMI(PROB = LST.GPLVM.carrot$PROB,GT = GT.carrot.target) #Get the MI
MI.carrot.cAE <- getMI(PROB = LST.cAE.carrot$PROB,GT = GT.carrot.target) #Get the MI
MI.carrot.CNN <- getMI(PROB = LST.CNN.carrot$PROB,GT = GT.carrot.target) #Get the MI
#SugarB
MI.sugarB.GPLVM <- getMI(PROB = LST.GPLVM.sugarB$PROB,GT = GT.sugarB.target) #Get the MI
MI.sugarB.cAE <- getMI(PROB = LST.cAE.sugarB$PROB,GT = GT.sugarB.target) #Get the MI
MI.sugarB.CNN <- getMI(PROB = LST.CNN.sugarB$PROB,GT = GT.sugarB.target) #Get the MI
#Plot the MI
#Carrot
MI.DF.carrot <- array(0,dim = c(iterations,3))
MI.DF.carrot[,1] <- MI.carrot.GPLVM
MI.DF.carrot[,2] <- MI.carrot.cAE
MI.DF.carrot[,3] <- MI.carrot.CNN
colnames(MI.DF.carrot) <- c("B-GP-LVM","cAE","CNN")
boxplot(MI.DF.carrot, xlab = "Model", ylab="MI [bit]", main="Daucus carota MI Comparison", cex.axis=0.85)
#SugarB
MI.DF.sugarB <- array(0,dim = c(iterations,3))
MI.DF.sugarB[,1] <- MI.sugarB.GPLVM
MI.DF.sugarB[,2] <- MI.sugarB.cAE
MI.DF.sugarB[,3] <- MI.sugarB.CNN
colnames(MI.DF.sugarB) <- c("B-GP-LVM","cAE","CNN")
boxplot(MI.DF.sugarB, xlab = "Model", ylab="MI [bit]", main="Beta vulgaris MI Comparison", cex.axis=0.85)
dev.off()
#---------------------------#
#--- Do the McNemar test ---#
#---------------------------#
pdf("McN.pdf",width=7, height=4)
par(mfrow=c(1,2))
CNN.bin.lab <- LST.CNN.carrot$PROB>0.5 #Get binary response
LST.CNN.carrot$LAB <- t(apply(CNN.bin.lab,1,as.numeric)) #Convert to numerical values (e.g.: 0 and)
CNN.bin.lab <- LST.CNN.sugarB$PROB>0.5 #Get binary response
LST.CNN.sugarB$LAB <- t(apply(CNN.bin.lab,1,as.numeric)) #Convert to numerical values (e.g.: 0 and)
#--- Sort CNN data  ---#
CNNIndexer <- function(CNNLab,GTLab){
  index.mem <- c() #Memory for CNN2GT indices
  for(ITERATION in seq(1,ncol(GTLab))){ #Loop for each iteration
    index.loop <- c() #Indices for this loop
    for(i in seq(1,nrow(CNNLab))){ #Process each CNN sample
      #Seek the right position for current CNN sample according to sampled indices
      #for(k in seq(1,nrow(CNNLab))){
      #  id.name <- unlist(strsplit(CNNLab[k,ITERATION],".p"))[1] #Get ID name without file ending
      #  if(id.name == GTLab[i,ITERATION]){
      #    index.loop <- c(index.loop,k)
      #  }#End check label
      #}#End sample loop
      k <- which(GTLab[i,ITERATION] == CNNLab[,ITERATION]) #Short for above
      index.loop <- c(index.loop,k) #Store result
    }#End sample iterator
    index.mem <- cbind(index.mem,index.loop) #Store result
  }#End index loop
  return(index.mem)
}#End CNN sorter
index.CNN.carrot <- CNNIndexer(CNNLab = LST.CNN.carrot$ID,GTLab = GT.carrot.lab) #Get indices to convert rows
index.CNN.sugarB <- CNNIndexer(CNNLab = LST.CNN.sugarB$ID,GTLab = GT.sugarB.lab) #Get indices to convert rows
#--- Do the McNemar loop ---#
Mc.Nemar.pval.log <- array(0,dim = c(iterations,4))
Mc.Nemar.pval <- array(0,dim = c(iterations,4))
for(ITERATION in seq(1,iterations)){
  #--- Get the CNN reference ---#
  CNN.labs.carrot <- LST.CNN.carrot$LAB[index.CNN.carrot[,ITERATION], ITERATION]
  CNN.labs.sugarB <- LST.CNN.sugarB$LAB[index.CNN.sugarB[,ITERATION], ITERATION]
  #--- Get the other classifiers labs ---#
  GPLVM.carrot <- LST.GPLVM.carrot$LAB[,ITERATION]
  GPLVM.sugarB <- LST.GPLVM.sugarB$LAB[,ITERATION]
  cAE.carrot <- LST.cAE.carrot$LAB[,ITERATION]
  cAE.sugarB <- LST.cAE.sugarB$LAB[,ITERATION]
  #--- GET GT ---#
  GT.local.carrot <- GT.carrot.target[,ITERATION] #Get ground truth
  GT.local.sugarB <- GT.sugarB.target[,ITERATION] #Get ground truth
  #--- Do the McNemar test
  #GPLVM carrot
  McNemar.CNN.GPLVM.carrot <- getMcNemar(LABS.classifier = GPLVM.carrot,LABS.target = CNN.labs.carrot,GT = GT.local.carrot)
  McNemar.CNN.GPLVM.carrot.log <- log(McNemar.CNN.GPLVM.carrot$p.val)-log(1-McNemar.CNN.GPLVM.carrot$p.val)
  #GPLVM sugarB
  McNemar.CNN.GPLVM.sugarB <- getMcNemar(LABS.classifier = GPLVM.sugarB,LABS.target = CNN.labs.sugarB,GT = GT.local.sugarB)
  McNemar.CNN.GPLVM.sugarB.log <- log(McNemar.CNN.GPLVM.sugarB$p.val)-log(1-McNemar.CNN.GPLVM.sugarB$p.val)
  #cAE carrot
  McNemar.CNN.cAE.carrot <- getMcNemar(LABS.classifier = cAE.carrot,LABS.target = CNN.labs.carrot,GT = GT.local.carrot)
  McNemar.CNN.cAE.carrot.log <- log(McNemar.CNN.cAE.carrot$p.val)-log(1-McNemar.CNN.cAE.carrot$p.val)
  #cAE sugarB
  McNemar.CNN.cAE.sugarB <- getMcNemar(LABS.classifier = cAE.sugarB,LABS.target = CNN.labs.sugarB,GT = GT.local.sugarB)
  McNemar.CNN.cAE.sugarB.log <- log(McNemar.CNN.cAE.sugarB$p.val)-log(1-McNemar.CNN.cAE.sugarB$p.val)  
  #---------------------#
  #--- Store results ---#
  #---------------------#
  Mc.Nemar.pval[ITERATION,1] <- McNemar.CNN.GPLVM.carrot$p.val
  Mc.Nemar.pval[ITERATION,2] <- McNemar.CNN.GPLVM.sugarB$p.val
  Mc.Nemar.pval[ITERATION,3] <- McNemar.CNN.cAE.carrot$p.val
  Mc.Nemar.pval[ITERATION,4] <- McNemar.CNN.cAE.sugarB$p.val
  Mc.Nemar.pval.log[ITERATION,1] <- McNemar.CNN.GPLVM.carrot.log
  Mc.Nemar.pval.log[ITERATION,2] <- McNemar.CNN.GPLVM.sugarB.log
  Mc.Nemar.pval.log[ITERATION,3] <- McNemar.CNN.cAE.carrot.log
  Mc.Nemar.pval.log[ITERATION,4] <- McNemar.CNN.cAE.sugarB.log
}#End McNemar iteration loop
colnames(Mc.Nemar.pval) <- c("B-GP-LVM","B-GP-LVM", "cAE", "cAE")
#--- Boxplots ---#
boxplot(Mc.Nemar.pval[,c(1,3)], main="McNemar Test for Daucus carota", ylab="p value", cex.axis=0.85)
boxplot(Mc.Nemar.pval[,c(2,4)], main="McNemar Test for Beta vulgaris", ylab="p value", cex.axis=0.85)
dev.off()