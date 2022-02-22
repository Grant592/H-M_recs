from tensorflow.keras.models import Model
from tensorflow.keras.applications import resnet_v2
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.preprocessing import image
import numpy as np


class ImageEmbedder():
    
    def __init__(self):
        
        self._IMAGE_TARGET_SIZE = (224,224)

        pre_trained_model = resnet_v2.ResNet50V2(
            input_shape = (224, 224, 3), 
            weights = 'imagenet',
            include_top=True
        )

        self.embedding_model = Model(
            inputs=pre_trained_model.input,
            outputs=pre_trained_model.get_layer('avg_pool').output
        )
    
    def create_embedding(self, image_path):
        img = image.load_img(
            image_path,
            target_size=self._IMAGE_TARGET_SIZE
        )

        img_vec = image.img_to_array(img)
        img_vec = np.expand_dims(img_vec, axis=0)
        img_vec = resnet_v2.preprocess_input(img_vec)
        
        return self.embedding_model.predict(img_vec)
        