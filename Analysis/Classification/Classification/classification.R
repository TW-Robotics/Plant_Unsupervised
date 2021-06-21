# This scripts implemenbts the classification of the selected features.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
rm(list=ls())
library(readr) #CSV file handling
source("./data.utils.R")
source("./SVM.utils.R")
#Converts a label string to a binary target nector
cAELab2target <- function(lab){
  target <- c()#memory for target vector
  for(L in lab){
    if(grepl("pos",L)){
      target <- c(target,1) #Add a positive sample
    }else{
      target <- c(target,0) #Add a negative sample
    }#End true/false check
  }#End loop over labels
  return(target) #Return target vector
}#End convert cAE label to target vector
#Converts a label string to a GPLVM label vector
cAELab2lab <- function(lab){
  labs <- c()#memory for target vector
  for(L in lab){
    filename <- unlist(strsplit(L,"/"))[2]
    labs <- c(labs, unlist(strsplit(filename,".png"))[1])    
  }#End loop over labels
  return(labs) #Return target vector
}#End convert cAE label to target vector
#------------------------#
#--- Initial settings ---#
#------------------------#
k.fold<-5
svm.params <- list(gamma = c(1e-5, 5e-1), nu = c(1e-3,1e-1))
iterations <- seq(1,10) #Iterations to use
#---------------------#
#--- Load the data ---#
#---------------------#
#The indices used for classification
carrots.indices <- suppressMessages(as.matrix(read_table2("../indexCreation/indicesCarrots.csv",col_names = F)))
sugarB.indices <- suppressMessages(as.matrix(read_table2("../indexCreation/indicesSugarB.csv",col_names = F)))
#--- GPLVM ---#
#Carrots
carrots.GPLVM.X.raw <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/GPLVM/Carrots/design.csv",col_names=F)))
carrots.GPLVM.Y <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/GPLVM/Carrots/target.csv",col_names = F)))
#The label is at first place the pos and then the neg images
carrots.GPLVM.label <- c(suppressMessages(as.matrix(read_csv("../../../data/preproc/Carrots/pos_label.csv", col_names = FALSE))),
                         suppressMessages(as.matrix(read_csv("../../../data/preproc/Carrots/neg_label.csv", col_names = FALSE)))
                         )
carrots.GPLVM.selection <- suppressMessages(as.matrix(read_table2("../../FeatureSelection/Carrot_GPLVM.csv", col_names = FALSE)))+1 #+1 due to Python to R conversion
#Sugar Bs
sugarB.GPLVM.X.raw <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/GPLVM/SugarB/design.csv",col_names = F)))
sugarB.GPLVM.Y <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/GPLVM/SugarB/target.csv",col_names = F)))
sugarB.GPLVM.label <- c(suppressMessages(as.matrix(read_csv("../../../data/preproc/Rueben/pos_label.csv", col_names = FALSE))),
                         suppressMessages(as.matrix(read_csv("../../../data/preproc/Rueben/neg_label.csv", col_names = FALSE)))
)
sugarB.GPLVM.selection <- suppressMessages(as.matrix(read_table2("../../FeatureSelection/SugarB_GPLVM.csv", col_names = FALSE)))+1 #+1 due to Python to R conversion
#--- cAE ---#
#Carrots
carrots.cAE.X.raw <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/cAE/Carrots/prediction.csv",col_names=F)))
carrots.cAE.label.raw <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/cAE/Carrots/labels.csv",col_names=F)))
carrots.cAE.label <- cAELab2lab(carrots.cAE.label.raw)
carrots.cAE.Y <- cAELab2target(carrots.cAE.label) #Convert label to target
carrots.cAE.selection <- suppressMessages(as.matrix(read_table2("../../FeatureSelection/Carrot_cAE.csv", col_names = FALSE)))+1 #+1 due to Python to R conversion
#Suigar Bs
sugarB.cAE.X.raw <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/cAE/SugarB/prediction.csv",col_names=F)))
sugarB.cAE.label.raw <- suppressMessages(as.matrix(design <- read_csv("../../Prediction/cAE/SugarB/labels.csv",col_names=F)))
sugarB.cAE.label <- cAELab2lab(sugarB.cAE.label.raw)
sugarB.cAE.Y <- cAELab2target(sugarB.cAE.label) #Convert label to target
sugarB.cAE.selection <- suppressMessages(as.matrix(read_table2("../../FeatureSelection/SugarB_cAE.csv", col_names = FALSE)))+1 #+1 due to Python to R conversion
#-----------------------------#
#--- Do the classification ---#
#-----------------------------#
LST.GPLVM.carrot <- list(X=carrots.GPLVM.X.raw[,carrots.GPLVM.selection],Y=carrots.GPLVM.Y,labels=carrots.GPLVM.label, name="Carrot",model="GPLVM")
LST.GPLVM.sugarB <- list(X=sugarB.GPLVM.X.raw[,sugarB.GPLVM.selection],Y=sugarB.GPLVM.Y,labels=sugarB.GPLVM.label, name="sugarB",model="GPLVM")
LST.cAE.carrot <- list(X=carrots.cAE.X.raw[,carrots.cAE.selection],Y=carrots.cAE.Y,labels=carrots.cAE.label, name="Carrot",model="cAE")
LST.cAE.sugarB <- list(X=sugarB.cAE.X.raw[,sugarB.cAE.selection],Y=sugarB.cAE.Y,labels=sugarB.cAE.label, name="sugarB",model="cAE")

