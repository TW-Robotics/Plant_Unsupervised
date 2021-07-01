# This script analyses the ARD values of the GPLVM.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
rm(list=ls())
library(readr) #CSV file handling
library(extrafont)
loadfonts()
pdf("RelevanceAnalysis.pdf",width=7, height=4,family = "Palatino")
par(mfrow=c(1,2))
ARD.GPLVM.carrots <- suppressMessages(as.matrix(read_csv("../../GPLVM/Carrots/optModel_bgp_ARDValues.csv", col_names = FALSE)))
ARD.GPLVM.sugarB <- suppressMessages(as.matrix(read_csv("../../GPLVM/SugarB/optModel_bgp_ARDValues.csv", col_names = FALSE)))
#--- PLot the results ---#
#Carrots
REL.carrot <- 1/ARD.GPLVM.carrots #Get the relevance
REL.diff.carrot <- diff(REL.carrot) #Get the difference of the relevance
REL.diff.carrot.TH <- which(REL.diff.carrot>median(REL.diff.carrot))[2] #Get first element at median
#plot(REL.diff.carrot,type='l')
#lines(c(1,150),c(median(REL.diff.carrot),median(REL.diff.carrot)),col='red')
#lines(c(REL.diff.carrot.TH,REL.diff.carrot.TH),c(-1,1),col='red')
plot(REL.carrot,type='l',xlab = "Latent Dimension", ylab = "Relevance", main="Daucus carota", cex.lab=0.8)
lines(c(REL.diff.carrot.TH,REL.diff.carrot.TH),c(-1,1),col='red')
legend("topright",legend=c("Relevance","Threshold"),lty=1, col=c('black','red'),cex=0.8)
#SugarB
REL.sugarB <- 1/ARD.GPLVM.sugarB #Get the relevance
REL.diff.sugarB <- diff(REL.sugarB) #Get the difference of the relevance
REL.diff.sugarB.TH <- which(REL.diff.sugarB>median(REL.diff.sugarB))[1] #Get first element at median
#plot(REL.diff.sugarB,type='l')
#lines(c(1,150),c(median(REL.diff.sugarB),median(REL.diff.sugarB)),col='red')
#lines(c(REL.diff.sugarB.TH,REL.diff.sugarB.TH),c(-1,1),col='red')
plot(REL.sugarB,type='l',xlab = "Latent Dimension", ylab = "Relevance", main="Beta vulgaris", cex.lab=0.8)
lines(c(REL.diff.sugarB.TH,REL.diff.sugarB.TH),c(-1,1),col='red')
legend("topright",legend=c("Relevance","Threshold"),lty=1, col=c('black','red'),cex=0.8)
#---------------------#
#--- Store results ---#
#---------------------#
cAE.carrots.TH.raw <- unlist(strsplit(suppressMessages(as.matrix(read_csv("../Autoencoder/modelSelection/best_model_Carrots.csv", col_names = FALSE))),"/"))
cAE.carrots.TH <- as.numeric(cAE.carrots.TH.raw[3])
cAE.sugarB.TH.raw <- unlist(strsplit(suppressMessages(as.matrix(read_csv("../Autoencoder/modelSelection/best_model_SugarB.csv", col_names = FALSE))),"/"))
cAE.sugarB.TH <- as.numeric(cAE.sugarB.TH.raw[3])
#-1 for Python conversion
write.table(seq(1,REL.diff.carrot.TH)-1,"Carrot_GPLVM.csv",row.names = F,col.names = F)
write.table(seq(1,REL.diff.sugarB.TH)-1,"SugarB_GPLVM.csv",row.names = F,col.names = F)
write.table(seq(1,cAE.carrots.TH)-1,"Carrot_cAE.csv",row.names = F,col.names = F)
write.table(seq(1,cAE.sugarB.TH)-1,"SugarB_cAE.csv",row.names = F,col.names = F)
dev.off()