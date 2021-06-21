# This script visualizes the top features for all used unsupervised models.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
import matplotlib
matplotlib.use('Agg')
import numpy as np
import matplotlib.pyplot as plt #We aim to plot something...
import cv2
row_elements=10
#-----------------------------#
#--- Set parts to the data ---#
#-----------------------------#
#best_cAE_C=$(cat ../Autoencoder/modelSelection/best_model_Carrots.csv) #Best cAE folder for carrot
#best_cAE_S=$(cat ../Autoencoder/modelSelection/best_model_SugarB.csv) #Best cAE folder for sugar B
best_cAE_C_raw=str(np.loadtxt("../Autoencoder/modelSelection/best_model_Carrots.csv",dtype='str'))
best_cAE_S_raw=str(np.loadtxt("../Autoencoder/modelSelection/best_model_SugarB.csv",dtype='str'))
best_cAE_C=str.split(best_cAE_C_raw,"/")[1]+"_"+str.split(best_cAE_C_raw,"/")[2]
best_cAE_S=str.split(best_cAE_S_raw,"/")[1]+"_"+str.split(best_cAE_S_raw,"/")[2]
path_pVals = (  '../../GPLVM/Carrots/Heatmaps/', #GPLVM carrot heatmap
                '../../GPLVM/SugarB/Heatmaps/', #GPLVM sugar B heatmap
                '../Autoencoder/modelSelection/'+best_cAE_C+"/",  #Same basepath for both cAE's
                '../Autoencoder/modelSelection/'+best_cAE_S+"/"
                ) #Path to the p-value heatmaps 
path_features = (   '../FeatureSelection/Carrot_GPLVM.csv', #Path to selection of GPLVM
                    '../FeatureSelection/SugarB_GPLVM.csv', #Path to selection of GPLVM
                    '../FeatureSelection/Carrot_cAE.csv', #Path to selection of cAE
                    '../FeatureSelection/SugarB_cAE.csv', #Path to selection of cAE
                ) #Path to the selected featurer
model_name=('GPLVM_C','GPLVM_S','cAE_C','cAE_S')
model_title=(   'B-GP-LVM Daucus carota',
                'B-GP-LVM Beta vulgaris',
                'cAE Daucus carota',
                'cAE Beta vulgaris')
model_prefix=('','','HM_','HM_')
model_delimiter=(',',',',' ',' ')
#------------------------#
#--- Process the data ---#
#------------------------#
for i in range(0,len(path_pVals)): #Loop over all models
    pVal_path = path_pVals[i] #Get path to pvals
    features = np.loadtxt(path_features[i],dtype=int)
    print("Process %s"%pVal_path)
    #--- Load features ---#
    row_pvals = () #Memory for rows
    col_pvals = () #Memory for cols
    for k in range(0,len(features)): #Load features
        #--- Raw heatmap ---#
        csv_HM=np.loadtxt(pVal_path+model_prefix[i]+str(k)+".csv",delimiter=model_delimiter[i]) #Load the p value
        if( model_prefix[i] == ''): #Just transpose B-GP-LVM features
            csv_HM = np.transpose(csv_HM)
        csv_HM= (csv_HM-np.min(csv_HM))/(np.max(csv_HM)-np.min(csv_HM))*255.
        csv_HM=csv_HM.astype(np.uint8)
        csv_HM=cv2.applyColorMap(255-csv_HM, cv2.COLORMAP_JET)
        csv_HM=cv2.copyMakeBorder(csv_HM,2,0,2,2,cv2.BORDER_CONSTANT,value=[0,0,0])
        #--- The p val image ---#
        csv_pval=np.loadtxt(pVal_path+"HM_"+str(k)+"_p.csv") #Load the p value
        csv_pval= (csv_pval-np.min(csv_pval))/(np.max(csv_pval)-np.min(csv_pval))*255.
        csv_pval=csv_pval.astype(np.uint8)
        csv_pval=cv2.applyColorMap(255-csv_pval, cv2.COLORMAP_JET)
        csv_pval=cv2.copyMakeBorder(csv_pval,2,2,2,2,cv2.BORDER_CONSTANT,value=[0,0,0])
        #--- Combine images ---#
        csv_pval=np.concatenate((csv_HM,csv_pval),axis=0)
        #--- Create image ---#
        if(len(row_pvals)==0):
            row_pvals=csv_pval #Init the row
        else: #extend p val
            row_pvals=np.concatenate((row_pvals,csv_pval),axis=1)
        #--- Process finished row ---#
        if(((k+1)%row_elements) == 0):#the row is finished
            #--- Extend col ---#
            if(len(col_pvals)==0):
                col_pvals=row_pvals #Init column memory
                #--- Store first row ---#
                plt.imshow(col_pvals)
                plt.title(model_title[i])
                plt.axis('off')
                plt.savefig("first10_"+model_name[i]+".png",bbox_inches = 'tight',pad_inches = 0)
                plt.savefig("first10_"+model_name[i]+".pdf",bbox_inches = 'tight',pad_inches = 0)
                plt.close()
            else:
                col_pvals=np.concatenate((col_pvals,row_pvals),axis=0) #Extend column
            #--- Reset row ---#
            row_pvals=() #Reset row
    #End feature load loop
    # We now must to add the remaining cells in the row
    if((row_elements-k%row_elements-1) > 0): #Just if we need to...
        last_row=np.concatenate((
                            row_pvals,
                            np.zeros((csv_pval.shape[0], #Rows remains the same
                                    (row_elements-k%row_elements-1)*csv_pval.shape[1],3 #Add missing cells
                            ),dtype=np.uint8)), axis=1)
        col_pvals=np.concatenate((col_pvals,last_row),axis=0)
    #--- Store image ---#
    plt.imshow(col_pvals)
    plt.axis('off')
    plt.savefig("Features_"+model_name[i]+".png",bbox_inches = 'tight',pad_inches = 0)
    plt.savefig("Features_"+model_name[i]+".pdf",bbox_inches = 'tight',pad_inches = 0)
    plt.close()
#End loop range over models
#We are done