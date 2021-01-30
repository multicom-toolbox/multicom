# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 21:41:28 2019

@author: Zhiye
"""

import keras.backend as K
from keras.datasets import mnist
from keras.engine.topology import Layer
from keras.layers import Input, Dense, Reshape, Activation, Flatten, Embedding, merge, Merge, Dropout, Lambda, add, concatenate, Concatenate, ConvLSTM2D, LSTM, average, MaxPooling2D, multiply, MaxPooling3D
from keras.layers import GlobalAveragePooling2D, Permute
from keras.layers.advanced_activations import LeakyReLU, PReLU
from keras.layers.convolutional import UpSampling2D, Conv2D, Conv1D
from keras.models import Sequential, Model
from keras.optimizers import Adam
from keras.utils import multi_gpu_model
from keras.constraints import maxnorm
from keras.layers.normalization import BatchNormalization
from keras.activations import tanh, softmax
from keras import metrics, initializers, utils, regularizers
import numpy as np

import tensorflow as tf
import sys
sys.setrecursionlimit(10000)
# Helper to build a conv -> BN -> relu block
def _conv_bn_relu1D_test(filters, kernel_size, strides,use_bias=True):
    def f(input):
        conv = Conv1D(filters=filters, kernel_size=kernel_size, strides=strides,use_bias=use_bias,
                             kernel_initializer="he_normal", activation='relu', padding="same")(input)
        return Activation("sigmoid")(conv)
    return f

# Helper to build a conv -> BN -> relu block
def _conv_bn_relu1D(filters, kernel_size, strides,use_bias=True, kernel_initializer = "he_normal"):
    def f(input):
        conv = Conv1D(filters=filters, kernel_size=kernel_size, strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same")(input)
        norm = BatchNormalization(axis=-1)(conv)
        return Activation("relu")(norm)
    return f

def _in_relu_conv1D(filters, kernel_size, strides,use_bias=True, kernel_initializer = "he_normal"):
    def f(input):
        act = _in_relu(input)
        conv = Conv1D(filters=filters, kernel_size=kernel_size, strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same")(act)
        return conv
    return f

def _conv_in_relu1D(filters, kernel_size, strides,use_bias=True, kernel_initializer = "he_normal"):
    def f(input):
        conv = Conv1D(filters=filters, kernel_size=kernel_size, strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same")(input)
        norm = InstanceNormalization(axis=-1)(conv)
        return Activation("relu")(norm)
    return f

def _bn_relu(input):
    norm = BatchNormalization(axis=-1)(input)
    return Activation("relu")(norm)

def _in_relu(input):
    norm = InstanceNormalization(axis=-1)(input)
    return Activation("relu")(norm)

def _in_elu(input):
    norm = InstanceNormalization(axis=-1)(input)
    return Activation("elu")(norm)

def _bn_relu_conv2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None, dilation_rate=(1,1)):
    def f(input):
        act = _bn_relu(input)
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer, dilation_rate = dilation_rate)(act)
        return conv
    return f

def _in_relu_conv2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None, dilation_rate=(1,1)):
    def f(input):
        act = _in_relu(input)
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer, dilation_rate = dilation_rate)(act)
        return conv
    return f

def _in_elu_conv2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None, dilation_rate=(1,1)):
    def f(input):
        act = _in_elu(input)
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer, dilation_rate = dilation_rate)(act)
        return conv
    return f

def _conv_bn_relu2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None, dilation_rate=(1,1)):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer, dilation_rate = dilation_rate)(input)
        # norm = BatchNormalization(axis=-1)(conv)
        norm = BatchNormalization(axis=-1)(conv)
        return Activation("relu")(norm)
    return f

def _conv_in_relu2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None, dilation_rate=(1,1)):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer, dilation_rate = dilation_rate)(input)
        norm = InstanceNormalization(axis=-1)(conv)
        return Activation("relu")(norm)
    return f

def _conv_rcin_relu2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None, dilation_rate=(1,1)):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer, dilation_rate = dilation_rate)(input)
        norm1 = InstanceNormalization(axis=-1)(conv)
        norm2 = RowNormalization(axis=-1)(conv)
        norm3 = ColumNormalization(axis=-1)(conv)
        norm  = concatenate([norm1, norm2, norm3])
        return Activation("relu")(norm)
    return f

def _conv_in_dropout_relu2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None,dropout_rate=0.2):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer)(input)
        norm = InstanceNormalization(axis=-1)(conv)
        drop = Dropout(dropout_rate)(norm)
        return Activation("relu")(drop)
    return f

def _conv_rcin_dropout_relu2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None,dropout_rate=0.2):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer)(input)
        norm1 = InstanceNormalization(axis=-1)(conv)
        norm2 = RowNormalization(axis=-1)(conv)
        norm3 = ColumNormalization(axis=-1)(conv)
        norm  = concatenate([norm1, norm2, norm3])
        drop = Dropout(dropout_rate)(norm)
        return Activation("relu")(drop)
    return f

def _conv_relu1D(filters, kernel_size, strides, use_bias=True, kernel_initializer = "he_normal"):
    def f(input):
        conv = Conv1D(filters=filters, kernel_size=kernel_size, strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same")(input)
        return Activation("relu")(conv)
    return f

# Helper to build a conv -> BN -> relu block
def _conv_relu2D(filters, nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal", dilation_rate=(1, 1)):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides, use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", dilation_rate=dilation_rate)(input)
        # norm = BatchNormalization(axis=1)(conv)
        return Activation("relu")(conv)
    return f

def _in_sigmoid(input):
    norm = InstanceNormalization(axis=-1)(input)
    return Activation("sigmoid")(norm)

def _in_sigmoid_conv2D(filters,  nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal",  kernel_regularizer=None):
    def f(input):
        act = _in_sigmoid(input)
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", kernel_regularizer=kernel_regularizer)(act)
        return conv
    return f

def _conv_in_sigmoid2D(filters, nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal", dilation_rate=(1, 1)):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", dilation_rate=dilation_rate)(input)
        norm = InstanceNormalization(axis=-1)(conv)
        return Activation("sigmoid")(conv)
    
    return f

def _conv_bn_sigmoid2D(filters, nb_row, nb_col, strides=(1, 1), use_bias=True, kernel_initializer = "he_normal", dilation_rate=(1, 1)):
    def f(input):
        conv = Conv2D(filters=filters, kernel_size=(nb_row, nb_col), strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same", dilation_rate=dilation_rate)(input)
        norm = BatchNormalization(axis=-1)(conv)
        return Activation("sigmoid")(conv)
    
    return f

# Helper to build a conv -> BN -> softmax block
def _conv_bn_softmax1D(filters, kernel_size, strides, name,use_bias=True, kernel_initializer = "he_normal"):
    def f(input):
        conv = Conv1D(filters=filters, kernel_size=kernel_size, strides=strides,use_bias=use_bias,
                             kernel_initializer=kernel_initializer, padding="same",name="%s_conv" % name)(input)
        norm = BatchNormalization(axis=-1,name="%s_nor" % name)(conv)
        return Dense(units=3, kernel_initializer=kernel_initializer,name="%s_softmax" % name, activation="softmax")(norm)
    
    return f

def _attention_layer(input_dim):
    def f(input):
        attention_probs = Dense(input_dim, activation='softmax')(input)
        attention_mul = merge([input, attention_probs],output_shape=input_dim, mode='mul')
        return attention_mul
    return f

def _weighted_mean_squared_error(weight):
    def loss(y_true, y_pred):
        #set 20A as thresold
        # y_bool = Lambda(lambda x: x <= 20.0)(y_pred)
        y_bool = K.cast((y_true <= 20.0), dtype='float32')
        y_bool_invert = K.cast((y_true > 20.0), dtype='float32')
        y_mean = K.mean(y_true)
        y_pred_below = y_pred * y_bool 
        y_pred_upper = y_pred * y_bool_invert 
        y_true_below = y_true * y_bool 
        y_true_upper = y_true * y_bool_invert 
        # y_pred_upper = multiply([y_pred, y_bool_invert])
        # y_true_below = multiply([y_true, y_bool])
        # y_true_upper = multiply([y_true, y_bool_invert])
        weights1 = 1
        # weights2 = 0
        weights2 = 1/(1 + K.square(y_pred_upper/y_mean))
        return K.mean(K.square((y_pred_below-y_true_below))*weights1) + K.mean(K.square((y_pred_upper-y_true_upper))*weights2)
        # return add([K.mean(K.square((y_pred_below-y_true_below))*weights1), K.mean(K.square((y_pred_upper-y_true_upper))*weights2)], axis= -1)
    return loss

def _weighted_categorical_crossentropy(weights):
    weights = K.variable(weights)

    def loss(y_true, y_pred):
        # scale predictions so that the class probas of each sample sum to 1
        y_pred /= K.sum(y_pred, axis=-1, keepdims=True)
        # clip to prevent NaN's and Inf's
        y_pred = K.clip(y_pred, K.epsilon(), 1 - K.epsilon())
        # calc
        loss = y_true * K.log(y_pred) * weights
        loss = -K.sum(loss, -1)
        return loss

    return loss

def _weighted_binary_crossentropy(pos_weight=1, neg_weight=1):

    def loss(y_true, y_pred):
        binary_crossentropy = K.binary_crossentropy(y_true, y_pred)
        weights = y_true * pos_weight + (1. - y_true) * neg_weight
        weighted_binary_crossentropy_vector = weights * binary_crossentropy
        return K.mean(weighted_binary_crossentropy_vector)
    return loss

def _weighted_binary_crossentropy_shield(pos_weight=1, neg_weight=1, shield=0):

    def loss(y_true, y_pred):
        y_pred /= K.sum(y_pred, axis=-1, keepdims=True)
        y_pred = K.clip(y_pred, K.epsilon(), 1.0-K.epsilon())
        # cross-entropy loss with weighting
        out = -(y_true * K.log(y_pred)*pos_weight+ (1.0 - y_true) * K.log(1.0 - y_pred)*neg_weight)
        return K.mean(out, axis=-1)
    return loss

def MaxoutAct(input, filters, kernel_size, output_dim, padding='same', activation = "relu"):
    output = None
    for _ in range(output_dim):
        conv = Conv2D(filters=filters, kernel_size=kernel_size, padding=padding)(input)
        activa = Activation(activation)(conv)
        maxout_out = Lambda(lambda x: K.max(x, axis=-1, keepdims=True))(activa)
        if output is not None:
            output = concatenate([output, maxout_out], axis=-1)
        else:
            output = maxout_out
    return output

def MaxoutCov(input, output_dim):
    output = None
    for i in range(output_dim):
        section = Lambda(lambda x:x[:,:,:,2*i:2*i+1])(input)
        maxout_out = Lambda(lambda x: K.max(x, axis=-1, keepdims=True))(section)
        if output is not None:
            output = concatenate([output, maxout_out], axis=-1)
        else:
            output = maxout_out
    return output

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

class RowNormalization(Layer):
    def __init__(self, axis=-1, epsilon=1e-5, **kwargs):
        super(RowNormalization, self).__init__(**kwargs)
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
        mean, var = tf.nn.moments(inputs, axes=[1], keep_dims=True)
        return K.batch_normalization(inputs, mean, var, self.beta, self.gamma, self.epsilon)

class ColumNormalization(Layer):
    def __init__(self, axis=-1, epsilon=1e-5, **kwargs):
        super(ColumNormalization, self).__init__(**kwargs)
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
        mean, var = tf.nn.moments(inputs, axes=[2], keep_dims=True)
        return K.batch_normalization(inputs, mean, var, self.beta, self.gamma, self.epsilon)


def _attention_layer(input_dim):
    def f(input):
        attention_probs = Dense(input_dim, activation='softmax')(input)
        attention_mul = merge([input, attention_probs],output_shape=input_dim, mode='mul')
        return attention_mul
    return f

def _handle_dim_ordering():
    global ROW_AXIS
    global COL_AXIS
    global CHANNEL_AXIS
    if K.image_dim_ordering() == 'tf':
        ROW_AXIS = 1
        COL_AXIS = 2
        CHANNEL_AXIS = 3
    else:
        CHANNEL_AXIS = 1
        ROW_AXIS = 2
        COL_AXIS = 3

def _shortcut(input, residual):
    input_shape = K.int_shape(input)
    residual_shape = K.int_shape(residual)
    # stride_width = int(round(input_shape[ROW_AXIS] / residual_shape[ROW_AXIS]))
    # stride_height = int(round(input_shape[COL_AXIS] / residual_shape[COL_AXIS]))
    stride_width = 1
    stride_height = 1
    equal_channels = input_shape[CHANNEL_AXIS] == residual_shape[CHANNEL_AXIS]

    shortcut = input
    if not equal_channels:
        shortcut = Conv2D(filters=residual_shape[CHANNEL_AXIS],
                          kernel_size=(1, 1),
                          strides=(stride_width, stride_height),
                          padding="valid",
                          kernel_initializer="he_normal")(input)
    return add([shortcut, residual])

def _residual_block(block_function, filters, repetitions, is_first_layer=False, use_SE=False):
    def f(input):
        for i in range(repetitions):
            init_strides = (1, 1)
            if i == 0 and not is_first_layer:
                # init_strides = (2, 2)
                init_strides = (1, 1)
            input = block_function(filters=filters, init_strides=init_strides,
                                   is_first_block_of_first_layer=(is_first_layer and i == 0), use_SE = use_SE)(input)
        return input

    return f

def basic_block(filters, init_strides=(1, 1), is_first_block_of_first_layer=False, use_SE=False):
    def f(input):
        if is_first_block_of_first_layer:
            # don't repeat bn->relu since we just did bn->relu->maxpool
            conv1 = Conv2D(filters=filters, kernel_size=(3, 3),
                           strides=init_strides,
                           padding="same",
                           kernel_initializer="he_normal")(input)
                           # ,
                           # kernel_regularizer=regularizers.l2(1e-4)
        else:
            conv1 = _in_relu_conv2D(filters=filters, nb_row=3, nb_col=3,
                                  strides=init_strides)(input)

        residual = _in_relu_conv2D(filters=filters, nb_row=3, nb_col=3)(conv1)
        if use_SE == True:
            residual = squeeze_excite_block(residual)
        return _shortcut(input, residual)
    return f


def bottleneck(filters, init_strides=(1, 1), is_first_block_of_first_layer=False, use_SE=False):
    def f(input):

        if is_first_block_of_first_layer:
            # don't repeat bn->relu since we just did bn->relu->maxpool
            conv_1_1 = Conv2D(filters=filters, kernel_size=(1, 1),
                              strides=init_strides,
                              padding="same",
                              kernel_initializer="he_normal",
                              kernel_regularizer=regularizers.l2(1e-4))(input)
        else:
            conv_1_1 = _in_relu_conv2D(filters=filters, nb_row=1, nb_col=1,
                                     strides=init_strides)(input)

        conv_3_3 = _in_relu_conv2D(filters=filters, nb_row=3, nb_col=3)(conv_1_1)
        residual = _in_relu_conv2D(filters=filters * 2, nb_row=1, nb_col=1)(conv_3_3)
        if use_SE == True:
            residual = squeeze_excite_block(residual)
        return _shortcut(input, residual)

    return f

def squeeze_excite_block(input, ratio=16):
    ''' Create a channel-wise squeeze-excite block
    Args:
        input: input tensor
        filters: number of output filters
    Returns: a keras tensor
    References
    -   [Squeeze and Excitation Networks](https://arxiv.org/abs/1709.01507)
    '''
    init = input
    channel_axis = 1 if K.image_data_format() == "channels_first" else -1
    filters = init._keras_shape[channel_axis]
    se_shape = (1, 1, filters)

    se = GlobalAveragePooling2D()(init)
    se = Reshape(se_shape)(se)
    se = Dense(filters // ratio, activation='relu', kernel_initializer='he_normal', use_bias=False)(se)
    se = Dense(filters, activation='sigmoid', kernel_initializer='he_normal', use_bias=False)(se)

    if K.image_data_format() == 'channels_first':
        se = Permute((3, 1, 2))(se)

    x = multiply([init, se])
    return x

def basic_block_other_RC(filters, init_strides=(1, 1), is_first_block_of_first_layer=False, use_SE=False):
    def f(input):
        residual = input
        conv1 = _conv_rcin_dropout_relu2D(filters=filters, nb_row=3, nb_col=3,strides=init_strides)(input)
        conv2 = _conv_rcin_dropout_relu2D(filters=filters, nb_row=3, nb_col=3,strides=init_strides)(conv1)
        if use_SE == True:
            conv2 = squeeze_excite_block(conv2)
        return _shortcut(residual, conv2)
    return f

def basic_block_pre_RC(filters, init_strides=(1, 1), is_first_block_of_first_layer=False, use_SE=False):
    def f(input):
        residual = input
        conv1 = _conv_rcin_dropout_relu2D(filters=filters, nb_row=3, nb_col=3,strides=init_strides, dropout_rate=0.2)(input)
        conv2 = _conv_rcin_dropout_relu2D(filters=filters, nb_row=3, nb_col=3,strides=init_strides, dropout_rate=0.2)(conv1)
        if use_SE == True:
            conv2 = squeeze_excite_block(conv2)
        return _shortcut(residual, conv2)
    return f

def DeepResnetRC_with_paras_2D_other(kernel_size,feature_2D_num,filters,nb_layers,opt, initializer = "he_normal", loss_function = "binary_crossentropy"):
    contact_feature_num_2D=feature_2D_num
    contact_input_shape=(None,None,contact_feature_num_2D)
    contact_input = Input(shape=contact_input_shape)
    
    _handle_dim_ordering()
    DNCON4_2D_input = contact_input
    
    DNCON4_2D_convs = []

    DNCON4_2D_conv = DNCON4_2D_input
    DNCON4_2D_conv = InstanceNormalization(axis=-1)(DNCON4_2D_conv)

    DNCON4_2D_conv = _conv_rcin_relu2D(filters=64, nb_row=1, nb_col=1, strides=(1, 1))(DNCON4_2D_conv)
    block = DNCON4_2D_conv
    filters = 64
    # repetitions = [3, 8, 36, 3]
    if nb_layers == 34:
        repetitions = [3, 4, 6, 3]
        for i, r in enumerate(repetitions):
            block = _residual_block(basic_block_other_RC, filters=filters, repetitions=r)(block)
    elif nb_layers == 46:
        repetitions = [3, 6, 10, 3]
        for i, r in enumerate(repetitions):
            block = _residual_block(basic_block_other_RC, filters=filters, repetitions=r, is_first_layer=(i == 0), use_SE=True)(block)
    # Last activation
    DNCON4_2D_conv = Conv2D(filters=1, kernel_size=(3, 3), strides=(1, 1), padding="same",kernel_initializer="he_normal")(block)
    DNCON4_2D_conv = Activation("sigmoid")(DNCON4_2D_conv)

    if loss_function == 'binary_crossentropy':
        loss = loss_function
        
    DNCON4_2D_out = DNCON4_2D_conv
    DNCON4_RES = Model(inputs=contact_input, outputs=DNCON4_2D_out)
    # categorical_crossentropy
    DNCON4_RES.compile(loss=loss, metrics=['accuracy'], optimizer=opt)
    DNCON4_RES.summary()
    return DNCON4_RES

def DeepResnetRC_with_paras_2D_Pre(kernel_size,feature_2D_num, filters,nb_layers,opt, initializer = "he_normal", loss_function = "binary_crossentropy"):

    contact_feature_num_2D=feature_2D_num
    contact_input_shape=(None,None,contact_feature_num_2D)
    contact_input = Input(shape=contact_input_shape)
    
    _handle_dim_ordering()
    DNCON4_2D_input = contact_input
    
    DNCON4_2D_convs = []

    DNCON4_2D_conv = DNCON4_2D_input
    DNCON4_2D_conv = _conv_rcin_relu2D(filters=64, nb_row=1, nb_col=1, strides=(1, 1))(DNCON4_2D_conv)
    block = DNCON4_2D_conv
    filters = 64
    if nb_layers == 46:
        repetitions = [3, 6, 10, 3]
        for i, r in enumerate(repetitions):
            block = _residual_block(basic_block_pre_RC, filters=filters, repetitions=r, is_first_layer=(i == 0))(block)
    elif nb_layers == 45:
        repetitions = [3, 4, 6, 3]
        for i, r in enumerate(repetitions):
            block = _residual_block(basic_block_pre_RC, filters=filters, repetitions=r, is_first_layer=(i == 0), use_SE=True)(block)
    else: # default is 34 layer res
        repetitions = [3, 4, 6, 3]
        for i, r in enumerate(repetitions):
            block = _residual_block(basic_block_pre_RC, filters=filters, repetitions=r, is_first_layer=(i == 0), use_SE=True)(block)
    # Last activation
    DNCON4_2D_conv = Conv2D(filters=1, kernel_size=(3, 3), strides=(1, 1), padding="same",kernel_initializer="he_normal")(block)
    DNCON4_2D_conv = Activation("sigmoid")(DNCON4_2D_conv)

    if loss_function == 'binary_crossentropy':
        loss = loss_function
        
    DNCON4_2D_out = DNCON4_2D_conv
    DNCON4_RES = Model(inputs=contact_input, outputs=DNCON4_2D_out)
    # categorical_crossentropy
    DNCON4_RES.compile(loss=loss, metrics=['accuracy'], optimizer=opt)
    DNCON4_RES.summary()
    return DNCON4_RES

def _in_relu_K(x, bn_name=None, relu_name=None):
    """Helper to build a BN -> relu block
    """
    # norm = BatchNormalization(axis=CHANNEL_AXIS, name=bn_name)(x)
    norm = InstanceNormalization(axis=-1, name=bn_name)(x)
    return Activation("relu", name=relu_name)(norm)

def _conv_in_relu_K(**conv_params):
    filters = conv_params["filters"]
    kernel_size = conv_params["kernel_size"]
    strides = conv_params.setdefault("strides", (1, 1))
    dilation_rate = conv_params.setdefault("dilation_rate", (1, 1))
    conv_name = conv_params.setdefault("conv_name", None)
    bn_name = conv_params.setdefault("bn_name", None)
    relu_name = conv_params.setdefault("relu_name", None)
    kernel_initializer = conv_params.setdefault("kernel_initializer", "he_normal")
    padding = conv_params.setdefault("padding", "same")
    kernel_regularizer = conv_params.setdefault("kernel_regularizer", regularizers.l2(1.e-4))

    def f(x):
        x = Conv2D(filters=filters, kernel_size=kernel_size,
                   strides=strides, padding=padding,
                   dilation_rate=dilation_rate,
                   kernel_initializer=kernel_initializer,
                   kernel_regularizer=kernel_regularizer,
                   name=conv_name)(x)
        return _in_relu_K(x, bn_name=bn_name, relu_name=relu_name)

    return f

def _in_relu_conv_K(**conv_params):
    filters = conv_params["filters"]
    kernel_size = conv_params["kernel_size"]
    strides = conv_params.setdefault("strides", (1, 1))
    dilation_rate = conv_params.setdefault("dilation_rate", (1, 1))
    conv_name = conv_params.setdefault("conv_name", None)
    bn_name = conv_params.setdefault("bn_name", None)
    relu_name = conv_params.setdefault("relu_name", None)
    kernel_initializer = conv_params.setdefault("kernel_initializer", "he_normal")
    padding = conv_params.setdefault("padding", "same")
    kernel_regularizer = conv_params.setdefault("kernel_regularizer", regularizers.l2(1.e-4))

    def f(x):
        activation = _in_relu_K(x, bn_name=bn_name, relu_name=relu_name)
        return Conv2D(filters=filters, kernel_size=kernel_size,
                      strides=strides, padding=padding,
                      dilation_rate=dilation_rate,
                      kernel_initializer=kernel_initializer,
                      name=conv_name)(activation)
                      # kernel_regularizer=kernel_regularizer,

    return f

def _rcin_relu_K(x, bn_name=None, relu_name=None):
    norm1 = InstanceNormalization(axis=-1, name=bn_name)(x)
    norm2 = RowNormalization(axis=-1, name=bn_name)(x)
    norm3 = ColumNormalization(axis=-1, name=bn_name)(x)
    norm  = concatenate([norm1, norm2, norm3])
    return Activation("relu", name=relu_name)(norm)

def _rcin_relu_conv_K(**conv_params):
    filters = conv_params["filters"]
    kernel_size = conv_params["kernel_size"]
    strides = conv_params.setdefault("strides", (1, 1))
    dilation_rate = conv_params.setdefault("dilation_rate", (1, 1))
    conv_name = conv_params.setdefault("conv_name", None)
    bn_name = conv_params.setdefault("bn_name", None)
    relu_name = conv_params.setdefault("relu_name", None)
    kernel_initializer = conv_params.setdefault("kernel_initializer", "he_normal")
    padding = conv_params.setdefault("padding", "same")
    kernel_regularizer = conv_params.setdefault("kernel_regularizer", regularizers.l2(1.e-4))

    def f(x):
        activation = _rcin_relu_K(x, bn_name=bn_name, relu_name=relu_name)
        return Conv2D(filters=filters, kernel_size=kernel_size,
                      strides=strides, padding=padding,
                      dilation_rate=dilation_rate,
                      kernel_initializer=kernel_initializer,
                      name=conv_name)(activation)
                      # kernel_regularizer=kernel_regularizer,

    return f

def _shortcut_K(input_feature, residual, conv_name_base=None, bn_name_base=None):
    input_shape = K.int_shape(input_feature)
    residual_shape = K.int_shape(residual)
    equal_channels = input_shape[CHANNEL_AXIS] == residual_shape[CHANNEL_AXIS]

    shortcut = input_feature
    # 1 X 1 conv if shape is different. Else identity.
    if not equal_channels:
        print('reshaping via a convolution...')
        if conv_name_base is not None:
            conv_name_base = conv_name_base + '1'
        shortcut = Conv2D(filters=residual_shape[CHANNEL_AXIS],
                          kernel_size=(1, 1),
                          strides=(1, 1),
                          padding="valid",
                          kernel_initializer="he_normal",
                          name=conv_name_base)(input_feature) 
                          # kernel_regularizer=regularizers.l2(0.0001),
        if bn_name_base is not None:
            bn_name_base = bn_name_base + '1'
        # shortcut = BatchNormalization(axis=CHANNEL_AXIS, name=bn_name_base)(shortcut)
        # shortcut = InstanceNormalization(axis=CHANNEL_AXIS, name=bn_name_base)(shortcut)

    return add([shortcut, residual])

def _residual_block_K(block_function, filters, blocks, stage, transition_strides=None, transition_dilation_rates=None, dilation_rates=None, 
    is_first_layer=False, dropout=None, residual_unit=_in_relu_conv_K, use_SE = False):
    if transition_dilation_rates is None:
        transition_dilation_rates = [(1, 1)] * blocks
    if transition_strides is None:
        transition_strides = [(1, 1)] * blocks
    if dilation_rates is None:
        dilation_rates = [1] * blocks

    def f(x):
        for i in range(blocks):
            is_first_block = is_first_layer and i == 0
            x = block_function(filters=filters, stage=stage, block=i,
                               transition_strides=transition_strides[i],
                               dilation_rate=dilation_rates[i],
                               is_first_block_of_first_layer=is_first_block,
                               dropout=dropout,
                               residual_unit=residual_unit, use_SE = use_SE)(x)
        return x

    return f

def _block_name_base_K(stage, block):
    if block < 27:
        block = '%c' % (block + 97)  # 97 is the ascii number for lowercase 'a'
    conv_name_base = 'res' + str(stage) + str(block) + '_branch'
    bn_name_base = 'bn' + str(stage) + str(block) + '_branch'
    return conv_name_base, bn_name_base

def basic_block_K(filters, stage, block, transition_strides=(1, 1), dilation_rate=(1, 1), is_first_block_of_first_layer=False, dropout=None, residual_unit=_in_relu_conv_K, use_SE = False):
    def f(input_features):
        conv_name_base, bn_name_base = _block_name_base_K(stage, block)
        if is_first_block_of_first_layer:
            # don't repeat bn->relu since we just did bn->relu->maxpool
            x = Conv2D(filters=filters, kernel_size=(3, 3),
                       strides=(1, 1),
                       dilation_rate=dilation_rate,
                       padding="same",
                       kernel_initializer="he_normal",
                       kernel_regularizer=regularizers.l2(1e-4),
                       name=conv_name_base + '2a')(input_features)
        else:
            x = residual_unit(filters=filters, kernel_size=(3, 3),
                              strides=(1, 1),
                              dilation_rate=dilation_rate,
                              conv_name_base=conv_name_base + '2a',
                              bn_name_base=bn_name_base + '2a')(input_features)

        if dropout is not None:
            x = Dropout(dropout)(x)

        x = residual_unit(filters=filters, kernel_size=(3, 3),
                          conv_name_base=conv_name_base + '2b',
                          bn_name_base=bn_name_base + '2b')(x)

        if use_SE == True:
            x = squeeze_excite_block(x)
        return _shortcut_K(input_features, x)

    return f

def bottle_neck_K(filters, stage, block, transition_strides=(1, 1), dilation_rate=(1, 1), is_first_block_of_first_layer=False, dropout=None, residual_unit=_in_relu_conv_K, use_SE = False):
    def f(input_feature):
        conv_name_base, bn_name_base = _block_name_base_K(stage, block)
        if is_first_block_of_first_layer:
            # don't repeat bn->relu since we just did bn->relu->maxpool
            x = Conv2D(filters=filters, kernel_size=(1, 1),
                       strides=transition_strides,
                       dilation_rate=dilation_rate,
                       padding="same",
                       kernel_initializer="he_normal",
                       kernel_regularizer=regularizers.l2(1e-4),
                       name=conv_name_base + '2a')(input_feature)
        else:
            x = residual_unit(filters=filters, kernel_size=(1, 1),
                              strides=transition_strides,
                              dilation_rate=dilation_rate,
                              conv_name_base=conv_name_base + '2a',
                              bn_name_base=bn_name_base + '2a')(input_feature)

        if dropout is not None:
            x = Dropout(dropout)(x)

        x = residual_unit(filters=filters, kernel_size=(3, 3),
                          conv_name_base=conv_name_base + '2b',
                          bn_name_base=bn_name_base + '2b')(x)

        if dropout is not None:
            x = Dropout(dropout)(x)

        x = residual_unit(filters=filters * 2, kernel_size=(1, 1),
                          conv_name_base=conv_name_base + '2c',
                          bn_name_base=bn_name_base + '2c')(x)
        if use_SE == True:
            x = squeeze_excite_block(x)
        return _shortcut_K(input_feature, x)

    return f


def DilatedResRC_with_paras_2D(kernel_size,feature_2D_num,use_bias,hidden_type,filters,nb_layers,opt, initializer = "he_normal", loss_function = "weighted_BCE", weight_p=1.0, weight_n=1.0):
    contact_feature_num_2D=feature_2D_num
    contact_input_shape=(None,None,contact_feature_num_2D)
    contact_input = Input(shape=contact_input_shape)
    
    _handle_dim_ordering()
    ######################### now merge new data to new architecture
    DNCON4_2D_input = contact_input
    DNCON4_2D_conv = DNCON4_2D_input
    DNCON4_2D_conv1 = InstanceNormalization(axis=-1)(DNCON4_2D_conv)
    DNCON4_2D_conv2 = RowNormalization(axis=-1)(DNCON4_2D_conv)
    DNCON4_2D_conv3 = ColumNormalization(axis=-1)(DNCON4_2D_conv)
    DNCON4_2D_conv  = concatenate([DNCON4_2D_conv1, DNCON4_2D_conv2, DNCON4_2D_conv3])

    DNCON4_2D_conv = Activation('relu')(DNCON4_2D_conv)
    DNCON4_2D_conv = Conv2D(128, 1, padding = 'same')(DNCON4_2D_conv)

    # DNCON4_2D_conv = Dense(64)(DNCON4_2D_conv)
    DNCON4_2D_conv = MaxoutAct(DNCON4_2D_conv, filters=4, kernel_size=(1,1), output_dim=64, padding='same', activation = "relu")

    DNCON4_2D_conv = _conv_bn_relu_K(filters=filters, kernel_size=7, strides=1)(DNCON4_2D_conv)

    # DNCON4_2D_conv = Conv2D(filters=filters, kernel_size=(3, 3), strides=(1,1),use_bias=True, kernel_initializer=initializer, padding="same")(DNCON4_2D_conv)
    block = DNCON4_2D_conv
    filters = filters
    residual_unit = _rcin_relu_conv_K
    dropout = None
    transition_dilation_rate = [(1, 1),(2, 2),(5, 5),(7, 7)]

    if nb_layers == 34:
        repetitions=[3, 4, 6, 3]
        for i, r in enumerate(repetitions):
            transition_dilation_rates = transition_dilation_rate * r
            transition_strides = [(1, 1)] * r  

            block = _residual_block_K(basic_block_K, filters=filters,
                                    stage=i, blocks=r,
                                    is_first_layer=(i == 0),
                                    dropout=dropout,
                                    transition_dilation_rates=transition_dilation_rates,
                                    transition_strides=transition_strides,
                                    residual_unit=residual_unit, use_SE = True)(block)
    elif nb_layers == 101:
        repetitions=[3, 4, 10, 3]
        for i, r in enumerate(repetitions):
            transition_dilation_rates = transition_dilation_rate * r
            transition_strides = [(1, 1)] * r  

            block = _residual_block_K(bottle_neck_K, filters=filters,
                                    stage=i, blocks=r,
                                    is_first_layer=(i == 0),
                                    dropout=dropout,
                                    transition_dilation_rates=transition_dilation_rates,
                                    transition_strides=transition_strides,
                                    residual_unit=residual_unit, use_SE = True)(block)
    elif nb_layers == 152:
        repetitions=[3, 8, 36, 3]
        for i, r in enumerate(repetitions):
            transition_dilation_rates = transition_dilation_rate * r
            transition_strides = [(1, 1)] * r  

            block = _residual_block_K(bottle_neck_K, filters=filters,
                                    stage=i, blocks=r,
                                    is_first_layer=(i == 0),
                                    dropout=dropout,
                                    transition_dilation_rates=transition_dilation_rates,
                                    transition_strides=transition_strides,
                                    residual_unit=residual_unit, use_SE = True)(block)
    # Last activation
    block = _rcin_relu_K(block)
    DNCON4_2D_conv = block

    if loss_function == 'weighted_BCE':
        DNCON4_2D_conv = _conv_bn_sigmoid2D(filters=1, nb_row=1, nb_col=1, strides=(1, 1), kernel_initializer=initializer, dilation_rate=(1, 1))(DNCON4_2D_conv)
        loss = _weighted_binary_crossentropy(weight_p, weight_n)
    elif loss_function == 'weighted_MSE':
        DNCON4_2D_conv = _conv_in_relu2D(filters=1, nb_row=1, nb_col=1, strides=(1, 1), kernel_initializer=initializer)(DNCON4_2D_conv)        
        loss = _weighted_mean_squared_error(weight_p)
    elif loss_function == 'binary_crossentropy':
        # DNCON4_2D_conv = Conv2D(filters=1, kernel_size = 1, padding = 'same', kernel_initializer=initializer)(DNCON4_2D_conv)
        # DNCON4_2D_conv = Activation('sigmoid')(DNCON4_2D_conv)
        DNCON4_2D_conv = _conv_bn_sigmoid2D(filters=1, nb_row=1, nb_col=1, strides=(1, 1), kernel_initializer=initializer)(DNCON4_2D_conv)
        loss = loss_function
        
    DNCON4_2D_out = DNCON4_2D_conv
    DNCON4_RES = Model(inputs=contact_input, outputs=DNCON4_2D_out)
    DNCON4_RES.compile(loss=loss, metrics=['accuracy'], optimizer=opt)
    DNCON4_RES.summary()
    return DNCON4_RES


def _dilated_residual_block(block_function, filters, repetitions, is_first_layer=False, dilation_rate=(1,1), use_SE = False):
    def f(input):
        for i in range(repetitions):
            init_strides = (1, 1)
            if i == 0 and not is_first_layer:
                # init_strides = (2, 2)
                init_strides = (1, 1)
            input = block_function(filters=filters, init_strides=init_strides,
                                   is_first_block_of_first_layer=(is_first_layer and i == 0),  dilation_rate=dilation_rate[i], use_SE = use_SE)(input)
        return input

    return f

def dilated_bottleneck_rc(filters, init_strides=(1, 1), is_first_block_of_first_layer=False, dilation_rate=(1,1), use_SE = False):
    def f(input):
        if is_first_block_of_first_layer:
            # don't repeat bn->relu since we just did bn->relu->maxpool
            conv_1_1 = Conv2D(filters=filters, kernel_size=(1, 1),
                              strides=init_strides,
                              padding="same",
                              kernel_initializer="he_normal",
                              kernel_regularizer=regularizers.l2(1e-4))(input)
        else:
            conv_1_1 = _rcin_relu_K(input) 
            conv_1_1 = Conv2D(filters=filters, kernel_size=(1, 1), strides=init_strides,padding="same",kernel_initializer="he_normal")(conv_1_1)

        conv_3_3 = _rcin_relu_K(conv_1_1) 
        conv_3_3 = Conv2D(filters=filters, kernel_size=(5, 5), strides=init_strides, padding="same", kernel_initializer="he_normal")(conv_3_3)
        conv_7_1 = Conv2D(filters=filters, kernel_size=(25, 1), strides=init_strides, padding="same", kernel_initializer="he_normal")(conv_3_3)
        conv_1_7 = Conv2D(filters=filters, kernel_size=(1, 25), strides=init_strides, padding="same", kernel_initializer="he_normal")(conv_3_3)
        conv_3_3 = concatenate([conv_3_3, conv_7_1, conv_1_7])
        # conv_3_3 = _in_elu_conv2D(filters=filters, nb_row=3, nb_col=3, dilation_rate=dilation_rate)(conv_1_1)
        # residual = _in_elu_conv2D(filters=filters * 2, nb_row=1, nb_col=1)(conv_3_3)
        residual = _rcin_relu_K(conv_3_3) 
        residual = Conv2D(filters=filters, kernel_size=(1, 1), strides=init_strides, padding="same", kernel_initializer="he_normal")(residual)
        if use_SE == True:
            residual = squeeze_excite_block(residual)
        return _shortcut(input, residual)
    return f
    
def GoogleResRC_with_paras_2D(fsz, feature_2D_num, filters, nb_blocks, opt, initializer = "he_normal", loss_function = "binary_crossentropy", weight_p=1.0, weight_n=1.0):
    _handle_dim_ordering()
    contact_feature_num_2D=feature_2D_num
    contact_input_shape=(None,None,contact_feature_num_2D)
    contact_input = Input(shape=contact_input_shape)
    
    DNCON4_2D_input = contact_input
    DNCON4_2D_conv = DNCON4_2D_input
    DNCON4_2D_conv = InstanceNormalization(axis=-1)(DNCON4_2D_conv)
    DNCON4_2D_conv = Conv2D(128, 1, padding = 'same')(DNCON4_2D_conv)
    # DNCON4_2D_conv = Dense(64)(DNCON4_2D_conv)
    DNCON4_2D_conv = MaxoutAct(DNCON4_2D_conv, filters=4, kernel_size=(1,1), output_dim=64, padding='same', activation = "elu")

    # ######This is original residual
    # DNCON4_2D_conv = _conv_in_relu2D(filters=64, nb_row=7, nb_col=7, strides=(1, 1))(DNCON4_2D_conv)

    # DNCON4_2D_conv = Conv2D(filters=filters, kernel_size=(3, 3), strides=(1,1),use_bias=True, kernel_initializer=initializer, padding="same")(DNCON4_2D_conv)
    block = DNCON4_2D_conv
    dilated_num = [1, 2, 4, 8, 1] * 1
    # repetitions = [3, 4, 6, 3]
    repetitions = [5]
    for i, r in enumerate(repetitions):
        block = _dilated_residual_block(dilated_bottleneck_rc, filters=filters, repetitions=r, is_first_layer=(i == 0), dilation_rate =dilated_num, use_SE = True)(block)
        block = Dropout(0.2)(block)
    # Last activation
    block = _rcin_relu_K(block)
    DNCON4_2D_conv = block
    # DNCON4_2D_conv = _attention_layer(filters)(DNCON4_2D_conv)

    DNCON4_2D_conv = _conv_in_sigmoid2D(filters=1, nb_row=1, nb_col=1, strides=(1, 1), kernel_initializer=initializer)(DNCON4_2D_conv)
    loss = loss_function
        
    DNCON4_2D_out = DNCON4_2D_conv
    DNCON4_RES = Model(inputs=contact_input, outputs=DNCON4_2D_out)
    DNCON4_RES.compile(loss=loss, metrics=['accuracy'], optimizer=opt)
    DNCON4_RES.summary()
    return DNCON4_RES

