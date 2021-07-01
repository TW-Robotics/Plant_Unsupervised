# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
library(e1071) #SVM implementation
library(rBayesianOptimization) #For global SVM optimization
library(abind) #For 3D data binding
library(pspearman) #For spearman rank test
#Get labels from the strings
getLabel.onehot <- function(label,classes){
  one.hot.labels <- c() #Memory for labels
  for(CLASS in classes){#loop over all possible classes
    label.local <- unlist(
      lapply(label, function(x){ #This function is applied to every entry in the label array
        if(grepl(CLASS,x)){ #Check if class name is in label string
          return(1) #Return 1 if name contains class element
        }else{return(0)}
      })#End lapply
    )#End unlist lapply return value
    one.hot.labels <- cbind(one.hot.labels, label.local) #Combine labels to one hot encoding
  }
  return(one.hot.labels)#Return one hot encoded labels
}
#---------------------------#
#--- SVM training models ---#
#---------------------------#
#We do a k fold cross validation for (y,x) and repeat it 10 times
train.svm <- function(X,Y,k.fold,iterations,svm.params){
  #------------------------#
  #--- Prepare training ---#
  #------------------------#
  lab.memory <- c() #Iteration label memory
  prob.memory <- c() #Probability memory
  index.memory <- c() #Storage of indices of random sampling
  for (ITER in seq(1,iterations)){
    cat("\t- Iteration ",ITER,"\n")
    cat("\t- Do sampling...\n")
    index <- seq(1,nrow(X))#sample(seq(1,nrow(X)),replace = F) #Create random indices for experiment
    cat("\t- Create folds...\n")
    folds <- split(index, ceiling(seq_along(index)/(length(index)/k.fold))) #Split indices for k folds
    iteration.labels <- c() #Memory for predicted labels
    iteration.class.prob <- c()  #Memory for probabilities
    for(k in seq(1,k.fold)){#Do k fold stuff
      cat("\t\t- Fold",k,"\n")
      #-----------------------#
      #--- Create datasets ---#
      #-----------------------#
      X.test <- X[folds[[toString(k)]],] #Test data is simply the 'active' fold
      Y.test <- Y[folds[[toString(k)]]] #... smae for labels
      index.train <- unlist(lapply( #Get the training indices over all folds
        seq(1,k.fold), 
        function(x){
          if(x!=k){
            return(folds[[toString(x)]])  
          }
        }))#End create training indices
      X.train <- X[index.train,] #Training data is all other folds
      Y.train <- Y[index.train]  #... same for labels
      #cat("Test:",dim(X.test),"\n")
      #cat("Train:",dim(X.train),"\n")
      model.svm <- optimize.svm(X.train,Y.train,X.test,Y.test,svm.params)
      lab.pred  <- predict(model.svm, X.test) #Predict using test data
      prob.pred.raw <- attr(predict(model.svm, X.test, probability=T), 'probabilities') #Get prediction probabilities
      prob.pred <- prob.pred.raw[,which(colnames(prob.pred.raw)=="1")]#[,order(as.numeric(colnames(prob.pred.raw)))]
      iteration.labels     <- c(iteration.labels, as.numeric(lab.pred)-1) #Store result for current run
      #cat("Len:",length(iteration.labels),"\n")
      iteration.class.prob <- rbind(iteration.class.prob, t(t(prob.pred))) #Store class probabilities
    }#End k loops
    #cat("Break iterations and return\n")
    #return(list(labs=iteration.labels,probs=iteration.class.prob))
    #--- Store data ---#
    lab.memory <- cbind(lab.memory,iteration.labels) #Add a column -> the result is [n x iteration] matrix
    prob.memory <- abind(prob.memory,iteration.class.prob,along = 3) #Add probabilitites, this will be a [n x class x iteration] matrix
    index.memory <- cbind(index.memory, index) #Store random index
  }#End iteration loop
  return(list(labs=lab.memory,probs=prob.memory,index = index.memory))
}#End train SVM
#Optimize SVM using Bayesian optimization
optimize.svm <- function(X,Y,X.test,Y.test,parameter,init.pts=10,n.iters=10,verbose=FALSE){
  #------------------------------------------------#
  #--- Evaluation function for SVM optimization ---#
  #------------------------------------------------#
  SVMFun <- function(gamma, nu) {
    svm.model <- svm(X, #Design matrix
                     Y, #Labels
                     type='nu-classification', #SVM type - in this case nu SVM
                     nu=nu, #SVM type hyperparameter
                     kernel = 'radial', gamma=gamma, #Kernel hyperparameters and definitions
                     probability = T) #Activate probabilities in label estimation (fits a logistig regression model in hilbert space)
    lab.pred <- predict(svm.model, X.test) #Predict using test data
    acc <- ACC(lab.pred,Y.test)
    return(list(Score = acc,Pred = 0))
  }
  #--- Do optimization ---#
  best.parameters <- tryCatch({
    OPT_Res <- BayesianOptimization(
      SVMFun, #Function to be evaluated
      bounds = parameter, #Bounds of SVM hpyerparameters
      init_points = init.pts,  #Number of iteration points
      n_iter = n.iters, #Number of iterations
      verbose = verbose) #Print flag
  best.parameters <- OPT_Res$Best_Par #Get gamma/nu values
  },error = function(err){
    cat("Could not use SVM for prediction - use parameter range mean (since its the same val for all)\n")
    message(err)
    return(c(mean(parameter$gamma), mean(parameter$nu)))
  }#End error handling
  )#End try-catch
  svm.model <- svm(X, #Design matrix
                   Y, #Labels
                   type='nu-classification', #SVM type - in this case nu SVM
                   nu=best.parameters[2], #SVM type hyperparameter
                   kernel = 'radial', gamma=best.parameters[1], #Kernel hyperparameters and definitions
                   probability = T) #Activate probabilities in label estimation (fits a logistig regression model in hilbert space)
  return(svm.model)#Return optimized and trained SVM model
}
#Accuracy calculation
ACC <- function(pred.labs, labs){
  acc.matrix <- as.matrix(table(pred.labs,labs)) #Get accuracy matrix
  acc <- sum(diag(acc.matrix))/sum(acc.matrix) #Get accuracy
  return(acc)
}
#LR based feature selection
FS.LR <- function(data.structure,train.indices,iterations,k.fold,alpha){
  X.raw <- data.structure$X #Get the design data
  X <- scale(X.raw) #Scale the training data
  Y <- data.structure$Y #Get labels
  labs <- data.structure$labels #Get labels
  #--- train indices already exist
  pval.memory <- array(0,dim = c(1+ncol(X),k.fold,length(iterations)))
  for(i in iterations){ #Do n iterations
    index <- GPLVM.index(i = i,labels = labs,index.matrix = train.indices)
    X.train <- X[index,] #Get shuffeld design data
    Y.train <- Y[index] #Ge shuffled inidces
    LR.result <- train.LR(X=X.train,Y=Y.train,k.fold=k.fold,iterations=1,svm.params=svm.params)
    #--- Store result ---#
    pval.memory[,,i] <- LR.result$p.vals
  }#End iteration loop  
  active.dimensions <- apply(pval.memory,1,function(x){return(mean(x))}) < alpha #Threshold using alpha
  return(active.dimensions)
}
#LR train used for LR based feature selection
train.LR <- function(X,Y,k.fold,iterations,svm.params){
  #------------------------#
  #--- Prepare training ---#
  #------------------------#
  p.val.memory <- c() #Memory for p values
  for (ITER in seq(1,iterations)){
    #cat("\t- Iteration ",ITER,"\n")
    #cat("\t- Do sampling...\n")
    index <- seq(1,nrow(X))#sample(seq(1,nrow(X)),replace = F) #Create random indices for experiment
    #cat("\t- Create folds...\n")
    folds <- split(index, ceiling(seq_along(index)/(length(index)/k.fold))) #Split indices for k folds
    iteration.pval <- c() #Memory for p values
    for(k in seq(1,k.fold)){#Do k fold stuff
      #cat("\t\t- Fold",k,"\n")
      #-----------------------#
      #--- Create datasets ---#
      #-----------------------#
      X.test <- X[folds[[toString(k)]],] #Test data is simply the 'active' fold
      Y.test <- Y[folds[[toString(k)]]] #... smae for labels
      index.train <- unlist(lapply( #Get the training indices over all folds
        seq(1,k.fold), 
        function(x){
          if(x!=k){
            return(folds[[toString(x)]])  
          }
        }))#End create training indices
      X.train <- X[index.train,] #Training data is all other folds
      Y.train <- Y[index.train]  #... same for labels
      DF.new.test <-  data.frame(Y.test,X.test) #Create new DF
      colnames(DF.new.test) <- c("Y",unlist(lapply(seq(1,ncol(X.test)),function(x){return(paste("L",x,".1",sep = ""))})))
      DF.data <- data.frame(Y.train,X.train) #Create a dataset of statistical test
      colnames(DF.data) <- c("Y",unlist(lapply(seq(1,ncol(X.train)),function(x){return(paste("L",x,".1",sep = ""))})))
      model.LR <- glm(Y~.,data = DF.data,family=binomial('logit'))
      iteration.pval <- abind(iteration.pval,coef(summary(model.LR))[,'Pr(>|z|)'],along = 2)
    }#End k loops
    #--- Store data ---#
    p.val.memory <- iteration.pval
  }#End iteration loop
  return(list(p.vals =p.val.memory))
}#End train LR
#Spearman Test
sp.test <- function(data.structure,alpha){
  activeDims <- c()
  for(k in seq(1,ncol(data.structure$X))){
    Y <- data.structure$Y
    X <- data.structure$X[,k]
    sp.test <- spearman.test(X,Y)
    activeDims <- c(activeDims,sp.test$p.value<alpha)
  }
  return(activeDims)
}