# This script implements the cAE analysis based on the calculated 
# metric, e.g.: the mean squared error. 
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
rm(list=ls())
library(readr) #CSV file handling
library(extrafont)
loadfonts()
pdf("cAESelection.pdf",width=7, height=4,family = "Palatino")
par(mfrow=c(1,2))
#-----------------------#
#--- Main parameters ---#
#-----------------------#
data.path <- "../../../Autoencoder/IT_"
iterations <- seq(1,10)
code.size <- c(10,20,50,75,100)
pops.names <- c("Daucus carota","Beta vulgaris")
pops <- c("Carrots","SugarB")
#--- Analysis parameters ---#
epochs <- 1000 #cAE epochs
analysis.horizont <- 50 #Analysis horizon from metric (lasst n epochs)
#-----------------------#
#--- Start main loop ---#
#-----------------------#
DF.best.models <- data.frame() #Memory for best models
pop.looper <- 1 #Looper for populations
for(POP in pops){#For each population
  pop.metric.memory <- array(0,dim = c(length(iterations)*length(code.size),epochs)) #Metric memory
  pop.metric.hyperparams <- array(0,dim = c(length(iterations)*length(code.size),3)) #code size, coe ID and iteration
  pop.metric.looper <- 1 #Looper for above
  for(CODE in code.size){#For each trained Code
    for(ITERATION in iterations){#For each iteration
      mse.local <- suppressMessages(as.matrix(read_csv(paste(data.path,ITERATION,"/",POP,"/",CODE,"/mse.csv",sep=""), col_names = FALSE)))
      pop.metric.memory[pop.metric.looper,] <- mse.local
      pop.metric.hyperparams[pop.metric.looper,] <- c(CODE,which(code.size==CODE),ITERATION)
      pop.metric.looper <- pop.metric.looper+1
    }#End code size loop
  }#End iteration loop
  #--- Process data ---#
  mse.horizont <- t(apply(pop.metric.memory,1,function(x){return(x[(length(x)-analysis.horizont+1):length(x)])})) #Get analysis horizont
  mse.horizont.median <- (apply(mse.horizont,1,function(x){return(median(x))})) #Get median of horizont
  #-------------------------------------------#
  #--- Plot stuff and get optimal solution ---#
  #-------------------------------------------#
  #Get models to use
  best.model.memory <- data.frame() #Memory to store the best model
  for(CODE in code.size){#Get best model for each code size
    best.mse <- min(
                        mse.horizont.median[which(pop.metric.hyperparams[,1]==CODE)]
                 )#End get best model
    index.best.mse <- which(mse.horizont.median==best.mse)
    best.model.df.local <- data.frame(index = index.best.mse,  #Index in vector
                                      value = best.mse,  #Best value
                                      text = paste("IT_",
                                                   which.min(mse.horizont.median[which(pop.metric.hyperparams[,1]==CODE)]),
                                                   "/",POP,"/",CODE,sep="") #String to best model
                                      )#End create DF
    best.model.memory <- rbind(best.model.memory,best.model.df.local)
  }#End get best model for each code size
  #Plot stuff
  plot(mse.horizont.median,col = pop.metric.hyperparams[,2],pch=16, type='b', 
       main = paste("Analysis for",pops.names[pop.looper]), ylab = "RMSE", xlab = "Experiments",cex.lab=0.8,cex.axis=0.8) #Plot points
  points(best.model.memory$index,mse.horizont.median[best.model.memory$index],cex=2,lwd=2) #Mark best models
  index.best <- which.min(mse.horizont.median[best.model.memory$index])
  points(best.model.memory$index[index.best],mse.horizont.median[best.model.memory$index][index.best],cex=2,lwd=2,col='green') #Mark best model
  legend("topright",legend = c(unlist(lapply(code.size,
                                           function(x){return(paste("Code size:",toString(x)))})
                                    ),'Best Model (Code)','Best Model'), 
         pch=c(rep(16,length(code.size)),1,1),cex=0.65, col = c(unique(pop.metric.hyperparams[,2]),'black','green'), bg='white') #Plot legend
  #--- Store results ---#
  DF.best.models <- rbind(DF.best.models,best.model.memory)
  cat("Best ",POP, " model:", best.model.memory$text[index.best],"\n")
  write.table(best.model.memory$text[index.best], paste("best_model_",POP,".csv",sep = ""),row.names = F,col.names = F,quote = F)
  pop.looper <- pop.looper+1
}#End population loop
write.table(DF.best.models$text, "bestModels.csv",row.names = F,col.names = F,quote = F)
dev.off()