# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 21:47:26 2019

@author: Zhiye
"""
import os

from Model_construct import *
from DataProcess_lib import *

from Model_construct import _weighted_binary_crossentropy, _weighted_categorical_crossentropy, _weighted_mean_squared_error
import numpy as np
import time
import shutil
import sys
import os
import platform
import gc
from collections import defaultdict
import pickle
from six.moves import range

import keras.backend as K
import tensorflow as tf
from keras.models import model_from_json,load_model, Sequential, Model
from keras.optimizers import Adam, Adadelta, SGD, RMSprop, Adagrad, Adamax, Nadam
from keras.utils import multi_gpu_model, Sequence
from keras.callbacks import ReduceLROnPlateau
from random import randint

def chkdirs(fn):
  dn = os.path.dirname(fn)
  if not os.path.exists(dn): os.makedirs(dn)

def generate_data_from_file(path_of_lists, path_of_X, path_of_Y, min_seq_sep,dist_string, batch_size, reject_fea_file='None', 
    child_list_index=0, list_sep_flag=False, dataset_select='train', feature_2D_num = 441, if_use_binsize=False, min_hhbond_number=10, Maximum_length = 500):
    accept_list = []
    if reject_fea_file != 'None':
        with open(reject_fea_file) as f:
            for line in f:
                if line.startswith('#'):
                    feature_name = line.strip()
                    feature_name = feature_name[0:]
                    accept_list.append(feature_name)
    if (dataset_select == 'train'):
        dataset_list = build_dataset_dictionaries_train(path_of_lists)
    elif (dataset_select == 'vali'):
        dataset_list = build_dataset_dictionaries_test(path_of_lists)
    else:
        dataset_list = build_dataset_dictionaries_train(path_of_lists)

    if (list_sep_flag == False):
        training_dict = subset_pdb_dict(dataset_list, 0, Maximum_length, 10000, 'random') #can be random ordered   
        training_list = list(training_dict.keys())
        training_lens = list(training_dict.values())
        all_data_num = len(training_dict)
        loopcount = all_data_num // int(batch_size)
        # print('crop_list_num=',all_data_num)
        # print('crop_loopcount=',loopcount)
    else:
        training_dict = subset_pdb_dict(dataset_list, 0, Maximum_length, 10000, 'ordered') #can be random ordered
        all_training_list = list(training_dict.keys())
        all_training_lens = list(training_dict.values())
        if ((child_list_index + 1) * 15 > len(training_dict)):
            print("Out of list range!\n")
            child_list_index = len(training_dict)/15 - 1
        child_batch_list = all_training_list[child_list_index * 15:(child_list_index + 1) * 15]
        child_batch_list_len = all_training_lens[child_list_index * 15:(child_list_index + 1) * 15]
        all_data_num = 15
        loopcount = all_data_num // int(batch_size)
        print('crop_list_num=',all_data_num)
        print('crop_loopcount=',loopcount)
        training_list = child_batch_list
        training_lens = child_batch_list_len
    index = 0
    while(True):
        if index >= loopcount:
            raining_dict = subset_pdb_dict(dataset_list, 0, Maximum_length, 10000, 'random') #can be random ordered   
            training_list = list(training_dict.keys())
            training_lens = list(training_dict.values())
            index = 0
        batch_list = training_list[index * batch_size:(index + 1) * batch_size]
        batch_list_len = training_lens[index * batch_size:(index + 1) * batch_size]
        index += 1
        # print(index, end='\t')
        if if_use_binsize:
            max_pdb_lens = Maximum_length
        else:
            max_pdb_lens = max(batch_list_len)

        data_all_dict = dict()
        batch_X=[]
        batch_Y=[]
        for i in range(0, len(batch_list)):
            pdb_name = batch_list[i]
            pdb_len = batch_list_len[i]
            notxt_flag = True
            featurefile =path_of_X + '/other/' + 'X-'  + pdb_name + '.txt'
            if ((len(accept_list) == 1 and ('# cov' not in accept_list and '# plm' not in accept_list and '# pre' not in accept_list and '# netout' not in accept_list)) or 
                  (len(accept_list) == 2 and ('# cov' not in accept_list or '# plm' not in accept_list or '# pre' not in accept_list or '# netout' not in accept_list)) or (len(accept_list) > 2)):
                notxt_flag = False
                if not os.path.isfile(featurefile):
                    print("feature file not exists: ",featurefile, " pass!")
                    continue     
            cov = path_of_X + '/cov/' + pdb_name + '.cov'
            if '# cov' in accept_list:
                if not os.path.isfile(cov):
                    print("Cov Matrix file not exists: ",cov, " pass!")
                    continue        
            plm = path_of_X + '/plm/' + pdb_name + '.plm'
            if '# plm' in accept_list:
                if not os.path.isfile(plm):
                    print("plm matrix file not exists: ",plm, " pass!")
                    continue   
            pre = path_of_X + '/pre/' + pdb_name + '.pre'
            if '# pre' in accept_list:
                if not os.path.isfile(pre):
                    print("pre matrix file not exists: ",pre, " pass!")
                    continue
            netout = path_of_X + '/net_out/' + pdb_name + '.npy'
            if '# netout' in accept_list:      
                if not os.path.isfile(netout):
                    print("netout matrix file not exists: ",netout, " pass!")
                    continue 
     
            targetfile = path_of_Y + '/' + pdb_name + '.txt'
            if not os.path.isfile(targetfile):
                    print("target file not exists: ",targetfile, " pass!")
                    continue  

            l_max = max_pdb_lens
            Y = getY(targetfile, min_seq_sep, l_max)
            if (l_max * l_max != len(Y)):
                print('Error!! y does not have L * L feature values!!, pdb_name = %s'%(pdb_name))
                continue
            if np.sum(Y) <= min_hhbond_number: # less than 10 hhbond 
                continue
            Y = Y.reshape(l_max, l_max, 1)

            (featuredata, feature_index_all_dict) = getX_2D_format(featurefile, cov, plm, pre, netout, accept_list, pdb_len, notxt_flag)
            if featuredata == False or feature_index_all_dict == False:
                print("Bad alignment, Please check!\n")
                continue
            feature_2D_all = []
            for key in sorted(feature_index_all_dict.keys()):
                featurename = feature_index_all_dict[key]
                feature = featuredata[key]
                feature = np.asarray(feature)
                if feature.shape[0] == feature.shape[1]:
                    feature_2D_all.append(feature)
                else:
                    print("Wrong dimension")
            fea_len = feature_2D_all[0].shape[0]

            F = len(feature_2D_all)
            if F != feature_2D_num:
                print("Target %s has wrong feature shape! Continue!" % pdb_name)
                continue
            X = np.zeros((max_pdb_lens, max_pdb_lens, F))
            for m in range(0, F):
                X[0:fea_len, 0:fea_len, m] = feature_2D_all[m]

            # X = np.memmap(cov, dtype=np.float32, mode='r', shape=(F, max_pdb_lens, max_pdb_lens))
            # X = X.transpose(1, 2, 0)

            batch_X.append(X)
            batch_Y.append(Y)
            del X
            del Y
        batch_X =  np.array(batch_X)
        batch_Y =  np.array(batch_Y)
        # print('X shape\n', batch_X.shape)
        # print('Y shape', batch_Y.shape)
        if len(batch_X.shape) < 4 or len(batch_Y.shape) < 4:
            continue
        yield batch_X, batch_Y


def Train_DeepHBond_2D_generator(feature_num,CV_dir,feature_dir,model_prefix,
    epoch_outside,epoch_inside,epoch_rerun,win_array,nb_filters,nb_layers, lib_dir, batch_size_train,path_of_lists, path_of_Y, path_of_X, Maximum_length,dist_string, reject_fea_file='None',
    initializer = "he_normal", loss_function = "binary_crossentropy", runcount=1.0,  min_hhbond_number = 10, list_sep_flag=False,  if_use_binsize = False, if_use_generator=True): 

    import numpy as np
    Train_data_keys = dict()
    Train_targets_keys = dict()
    print("\n######################################\n佛祖保佑，永不迨机，永无bug，精度九十九\n######################################\n")
    feature_2D_num=feature_num # the number of features for each residue
 
    print("Load feature number", feature_2D_num)
    ### Define the model 
    model_out= "%s/model-train-%s.json" % (CV_dir,model_prefix)
    model_weight_out = "%s/model-train-weight-%s.h5" % (CV_dir,model_prefix)
    model_weight_out_best = "%s/model-train-weight-%s-best-val.h5" % (CV_dir,model_prefix)

    opt = Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.0000)#0.001  decay=0.0
    if model_prefix == 'DNCON4_CONV':
        DNCON4 = DeepConv_with_paras_2D(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_RES':
        DNCON4 = DeepResnet_with_paras_2D(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_RESPRE':
        DNCON4 = DeepResnet_with_paras_2D_Pre(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_RESPRERC':
        DNCON4 = DeepResnetRC_with_paras_2D_Pre(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_RESOTHER':
        DNCON4 = DeepResnet_with_paras_2D_other(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_RESOTHERRC':
        DNCON4 = DeepResnetRC_with_paras_2D_other(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_DIARES':
        DNCON4 = DilatedRes_with_paras_2D(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_DIARESRC':
        DNCON4 = DilatedResRC_with_paras_2D(win_array,feature_2D_num, nb_filters,nb_layers,opt,initializer,loss_function)
    elif model_prefix == 'DNCON4_GRESRC':
        DNCON4 = GoogleResRC_with_paras_2D(win_array, feature_2D_num, nb_filters, nb_layers, opt, initializer, loss_function)
    else:
        DNCON4 = DeepConv_with_paras_2D(win_array,feature_2D_num, nb_filters,nb_layers,opt)
    
    model_json = DNCON4.to_json()
    print("Saved model to disk")
    with open(model_out, "w") as json_file:
        json_file.write(model_json)

    rerun_flag=0
    # with tf.device("/cpu:0"):
    #     DNCON4 = multi_gpu_model(DNCON4, gpus=2)
    train_acc_history_out = "%s/training.acc_history" % (CV_dir)
    val_acc_history_out = "%s/validation.acc_history" % (CV_dir)
    best_val_acc_out = "%s/best_validation.acc_history" % (CV_dir)
    if os.path.exists(model_weight_out_best):
        print("######## Loading existing weights ",model_weight_out_best)
        DNCON4.load_weights(model_weight_out_best)
        rerun_flag = 1
    else:
        print("######## Setting initial weights")   
    
        chkdirs(train_acc_history_out)     
        with open(train_acc_history_out, "a") as myfile:
          myfile.write("Interval_len\tEpoch_outside\tEpoch_inside\tAvg_Accuracy_l5\tAvg_Accuracy_l2\tAvg_Accuracy_1l\tGloable_MSE\tWeighted_MSE\n")
          
        chkdirs(val_acc_history_out)     
        with open(val_acc_history_out, "a") as myfile:
          myfile.write("Epoch\tprec_l5\tprec_l2\tprec_1l\tmcc_l5\tmcc_l2\tmcc_1l\trecall_l5\trecall_l2\trecall_1l\tf1_l5\tf1_l2\tf1_1l\n")
        
        chkdirs(best_val_acc_out)     
        with open(best_val_acc_out, "a") as myfile:
          myfile.write("Seq_Name\tSeq_Length\tAvg_Accuracy_l5\tAvg_Accuracy_l2\tAvg_Accuracy_1l\n")

    #predict_method has three value : bin_class, mul_class, real_dist

    predict_method = 'bin_class'
    path_of_Y_train = path_of_Y + '/hhbond_bin/'
    path_of_Y_evalu = path_of_Y + '/hhbond_bin/'
    loss_function = loss_function

    DNCON4.compile(loss=loss_function, metrics=['acc'], optimizer=opt)

    model_weight_epochs = "%s/model_weights/"%(CV_dir)
    model_weights_top = "%s/model_weights_top/"%(CV_dir)
    model_predict= "%s/predict_map/"%(CV_dir)
    model_val_acc= "%s/val_acc_inepoch/"%(CV_dir)
    chkdirs(model_weight_epochs)
    chkdirs(model_weights_top)
    chkdirs(model_predict)
    chkdirs(model_val_acc)

    tr_l = build_dataset_dictionaries_train(path_of_lists)
    tr_l_dict = subset_pdb_dict(tr_l, 0, Maximum_length, 100000, 'ordered')
    te_l = build_dataset_dictionaries_test(path_of_lists)
    te_l_dict = subset_pdb_dict(te_l, 0, Maximum_length, 100000, 'ordered')
    all_l = te_l.copy()
    train_data_num = len(tr_l_dict)
    child_list_num = int(train_data_num/15)# 15 is the inter
    print('Total Number of Training dataset = ',str(len(tr_l_dict)))
    print('Total Number of Validation dataset = ',str(len(te_l_dict)))

    # callbacks=[reduce_lr]
    train_avg_acc_best = 0 
    val_avg_acc_best = 0
    val_avg_acc_best = 0
    min_seq_sep = 5
    lr_decay = False
    train_loss_last = 1e32
    train_loss_list = []
    evalu_loss_list = []
    # reduce_lr = ReduceLROnPlateau(monitor='loss', factor=0.5, patience=5, min_lr=0.0001)
    #     def __init__(self, path_of_lists, path_of_X, path_of_Y, min_seq_sep,dist_string, batch_size, reject_fea_file='None', 
    # dataset_select='train', if_use_binsize=False, predict_method='bin_class'):
    # train_data_sequence = SequenceData(path_of_lists, path_of_X, path_of_Y_train, min_seq_sep, dist_string, batch_size_train, reject_fea_file, if_use_binsize=if_use_binsize, predict_method=predict_method)
    
    if if_use_generator == False:
        print("Loading all data to memory! Waiting...")
        X_train, Y_train = load_data_from_file(path_of_lists, path_of_X, path_of_Y_train, min_seq_sep, dist_string, reject_fea_file, if_use_binsize=if_use_binsize, Maximum_length=Maximum_length)
    for epoch in range(epoch_rerun,epoch_outside):
        if (epoch >=30 and lr_decay == False):
            print("Setting lr_decay as true")
            lr_decay = True
            opt = SGD(lr=0.01, momentum=0.9, decay=0.00, nesterov=False)#0.001
            DNCON4.compile(loss=loss_function, metrics=['accuracy'], optimizer=opt)
            # reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=1, verbose = 1, min_delta=0.005, min_lr=0.00005)
        # class_weight = {0:1.,1:60.}

        print("\n############ Running epoch ", epoch)
        if epoch == 0 and rerun_flag == 0:
            first_inepoch = 1
            history = DNCON4.fit_generator(generate_data_from_file(path_of_lists, path_of_X, path_of_Y_train, min_seq_sep, dist_string, batch_size_train, reject_fea_file, feature_2D_num= feature_2D_num, 
                if_use_binsize=if_use_binsize, min_hhbond_number=min_hhbond_number, Maximum_length = Maximum_length), 
            steps_per_epoch = len(tr_l_dict)//batch_size_train, epochs = first_inepoch, max_queue_size=20, workers=2, use_multiprocessing=False)         
            train_loss_list.append(history.history['loss'][first_inepoch-1])
        else: 
            history = DNCON4.fit_generator(generate_data_from_file(path_of_lists, path_of_X, path_of_Y_train, min_seq_sep, dist_string, batch_size_train, reject_fea_file, feature_2D_num= feature_2D_num, 
                if_use_binsize=if_use_binsize, min_hhbond_number=min_hhbond_number, Maximum_length = Maximum_length), 
                steps_per_epoch = len(tr_l_dict)//batch_size_train, epochs = 1, max_queue_size=20, workers=2, use_multiprocessing=False)         
            train_loss_list.append(history.history['loss'][0])
     
        DNCON4.save_weights(model_weight_out)

        # DNCON4.save(model_and_weights)
        
        ### save models
        model_weight_out_inepoch = "%s/model-train-weight-%s-epoch%i.h5" % (model_weight_epochs,model_prefix,epoch)
        DNCON4.save_weights(model_weight_out_inepoch)
        ##### running validation

        print("Now evaluate for epoch ",epoch)
        val_acc_out_inepoch = "%s/validation_epoch%i.acc_history" % (model_val_acc, epoch) 
        sys.stdout.flush()
        selected_list = subset_pdb_dict(te_l,   0, Maximum_length, 7000, 'ordered')  ## here can be optimized to automatically get maxL from selected dataset

        testdata_len_range=50
        step_num = 0
        out_avg_prec = 0.0
        out_avg_mcc = 0.0
        out_avg_recall = 0.0
        out_avg_f1 = 0.0
        out_sum_hbond = 0.0
        out_diff_hbond = 0.0
        print(("SeqName\tSeqLen\tFea\tprec\trecall\tf1\tmcc\tsum\tdiff\n"))
        for key in selected_list:
            value = selected_list[key]
            p1 = {key: value}
            if if_use_binsize:
                length = Maximum_length
            else:
                length = value
            if len(p1) < 1:
                continue
            # print("start predict")
            if len(reject_fea_file)!=2:
                selected_list_2D = get_x_2D_from_this_list(p1, path_of_X, length, dist_string, feature_num, reject_fea_file, value)
                if type(selected_list_2D) == bool:
                    continue
                # print("selected_list_2D.shape: ",selected_list_2D.shape)
                # print('Loading label sets..')
                selected_list_label = get_y_from_this_list(p1, path_of_Y_evalu, 0, length, dist_string)# dist_string 80
                if type(selected_list_label) == bool:
                    continue
                DNCON4.load_weights(model_weight_out)

                DNCON4_prediction = DNCON4.predict([selected_list_2D], batch_size= 1)
            elif len(reject_fea_file)>=2:
                pred_temp = []
                bool_flag = False
                for fea_num in range(len(reject_fea_file)):
                    temp = get_x_2D_from_this_list(p1, path_of_X, length, dist_string, feature_num, reject_fea_file[fea_num], value)
                    # print("selected_list_2D.shape: ",temp.shape)
                    if type(temp) == bool:
                        bool_flag= True
                    pred_temp.append(temp)
                if bool_flag == True:
                    continue
                else:
                    # print('Loading label sets..')
                    selected_list_label = get_y_from_this_list(p1, path_of_Y_evalu, 0, length, dist_string)# dist_string 80
                    DNCON4.load_weights(model_weight_out)
                    DNCON4_prediction = DNCON4.predict(pred_temp, batch_size= 1)

            DNCON4_prediction = DNCON4_prediction.reshape(len(p1), length*length)

            (avg_prec, avg_recall, avg_f1, avg_mcc, sum_hbond, diff_hbond) = evaluate_prediction(selected_list_label, DNCON4_prediction, 5)
            val_acc_history_content = "%s\t%i\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f" % (key,value, avg_prec, avg_recall, avg_f1, avg_mcc, sum_hbond, diff_hbond)
            print(val_acc_history_content)
            with open(val_acc_out_inepoch, "a") as myfile:
                myfile.write(val_acc_history_content)

 
            out_avg_prec += avg_prec * len(p1)
            out_avg_mcc += avg_mcc * len(p1)
            out_avg_recall += avg_recall * len(p1)
            out_avg_f1 += avg_f1 * len(p1)
            out_sum_hbond += sum_hbond * len(p1)
            out_diff_hbond += diff_hbond * len(p1)
            
            step_num += 1
        print ('step_num=', step_num)
        all_num = len(selected_list)
        out_avg_prec /= all_num
        out_avg_mcc /= all_num
        out_avg_recall /= all_num
        out_avg_f1 /= all_num
        out_sum_hbond /= step_num
        out_diff_hbond /= step_num
        val_acc_history_content = "%i\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f" % (epoch, out_avg_prec, out_avg_recall, out_avg_f1, out_avg_mcc, sum_hbond, diff_hbond)
        # val_acc_history_content = "%i\t%i\t%i\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n" % (interval_len,epoch,epoch_inside,out_avg_pc_l5,out_avg_pc_l2,out_avg_pc_1l,
        #     out_avg_acc_l5,out_avg_acc_l2,out_avg_acc_1l, out_gloable_mse, train_loss_list[-1])
        with open(val_acc_history_out, "a") as myfile:
                    myfile.write(val_acc_history_content)  
                    myfile.write('\n')

        print('The validation accuracy is ',val_acc_history_content)
        if out_avg_mcc >= val_avg_acc_best:
            val_avg_acc_best = out_avg_mcc 
            score_imed = "Accuracy L2 of Val: %.4f\t\n" % (val_avg_acc_best)
            print("Saved best weight to disk, ", score_imed)
            DNCON4.save_weights(model_weight_out_best)

        train_loss = history.history['loss'][0]
        if (lr_decay and epoch > 30):
            current_lr = K.get_value(DNCON4.optimizer.lr)
            print("Current learning rate is {} ...".format(current_lr))
            if (epoch % 20 == 0):
                K.set_value(DNCON4.optimizer.lr, current_lr * 0.1)
                print("Decreasing learning rate to {} ...".format(current_lr * 0.1))

        train_loss_last = train_loss
        print("Train loss history:", train_loss_list)
    #select top10 models
    epochs = []
    accL5s = []
    with open(val_acc_history_out) as f:
        for line in f:
            cols = line.strip().split()
            if cols[0] != '150':
                continue
            else:
                epoch = cols[1]
                accL5 = cols[6]
                epochs.append(cols[1])
                accL5s.append(cols[6])
                # print(epoch, accL5)
    accL5_sort = accL5s.copy()
    accL5_sort.sort(reverse=True)
    accL5_top = accL5_sort[0:5]
    epoch_top = []
    for index in range(len(accL5_top)):
        acc_find = accL5_top[index]
        pos_find = [i for i, v in enumerate(accL5s) if v == acc_find]
        # print(pos_find)
        for num in range(len(pos_find)):
            epoch_top.append(epochs[pos_find[num]])
    epoch_top = list(set(epoch_top))
    for index in range(len(epoch_top)):
        model_weight = "model-train-weight-%s-epoch%i.h5" % (model_prefix,int(epoch_top[index]))
        src_file = os.path.join(model_weight_epochs,model_weight)
        dst_file = os.path.join(model_weights_top,model_weight)
        shutil.copyfile(src_file,dst_file)
        print("Copy %s to model_weights_top"%epoch_top[index])
    print("Training finished, best validation acc = ",val_avg_acc_best)
    return val_avg_acc_best