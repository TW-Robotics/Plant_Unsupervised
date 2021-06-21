# This script implements the prediction for a given dataset (pos+neg)
# based on a trained GPLVM model.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2020 <wilfried.woeber@technikum-wien.at>
import sys                  #System stuff
sys.path.append('../../../Python/')  #Add path to project library
from bGPLVM import bGPLVM   #GPy wrapper
import numpy as np          #You should know that
import matplotlib.pyplot as plt #We aim to plot something...
import os                   #For bash stuff
#---------------------#
#--- Set variables ---#
#---------------------#
proc_path = sys.argv[1] #Path, where data is
design_path = sys.argv[2]   #Path to design.csv
image_dim = (int(sys.argv[3]), int(sys.argv[4])) #Image dimensions
path_pos = sys.argv[5] #Path to positive csv file
path_neg = sys.argv[6] #Path to negative csv file
#--------------------------------------#
#--- Load IDP and optimal dimension ---#
#--------------------------------------#
latentDim        = np.loadtxt(proc_path+"/optModel_bgp_lDim.csv", dtype=int)
nrInd            = np.loadtxt(proc_path+"/optModel_bgp_nrInd.csv",dtype=int)
# --> note, we used 90% rule
print("Use %d inducing points and %d latent dimensions" % (nrInd,latentDim))
#-------------------------#
#--- Init bGPLVM model ---#
#-------------------------#
data_Model	= proc_path+"/optModel_bgp_model.npy"
data_latent	= proc_path+"/optModel_bgp_features_train.csv"
dataFolder	= design_path
#--- Create bGPLVM model ---#
model =bGPLVM(  dataFolder,         #Path to training data
                data_latent,        #Extracted features
              	data_Model,         #Path to model data
                "",                 #Sampels from faulty classes
                "",                 #Path to excluded featues
                nrInd,              #Number of inducing pts
                latentDim,          #Number of latent dimensions
                (image_dim[1],image_dim[0]))       #Reshaping image
#---------------------#
#--- Do prediction ---#
#---------------------#
#Load data
data_pos = np.loadtxt(path_pos, delimiter=',')
data_neg = np.loadtxt(path_neg, delimiter=',')
print("Loaded [%dx%d] pos design data and [%dx%d] pos design data"%(data_pos.shape[0],data_pos.shape[1],data_neg.shape[0],data_neg.shape[1]))
#Pos data
data_pos_scaled=model.Data_full.scaler.transform(data_pos) #Scale positive data
projection_mu, projection_var = model.model.infer_newX(data_pos_scaled) #Project positive data
pos_mu = projection_mu.mean #Get values
#Neg data
data_neg_scaled=model.Data_full.scaler.transform(data_neg) #Scale positive data
projection_mu, projection_var = model.model.infer_newX(data_neg_scaled) #Project positive data
neg_mu = projection_mu.mean #Get values
#------------------------------------------#
#--- Create data to store and store it! ---#
#------------------------------------------#
data = np.concatenate((pos_mu,neg_mu),axis=0) #Get data
target = np.concatenate((np.ones((pos_mu.shape[0],)),np.zeros((neg_mu.shape[0],)))) #Create inherent target vector
print("Created [%dx%d] design matrix"%(data.shape[0],data.shape[1]))
print("Created target vector: ", target.shape)
#--- Store it ---#
np.savetxt("design.csv", data, delimiter=',')
np.savetxt("target.csv", target, delimiter=',')
