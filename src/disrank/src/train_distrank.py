# linear regression
import os
import numpy as np
np.random.seed(1337)
import matplotlib.pyplot as plt
import tensorflow as tf
import keras.backend as K
import keras
from keras import metrics, initializers, utils, regularizers
from keras.models import Sequential, Model, load_model
from keras.layers import Input, Dense, Dropout, Activation, Flatten
from keras.layers.convolutional import Conv2D, Conv1D
from keras.engine.topology import Layer
from keras.optimizers import Adam, SGD

class InstanceNormalization(Layer):
    def __init__(self, axis=-1, epsilon=1e-5, **kwargs):
        super(InstanceNormalization, self).__init__(**kwargs)
        self.axis = axis
        self.epsilon = epsilon

    def build(self, input_shape):
        dim = input_shape[self.axis]
        if dim is None:
            raise ValueError('Axis '+str(self.axis)+' of input tensor should have a defined dimension but the layer received an input with shape '+str(input_shape)+ '.')
        shape = (dim,)

        self.gamma = self.add_weight(shape=shape, name='gamma', initializer=initializers.random_normal(1.0, 0.02))
        self.beta = self.add_weight(shape=shape, name='beta', initializer='zeros')
        self.built = True

    def call(self, inputs, training=None):
        mean, var = tf.nn.moments(inputs, axes=[1,2], keep_dims=True)
        return K.batch_normalization(inputs, mean, var, self.beta, self.gamma, self.epsilon)

data_file = open('/mnt/data/zhiye/Python/DistRank/output/m_r_AGR_11k/train_data.txt', 'r')
model_name = '/mnt/data/zhiye/Python/DistRank/model/model.h5'
data = []
for line in data_file.readlines():
    line_list = line.strip('\n').split('\t')
    line_select = line_list[1:]
    data.append(line_select)
data = np.array(data)
np.random.shuffle(data)

X = data[:,0:-1]
Y = data[:,-1]
Y = keras.utils.to_categorical(Y, 10)

X_train, Y_train = X[:300, :], Y[:300]
# X_train = X_train.reshape(300, -1, 1)
X_test, Y_test = X[300:, :], Y[300:]
# X_test = X_test.reshape(50, -1, 1)
print("train shape: %s, %s"%(X_train.shape, Y_train.shape))

input =  Input(shape=(8,))
# Temp = Conv1D(filters=16, kernel_size=1 ,use_bias=True,kernel_initializer = "he_normal", kernel_regularizer=regularizers.l2(1.e-4))(input)
# Temp = Dense(8)(input)
# # Temp = InstanceNormalization(axis=-1)(Temp)
# Temp = Activation("relu")(Temp)
# # Temp = Dropout(0.3)(Temp)
# # Temp = Conv1D(filters=32, kernel_size=1 ,use_bias=True,kernel_initializer = "he_normal", kernel_regularizer=regularizers.l2(1.e-4))(Temp)
# Temp = Dense(64)(Temp)
# Temp = InstanceNormalization(axis=-1)(Temp)
# Temp = Activation("relu")(Temp)
# Temp = Dropout(0.3)(Temp)
# # Temp = Conv1D(filters=128, kernel_size=1 ,use_bias=True,kernel_initializer = "he_normal", kernel_regularizer=regularizers.l2(1.e-4))(Temp)
# Temp = Dense(128)(Temp)
# Temp = InstanceNormalization(axis=-1)(Temp)
# Temp = Activation("relu")(Temp)
# # Temp = Dropout(0.3)(Temp)
# # Temp = Conv1D(filters=64, kernel_size=1 ,use_bias=True,kernel_initializer = "he_normal", kernel_regularizer=regularizers.l2(1.e-4))(Temp)
# Temp = Dense(64)(Temp)
# Temp = InstanceNormalization(axis=-1)(Temp)
# Temp = Activation("relu")(Temp)
# Temp = Dropout(0.3)(Temp)
# Temp = Flatten()(Temp)

Temp = Dense(16)(input)
Temp = Activation("relu")(Temp)
Temp = Dropout(0.3)(Temp)
Temp = Dense(64)(Temp)
Temp = Activation("relu")(Temp)
Temp = Dropout(0.3)(Temp)
Temp = Dense(128)(Temp)
Temp = Activation("relu")(Temp)
Temp = Dropout(0.3)(Temp)
Temp = Dense(32)(Temp)
Temp = Activation("relu")(Temp)
Temp = Dropout(0.3)(Temp)
Temp = Dense(10)(Temp)
Temp = Activation("softmax")(Temp)
output = Temp
RANK = Model(inputs=input, outputs=output)
opt = Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.0000)
# opt = SGD(lr=0.0001, momentum=0.9, decay=0.00, nesterov=False)
RANK.compile(loss='categorical_crossentropy', optimizer=opt, metrics=['accuracy'])
RANK.summary()

history = RANK.fit(X_train, Y_train, epochs=300, batch_size=8, shuffle=True, validation_data=(X_test, Y_test))
RANK.save(model_name)

plt.plot(history.history['acc'])
plt.plot(history.history['val_acc'])
plt.title('Model accuracy')
plt.ylabel('Accuracy')
plt.xlabel('Epoch')
plt.legend(['Train', 'Test'], loc='upper left')
plt.show()

plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('Model loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['Train', 'Test'], loc='upper left')
plt.show()

# evaluate
accuracy = RANK.evaluate(X_test, Y_test)
print(accuracy)
# print('accurcy: %f' % (accuracy))


## linear regression predict
# main_dir = '/mnt/data/zhiye/Python/DistRank/output/m_r_AGR_11k/'
# RANK = load_model(model_name)
# data_file = open(main_dir+'train_data.txt', 'r')
# pred_file = main_dir + '/pred.txt'
# if os.path.exists(pred_file):os.remove(pred_file)
# for line in data_file.readlines():
#     line_list = line.strip('\n').split('\t')
#     temp_name = line_list[0]
#     print("pred %s"%temp_name)
#     temp_true_rank = line_list[-1]
#     line_select = line_list[1:-1]
#     data_input = np.array(line_select)
#     data_input = data_input.reshape(1,-1)
#     temp_pred_ramk = RANK.predict(data_input)[0][0]
#     with open(pred_file, 'a') as myfile:
#         str_to_write = "%s\t%s\t%.4f\n"%(temp_name, temp_true_rank, temp_pred_ramk)
#         myfile.write(str_to_write)