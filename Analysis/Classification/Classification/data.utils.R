# This script contains some useful functions for classification pre-
# processing.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>

#Returns the index defined in the index previously created
GPLVM.index <- function(i,labels,index.matrix){
  #We look for the correct name in the label and store the index there
  train.to.index <- c() #Memory with index
  for(k in seq(1,length(labels))){#Loop over the training labels
    #for(m in seq(1,length(labels))){
    #  if(labels[k] == index.matrix[m,i]){#If we found the current label in the defined index matrix
    #    train.to.index <- c(train.to.index,m)
    #    #The current element k must be at place m in the new vector
    #  }
    #}
    train.to.index <- c(train.to.index,which(index.matrix[k,i] == labels))
  }#End label looper
  if(length(train.to.index) != length(labels)){
    stop("Faulty train to indices calculation")
  }
  return(train.to.index)
}