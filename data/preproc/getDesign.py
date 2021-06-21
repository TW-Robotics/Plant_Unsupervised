# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
from flattenImage import flatten
import sys
import os
import cv2
import numpy as np
import csv
#------------------------#
#--- Global functions ---#
#------------------------#
def getMinImg(images_list,path):
    img = cv2.imread(path+"/"+images_list[0])    #Load image from folder
    Xmn,Ymn,_ = img.shape   #Get image shape
    for index in range(1,len(images_list)):
        img = cv2.imread(path+"/"+images_list[index])    #Load image from folder
        X,Y,_ = img.shape #Get image shape
        if Y<Ymn:   #Check if current image width is smaller
            Ymn = Y
            Xmn = X   
    return( (Ymn,Xmn) ) #Return minimum X and y shape

#-----------------------#
#--- Main processing ---#
#-----------------------#
#--- Get parameter from terminal ---#
if(len(sys.argv) < 3):
    data_folder = "../data/SugarBeet"
    postfix = "png"
else:
    data_folder = sys.argv[1]       #Get path to data
    postfix = sys.argv[2]           #Get image ending
print("Folder to process %s" % data_folder)
print("Seek images with ending %s" % postfix)
#---------------------#
#--- Get all files ---#
#---------------------#
files_raw = os.listdir(data_folder) #Get all files in given folder
files = [ filename for filename in files_raw if filename.endswith( postfix ) ]  #Just files with ending
files_neg = [ filename for filename in files if filename[0:3]=="neg" ]  #Neg files
files_pos = [ filename for filename in files if filename[0:3]=="pos" ]  #pos files
minimum_shape=getMinImg(files, data_folder) #Get minimal image shape
#print(minimum_shape)
#sys.exit(-1)
#-------------------------------#
#--- Function to store image ---#
#-------------------------------#
def storeImg(image, name):
    img=image.copy()
    img = (img-np.min(img))/(np.max(img)-np.min(img))*255.
    img = img.astype(np.uint8)
    cv2.imwrite(name,img)
#------------------------------------#
#--- loop over all positive files ---#
#------------------------------------#
design_raw = [] #Memory for flattend images
label_raw = []  #Memory for label
for POS_FILE in files_pos:#Loop over all positive files
    GRAY = False
    if(GRAY):
        img = cv2.imread(data_folder+"/"+POS_FILE,cv2.IMREAD_GRAYSCALE) #Load image
    else: 
        img = cv2.imread(data_folder+"/"+POS_FILE) #Load image
        img = img.astype(float)
        VI = 2.*img[:,:,1]-img[:,:,0]-img[:,:,2] #2*G-B-R
        img = VI
        #cv2.imshow("test", (VI-np.min(VI))/(np.max(VI)-np.min(VI))); cv2.waitKey(0);
    #img.resize(minimum_shape)
    img=cv2.resize(img,minimum_shape)
    #--- Store file as image ---#
    storeImg(img,POS_FILE)
    #--- Create design matrix ---#
    img_vector = flatten(img)       #Flatten to vector
    design_raw.append(img_vector)   #Extend memory
    #--- Create label vector ---#
    label_raw.append(os.path.splitext(POS_FILE)[0]) #Remove file ending and extend list
design = np.array(design_raw)   #Convert to numpy array
with open("pos_label.csv", 'w+') as myfile:
    wr = csv.writer(myfile)
    wr.writerow(label_raw) 
np.savetxt("pos_design.csv", design, delimiter=',')
print("Store a [%d x %d] matrix for %d images and resize to [%d x %d]" % (design.shape[0],design.shape[1], len(files_pos), minimum_shape[0], minimum_shape[1]))
#------------------------------------#
#--- loop over all negative files ---#
#------------------------------------#
design_raw = [] #Memory for flattend images
label_raw = []  #Memory for label
for NEG_FILE in files_neg:#Loop over all positive files
    if(GRAY):
        img = cv2.imread(data_folder+"/"+NEG_FILE,cv2.IMREAD_GRAYSCALE) #Load image
    else: 
        img = cv2.imread(data_folder+"/"+NEG_FILE) #Load image
        img = img.astype(float)
        VI = 2.*img[:,:,1]-img[:,:,0]-img[:,:,2] #2*G-B-R
        img = VI
    #img.resize(minimum_shape)
    img=cv2.resize(img,minimum_shape)
    #--- Store file as image ---#
    storeImg(img,NEG_FILE)
    #--- Create design matrix ---#
    img_vector = flatten(img)       #Flatten to vector
    design_raw.append(img_vector)   #Extend memory
    #--- Create label vector ---#
    label_raw.append(os.path.splitext(NEG_FILE)[0]) #Remove file ending and extend list
design = np.array(design_raw)   #Convert to numpy array
with open("neg_label.csv", 'w+') as myfile:
    wr = csv.writer(myfile)
    wr.writerow(label_raw) 
np.savetxt("neg_design.csv", design, delimiter=',')
print("Store a [%d x %d] matrix for %d images and resize to [%d x %d]" % (design.shape[0],design.shape[1], len(files_neg), minimum_shape[0], minimum_shape[1]))

