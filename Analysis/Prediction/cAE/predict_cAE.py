# This script loads given model (hopefully the ''best'') and predicts
# for given image paths.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Woeber 2021 <wilfried.woeber@technikum-wien.at>
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras import models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import numpy as np
import matplotlib.pyplot as plt
import sys
import os
#--- Manage physical memory ---#
physical_devices = tf.config.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(physical_devices[0], True)
#------------------------------#
#--- Define global settings ---#
#------------------------------#
if(len(sys.argv) != 5):
    train_dir= './data/Carrots/'
    best_model_path= '../../../Autoencoder/IT_10/Carrots/20'
    img_sizeX = 64
    img_sizeY = 64
else:
    train_dir=sys.argv[1]       #Train folder generated by bash script
    best_model_path=sys.argv[2] #Get path to best model csv file
    img_sizeX = int(sys.argv[3])     #Image size in X
    img_sizeY = int(sys.argv[4])     #Image size in Y
#--- Go ahead ---#
train_batchsize = 8         #Used batches for training
val_batchsize = 5           #Validation batchsize
#------------------#
#--- Load model ---#
#------------------#
model = models.load_model(best_model_path+"/my_model")
#---------------#
#--- Use cAE ---#
#---------------#
train_im = ImageDataGenerator(rescale=1./255)
def test_images():
    train_generator = train_im.flow_from_directory (
            train_dir, 
            target_size=(img_sizeX,img_sizeY),
            #color_mode='rgb',
            #batch_size=200,
            shuffle = False,
            class_mode='categorical'
         )
    x =  train_generator
    #return x[0][0], x[0][1], train_generator.filenames
    return x, train_generator.filenames
test_data = test_images()
encoder = Model(inputs=model.input, outputs=model.get_layer('Code').output)
prediction = encoder.predict(test_data[0])
np.savetxt("prediction.csv", prediction, delimiter=',')
np.savetxt("labels.csv", test_data[1],delimiter=",", fmt="%s")