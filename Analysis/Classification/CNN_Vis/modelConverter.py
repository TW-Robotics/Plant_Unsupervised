# This script converts a new TF2 format to an old hf format.
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
#Carrot
model = models.load_model("Carrot/CNNmodel")
model.save("Carrot/CNNModel",save_format='h5')
#sugarB
model = models.load_model("SugarB/CNNmodel")
model.save("SugarB/CNNModel",save_format='h5')