LST <- list(LST.GPLVM.carrot,LST.GPLVM.sugarB,LST.cAE.carrot,LST.cAE.sugarB)
#LST <- list(LST.cAE.carrot,LST.cAE.sugarB)

for(LST.iterator in seq(1,length(LST))){#Loop over all defined models
  X.raw <- LST[[LST.iterator]]$X #Get the design data
  X <- scale(X.raw) #Scale the training data
  Y <- LST[[LST.iterator]]$Y #Get labels
  labs <- LST[[LST.iterator]]$labels #Get labels
  if(LST[[LST.iterator]]$name == "Carrot"){
    train.indices <- carrots.indices
  }else{
    train.indices <- sugarB.indices
  }
  prob.memory <- array(0,dim = c(length(Y),length(iterations)))
  acc.memory <- c()
  lab.memory <- array(0,dim = c(length(Y),length(iterations)))
  for(i in iterations){ #Do n iterations
    index <- GPLVM.index(i = i,labels = labs,index.matrix = train.indices)
    X.train <- X[index,] #Get shuffeld design data
    Y.train <- Y[index] #Ge shuffled inidces
    SVM.result <- train.svm(X=X.train,Y=Y.train,k.fold=k.fold,iterations=1,svm.params=svm.params)
    #model.svm <- optimize.svm(X = X[index[1:500],],Y = Y[index[1:500]],X.test = X[index[501:700],],Y.test = Y[index[501:700]],parameter = svm.params,verbose = T)
    #--- Store result ---#
    #ACC
    ACC.loc <- (sum(diag(table(Y.train,SVM.result$labs)))/sum((table(Y.train,SVM.result$labs)))*100)
    acc.memory <- c(acc.memory,ACC.loc)
    #PROB 
    prob.memory[,i] <- SVM.result$probs[,1,1]
    lab.memory[,i] <- SVM.result$labs
  }#End iteration loop  
  LST[[LST.iterator]]$ACC.memory <- acc.memory
  LST[[LST.iterator]]$PROB.memory <- prob.memory
  LST[[LST.iterator]]$LAB.memory <- lab.memory
}#End model/dataset looper
#--------------------#
#--- Save results ---#
#--------------------#
for(LST.iterator in seq(1,length(LST))){#Loop over all defined models
  write.table(LST[[LST.iterator]]$ACC.memory,paste(LST[[LST.iterator]]$name,"_",LST[[LST.iterator]]$model,"_ACC.csv",sep = ""),row.names = F,col.names = F)
  write.table(LST[[LST.iterator]]$PROB.memory,paste(LST[[LST.iterator]]$name,"_",LST[[LST.iterator]]$model,"_PROB.csv",sep = ""),row.names = F,col.names = F)
  write.table(LST[[LST.iterator]]$LAB.memory,paste(LST[[LST.iterator]]$name,"_",LST[[LST.iterator]]$model,"_LAB.csv",sep = ""),row.names = F,col.names = F)
}