# This file reads the image annotation and extracts the plant images as well 
# as background images.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
import numpy as np
import cv2
#Reads the annotation and extracts the images
def getImages(filepath):
    myfile = open(filepath, 'r') #Open the annotation file
    Lines = myfile.readlines() #Get the lines in the annotation file
    folder=filepath[0:filepath.rfind("/")+1] #Path to images
    #--- process the annotation ---#
    pos_looper=0 #Positive image looper
    neg_looper=0 #Negative image looper
    for line in Lines: #For all found images
        #--- Get info from annotation ---#
        image_name=line.split(";")[0] #Get image name
        img_class=int(line.split(";")[1]) #Get image class (pos/neg)
        obj_x=int(line.split(";")[2]) #Get objects x position
        obj_y=int(line.split(";")[3]) #Get objects y position
        obj_W=int(line.split(";")[4]) #Get objects width
        obj_H=int(line.split(";")[5].strip()) #Get objects height
        #--- Get a square ---#
        center_x = obj_x+int(obj_W/2)
        center_y = obj_y+int(obj_H/2)
        if(obj_W>obj_H): #I know... but its readable
           obj_WH = obj_W
        else:
           obj_WH = obj_H
        #--- Rebuild the positions ---#
        obj_x = center_x-int(obj_WH/2)
        obj_y = center_y-int(obj_WH/2)
        obj_W=obj_WH
        obj_H=obj_WH
        #--- Cat errors ---#
        if(obj_y < 0):
            obj_y=0
        print("Load img %s"%image_name)
        print("(%d, %d, %d, %d)"%(obj_x, obj_y, obj_W, obj_H))
        #--- Load image ---#
        img = cv2.imread(folder+image_name) #Load image
        cut=img[obj_y:(obj_y+obj_H),obj_x:(obj_x+obj_W)]
        cv2.imshow("test",cut)
        cv2.waitKey(1)
        #--- Store images ---#
        if(img_class == 0):
            cv2.imwrite("pos_"+str(pos_looper)+".png",cut)
            pos_looper=pos_looper+1
        elif(img_class == 1):
            cv2.imwrite("neg_"+str(neg_looper)+".png",cut)
            neg_looper=neg_looper+1

if __name__ == "__main__":
    import os
    path_carrots="./rawImages/carrot/annotation.csv" #Path to carrot annotation
    path_rueben ="./rawImages/ruebe/annotation.csv" #Path to sugar beet annotation
    #--- Get carrot images ---#
    getImages(path_carrots) #Get carrot images
    os.system("mkdir Carrots; mv *.png Carrots/.")
    #--- Get sugar beet images ---#
    getImages(path_rueben) #Get suagr beet images
    os.system("mkdir Rueben; mv *.png Rueben/.")

