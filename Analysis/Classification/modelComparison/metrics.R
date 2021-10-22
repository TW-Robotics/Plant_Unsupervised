# This scripts implements the metrics for classifier comparison.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
# mutual information
getMI <- function(PROB,GT){
  iterations <- dim(GT)[2] #Get the number of iterations
  MI.memory <- c() #Memory for MI values
  for(ITERATION in seq(1,iterations)){
    MI.loop <- c() #Memory for each iteration
    for(N in seq(1,nrow(PROB))){ #Sample loop
      # The MI is defined by 1/N * sum_n=1^N sum_y=0^1 p(y_n=y|x_n) log2(p(y_n=y|x_n) / p(y_n = y))
      # For Y = 1
      MI <- -1
      p_y_yn_xn <- 0
      not.p_y_yn_xn <- 0
      therm2 <- 0
      not.therm2 <- 0
      if(PROB[N,ITERATION] > 1e-6){
        p_y_yn_xn <- PROB[N,ITERATION]
        therm2 <- log2(
                          p_y_yn_xn / (sum(GT[,ITERATION])/nrow(GT))
                      )#calculate second therm
      }
      if((1-PROB[N,ITERATION]) > 1e-6){
        # For Y = 0
        not.p_y_yn_xn <- 1 - PROB[N,ITERATION]
        not.therm2 <- log2(
          not.p_y_yn_xn / (1-(sum(GT[,ITERATION])/nrow(GT)))
        )#calculate second therm for negative part
        #Fuse parts
      }
      if((p_y_yn_xn==0) && (not.p_y_yn_xn ==0)){
        warning("both are zero")
        MI <- 0
      }else{
        MI <- p_y_yn_xn*therm2 + not.p_y_yn_xn*not.therm2 #Implement the sum
      }
      MI.loop <- c(MI.loop,MI)
    }#End sample loop
    MI.memory <- c(MI.memory, sum(MI.loop)/length(MI.loop))
  }#End iteration loop
  return(MI.memory)
}#End mutual information calculation
# MC Nemar test 
getMcNemar <- function(LABS.classifier, LABS.target,GT){
    #We initiall need the counts of correctly classified samples for the target classifier
    #A (na) and B (nb). These values are used for the test
    #--- Get correctly classified samples for A, the target classifier ---#
    nA <- sum(LABS.target==GT) #Correctly classified samples for A
    nB <- sum(LABS.classifier==GT) #Correctly classified samples for B
    contingency.table.raw <- table(LABS.target==GT,LABS.classifier==GT) #Get contigency table
    contingency.table <- array(0,dim = c(2,2)) #Init new contigancy table
    contingency.table[1,1] <- contingency.table.raw[2,2] #Both are true
    contingency.table[2,2] <- contingency.table.raw[1,1] #Both are wrong
    contingency.table[1,2] <- contingency.table.raw[1,2] #classifier is wrong, target is right
    contingency.table[2,1] <- contingency.table.raw[2,1] #target is wrong, classifier is right
    mc.nemar.pval <- mcnemar.test(contingency.table,correct = T)$p.val
    return(list(p.val=mc.nemar.pval,CT = contingency.table))
    #mcnemar.test(,correct = T)$p.value
}