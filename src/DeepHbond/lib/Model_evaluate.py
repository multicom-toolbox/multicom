# -*- coding: utf-8 -*-
"""
Created on Thu Jan 2 10:48:28 2020

@author: Zhiye
"""

import sys
import os,glob,re
import time

#This may wrong sometime
sys.path.insert(0, sys.path[0])
from Model_construct import *
from DataProcess_lib import *
from training_strategy import *

import subprocess
import numpy as np
from keras.models import model_from_json,load_model, Sequential, Model
from keras.utils import CustomObjectScope
from random import randint
import keras.backend as K
import tensorflow as tf

if len(sys.argv) == 8:
    CV_dir = [sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]] # ensemble use four model average
    out_dir = str(sys.argv[5])  # DNCON2, DNCON4, DEEPCOV, RESPRE
    dataset = str(sys.argv[6])
    database_path=str(sys.argv[7]) 
elif len(sys.argv) == 5:
    CV_dir = sys.argv[1] # DNCON4_RES
    out_dir = str(sys.argv[2])  # DNCON2, DNCON4, DEEPCOV, RESPRE
    dataset = str(sys.argv[3])
    database_path=str(sys.argv[4]) 
else:
  print('please input the right parameters')
  sys.exit(1)

# CV_dir = '/mnt/data/zhiye/Python/DeepHBond/models/custom/gresrc_plm/DNCON4_GRESRC_DEEPCOV_6463_plm_v3_filter64_layers5_ftsize3_24.0//'
# out_dir = CV_dir
# dataset = 'CASP13'
# database_path='/mnt/data/zhiye/Python/DNCON4_db_tools/'

print("Model dir:", CV_dir)
only_predict_flag = False # if do not have lable set True
lib_path = sys.path[0]
GLOABL_Path = os.path.dirname(sys.path[0]) ##.split('DNCON4')[0]+'DNCON4/'
print("Find gloabl path :", GLOABL_Path)
###CASP13 FM
if dataset == 'CASP13':
    path_of_lists = GLOABL_Path + '/data/'+dataset+'/lists-test-train/'
    path_of_X= database_path + '/features/CASP13/'
    path_of_Y= database_path + '/features/CASP13/'  
    path_of_fasta = database_path + '/features/CASP13/fasta/'
    path_of_pdb = database_path + '/features/CASP13/pdb/'    
    path_of_lists = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/lists-test-train/'
    path_of_X= '/mnt/data/zhiye/Python/DNCON4/data/CASP13/feats_fixed/'  # new pipline
    path_of_Y= '/mnt/data/zhiye/Python/DNCON4/data/CASP13/feats_fixed/'  
    path_of_fasta = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/fasta/'
    path_of_pdb = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/pdb43/' 
elif dataset == 'CASP13_MSA':
    path_of_lists = GLOABL_Path + '/data/CASP13/lists-test-train/'
    path_of_X= database_path + '/features/' + dataset +'/'
    path_of_Y= database_path + '/features/' + dataset +'/' 
    path_of_fasta = database_path + '/features/' + dataset +'/fasta/'
    path_of_pdb = database_path + '/features/' + dataset +'/pdb/'
    path_of_fasta = database_path + '/features/CASP13/fasta/'
    path_of_pdb = database_path + '/features/CASP13/pdb/' 
    path_of_lists = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/lists-test-train/'
    path_of_X= '/mnt/data/zhiye/Python/DNCON4/data/CASP13/feats_deepmsa/'  # new pipline
    path_of_Y= '/mnt/data/zhiye/Python/DNCON4/data/CASP13/feats_deepmsa/'  
    path_of_fasta = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/fasta/'
    path_of_pdb = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/pdb43/' 
elif dataset == 'CASP13_DM':
    path_of_lists = database_path + '/features/'+dataset+'/lists-test-train/'
    path_of_X= database_path + '/features/' + dataset +'/ALN/'
    path_of_Y= database_path + '/features/' + dataset +'/ALN/' 
    path_of_fasta = database_path + '/features/' + dataset +'/ALN/fasta/'
    path_of_pdb = database_path + '/features/' + dataset +'/ALN/pdb/'     
elif dataset == 'CASP13_DM_MSA':
    path_of_lists = database_path + '/features/CASP13_DM/lists-test-train/'
    path_of_X= database_path + '/features/CASP13_DM/MSA/'
    path_of_Y= database_path + '/features/CASP13_DM/MSA/' 
    path_of_fasta = database_path + '/features/CASP13_DM/MSA/fasta/'
    path_of_pdb = database_path + '/features/CASP13_DM/MSA/pdb/' 
elif dataset == 'DEEPMSA':
    path_of_lists = GLOABL_Path + '/data/'+dataset+'/lists-test-train/'
    path_of_X= database_path + '/features/' + dataset +'/'
    path_of_Y= database_path + '/features/' + dataset +'/' 
    path_of_fasta = database_path + '/features/' + dataset +'/fasta/'
    path_of_pdb = database_path + '/features/' + dataset +'/pdb/'  
elif dataset == 'CAMEO':
    path_of_lists = GLOABL_Path + '/data/' + dataset+'/lists-test-train/'
    path_of_X= database_path + '/features/' + dataset +'/'
    path_of_Y= database_path + '/features/' + dataset +'/' 
    path_of_fasta = database_path + '/features/' + dataset +'/fasta/'
    path_of_pdb = database_path + '/features/' + dataset +'/pdb/'  
elif dataset == 'CASP12':
    path_of_lists = GLOABL_Path + '/data/' + dataset+'/lists-test-train/'
    path_of_X= database_path + '/features/' + dataset +'/'
    path_of_Y= database_path + '/features/' + dataset +'/' 
    path_of_fasta = database_path + '/features/' + dataset +'/fasta/'
    path_of_pdb = database_path + '/features/' + dataset +'/pdb/'
elif dataset == 'CASP12_MSA':
    path_of_lists = GLOABL_Path + '/data/CASP12/lists-test-train/'
    path_of_X= database_path + '/features/' + dataset +'/'
    path_of_Y= database_path + '/features/' + dataset +'/' 
    path_of_fasta = database_path + '/features/' + dataset +'/fasta/'
    path_of_pdb = database_path + '/features/' + dataset +'/pdb/'
else:
    print("This script can test CASP13, DEEPMSA, CAMEO dataset, other dataset will be added later.")
    sys.exit(1)

feature_list = 'other'# ['combine', 'combine_all2d', 'other', 'ensemble']  # combine will output three map and it combine, other just output one pred
data_list_choose = 'test'# ['train', 'test', 'train_sub', 'all']
Maximum_length = 100000  # casp12 700
dist_string = "80"
if_use_binsize = False #False True

gpu_schedul_strategy("local", allow_growth=True)

def chkdirs(fn):
    dn = os.path.dirname(fn)
    if not os.path.exists(dn): os.makedirs(dn)

def getFileName(path, filetype):
    f_list = os.listdir(path)
    all_file = []
    for i in f_list:
        if os.path.splitext(i)[1] == filetype:
            all_file.append(i)
    return all_file


print("\n######################################\n佛祖保佑，永不迨机，永无bug，精度九十九\n######################################\n")


path_of_Y_train = path_of_Y + '/hhbond_bin/'
path_of_Y_evalu = path_of_Y + '/hhbond_bin/'

tr_l = {}
te_l = {}
if 'train' == data_list_choose:
    tr_l = build_dataset_dictionaries_train(path_of_lists)
if 'test' == data_list_choose:
    te_l = build_dataset_dictionaries_test(path_of_lists)
if 'all' == data_list_choose:
    tr_l = build_dataset_dictionaries_train(path_of_lists)
    te_l = build_dataset_dictionaries_test(path_of_lists)
all_l = te_l.copy()       
all_l.update(tr_l)

print('Total Number to predict = ',str(len(all_l)))

##### running validation
selected_list = subset_pdb_dict(all_l,   0, Maximum_length, 5000, 'ordered')  ## here can be optimized to automatically get maxL from selected dataset

iter_num = 0
if isinstance(CV_dir, str) == True:
    iter_num = 1
    CV_dir = [CV_dir]
else:
    iter_num = len(CV_dir)
chkdirs(out_dir)
final_acc_reprot = "%s/coneva.result" % (out_dir) 
with open(final_acc_reprot, "a") as myfile:
    myfile.write(time.strftime('\n\n%Y-%m-%d %H:%M:%S',time.localtime(time.time())))
    myfile.write("SeqName\tSeqLen\tFea\tprec\trecall\tf1\tmcc\n")

for index in range(iter_num):
    sub_cv_dir = CV_dir[index]
    reject_fea_path = sub_cv_dir + '/'
    reject_fea_file = getFileName(reject_fea_path, '.txt')

    model_out= sub_cv_dir + '/' + getFileName(sub_cv_dir, '.json')[0]
    weights_name_list = getFileName(sub_cv_dir, '.h5')
    model_name = None
    for i in range(len(weights_name_list)):
        if 'best' in weights_name_list[i]:
            model_name = weights_name_list[i]
        else:
            continue
    model_weight_out_best = sub_cv_dir + '/' + model_name
    model_weight_top10 = "%s/model_weights_top/" % (sub_cv_dir)

    # pred_history_out = "%s/predict%d.acc_history" % (out_dir, index) 
    # with open(pred_history_out, "a") as myfile:
    #     myfile.write(time.strftime('%Y-%m-%d %H:%M:%S\n',time.localtime(time.time())))
    with CustomObjectScope({'InstanceNormalization': InstanceNormalization, 'RowNormalization': RowNormalization, 'ColumNormalization': ColumNormalization, 'tf':tf}):
        json_string = open(model_out).read()
        DNCON4 = model_from_json(json_string)

    if os.path.exists(model_weight_out_best):
        print("######## Loading existing weights ",model_weight_out_best)
        DNCON4.load_weights(model_weight_out_best)
    else:
        print("Please check the best weights\n")
        sys.exit(1)

    model_predict= "%s/pred_map%d/"%(out_dir, index)
    chkdirs(model_predict)
    if 'other' == feature_list:
        if len(reject_fea_file) == 1:
            OTHER = reject_fea_path + reject_fea_file[0]
            # print(OTHER)
        elif len(reject_fea_file) >= 2:
            OTHER = []
            for feafile_num in range(len(reject_fea_file)):
                OTHER.append(reject_fea_path + reject_fea_file[feafile_num])
    step_num = 0
      
    for key in selected_list:
        value = selected_list[key]
        p1 = {key: value}
        if if_use_binsize:
            Maximum_length = Maximum_length
        else:
            Maximum_length = value
        if len(p1) < 1:
            continue
        if step_num == 0:
            feature_num = get_x_2D_feature_number(p1, path_of_X, OTHER)
            # print(feature_num)
        print("start predict %s %d" %(key, value))

        if 'other' in feature_list:
            selected_list_2D_other = get_x_2D_from_this_list(p1, path_of_X, Maximum_length, dist_string, feature_num, OTHER, value)
            if type(selected_list_2D_other) == bool:
                continue
            DNCON4_prediction_other = DNCON4.predict([selected_list_2D_other], batch_size= 1)  
                # print(DNCON4_prediction_other.shape)
              
            CMAP = DNCON4_prediction_other.reshape(Maximum_length, Maximum_length)
            other_cmap_file = "%s/%s.txt" % (model_predict, key)
            np.savetxt(other_cmap_file, CMAP, fmt='%.4f')
        
        # Predict different epoch map
        if 'ensemble' in feature_list:
            weights = os.listdir(model_weight_top10)
            selected_list_2D_other = get_x_2D_from_this_list(p1, path_of_X, Maximum_length, dist_string, feature_num, OTHER, value)
            if type(selected_list_2D_other) == bool:
                continue

            real_cmap_other = np.zeros((Maximum_length, Maximum_length))
            weight_num = 0
            for weight in weights:
                model_predict_epoch= "%s/ensemble_pred_map%d/"%(out_dir, weight_num)
                chkdirs(model_predict_epoch)
                model_weight_out = model_weight_top10 + '/' + weight
                weight_num += 1
                DNCON4.load_weights(model_weight_out)

                DNCON4_prediction_other = DNCON4.predict([selected_list_2D_other], batch_size= 1)  
                DNCON4_prediction_plm = DNCON4.predict([selected_list_2D_plm], batch_size= 1)  

                CMAP = DNCON4_prediction_other.reshape(Maximum_length, Maximum_length)
                # Map_UpTrans = np.triu(CMAP, 1).T
                # Map_UandL = np.triu(CMAP)
                Map_UpTrans = (np.triu(CMAP, 1).T + np.tril(CMAP, -1))/2
                Map_UandL = (np.triu(CMAP) + np.tril(CMAP).T)/2
                real_cmap_other_temp = Map_UandL + Map_UpTrans

                real_cmap_other += real_cmap_other_temp

            real_cmap_other /= weight_num
            sum_cmap_file = "%s/ensemble_pred_map/%s.txt" % (out_dir,key)
            np.savetxt(sum_cmap_file, real_cmap_other, fmt='%.4f')

### use coneva to evaluate
if iter_num == 1: # this is single model predictor
    cmap_dir= "%s/pred_map%d/"%(out_dir, index)
    hhbonds_dir = cmap_dir+'/hhbonds/'
    chkdirs(hhbonds_dir)
    os.chdir(hhbonds_dir)
    for filename in glob.glob(cmap_dir+'/*.txt'):
        id = os.path.basename(filename)
        id = re.sub('\.txt$', '', id)
        f = open(hhbonds_dir+"/"+id+".raw",'w')
        cmap = np.loadtxt(filename,dtype='float32')
        L = cmap.shape[0]
        for i in range(0,L):
            for j in range(0,L):
                f.write(str(i+1)+" "+str(j+1)+" 0 3.5 "+'%.4f'%(cmap[i][j])+"\n")
        f.close()
        os.system('egrep -v \"^>\" '+ path_of_fasta +id+'.fasta'+'  > '+id+'.hhbonds')
        os.system('cat '+id+'.raw >> '+id+'.hhbonds')
        os.system('rm -f '+id+'.raw')
    if only_predict_flag == False:
        print("Use coneva to evaluated. It may take 1 or 2 minutes.....\n")
        emoji_flag = False
        for key in selected_list:
            # print(key+" evaluated")print
            if emoji_flag:
                emoji_flag=False
                print('\r', '\\(￣︶￣*\\))  \\(￣︶￣*\\))  \\(￣︶￣*\\))  \\(￣︶￣*\\))  \\(￣︶￣*\\))', end='', flush=True)
            else:
                emoji_flag=True
                print('\r', ' ((/*￣︶￣)/  ((/*￣︶￣)/  ((/*￣︶￣)/  ((/*￣︶￣)/  ((/*￣︶￣)/', end='', flush=True)
            pdb_name = get_all_file_contain_str(path_of_pdb, key)
            for i in range(len(pdb_name)):
                pdb_file = path_of_pdb + pdb_name[i]
                if os.path.exists(pdb_file):
                    subprocess.call("perl "+lib_path+"/boneva.pl -rr "+hhbonds_dir+"/"+key+".hhbonds -pdb "+ pdb_file + " -d 3.5 -atom hhbonds -smin 3 >> "+hhbonds_dir+"/hhbonds.txt",shell=True)
                else:
                    print("Please check the pdb file: %s"%pdb_file)
        title_line = "\nPRECISION                     Top-5     Top-L/10  Top-L/5   Top-L/2   Top-L     Top-2L    "
        with open(final_acc_reprot, "a") as myfile:
            myfile.write(title_line)
            myfile.write('\n')
        print(title_line)
        
        top5_acc = topL10_acc = topL5_acc = topL2_acc = topL_acc = top2L_acc = 0 
        count = 0
        for line in open(hhbonds_dir+"/hhbonds.txt",'r'):
            line = line.rstrip()
            if(".pdb (precision)" in line):
                arr = line.split()
                print(arr[0])  
                with open(final_acc_reprot, "a") as myfile:
                    myfile.write(' ')
                    myfile.write(arr[0])
                    myfile.write('\n')
            if(".hhbonds (precision)" in line):
                count += 1
                print(line, end=' ')
                with open(final_acc_reprot, "a") as myfile:
                    myfile.write(line)
                _array = line.split(' ')
                array = [x for x in _array if x !='']
                top5_acc   += float(array[2])
                topL10_acc += float(array[3])
                topL5_acc  += float(array[4])
                topL2_acc  += float(array[5])
                topL_acc   += float(array[6])
                top2L_acc  += float(array[7])
        top5_acc   /= count
        topL10_acc /= count
        topL5_acc  /= count
        topL2_acc  /= count
        topL_acc   /= count
        top2L_acc  /= count
        final_line = "AVERAGE                       %.2f     %.2f     %.2f     %.2f     %.2f     %.2f    \n"%(top5_acc, topL10_acc, topL5_acc, topL2_acc, topL_acc, top2L_acc)
        print(final_line)
        with open(final_acc_reprot, "a") as myfile:
            myfile.write(final_line)
        os.system('rm -f hhbonds.txt')
    else:
        print ("Final pred_map filepath: %s"%(cmap_dir))
        print ("Final hhbonds  filepath: %s"%(rr_dir))
elif iter_num == 4: # this is multiple model predictor, now modele number is 4
    cmap1dir = "%s/pred_map0/"%(out_dir)
    cmap2dir = "%s/pred_map1/"%(out_dir)
    cmap3dir = "%s/pred_map2/"%(out_dir)
    cmap4dir = "%s/pred_map3/"%(out_dir)
    sum_cmap_dir = "%s/pred_map_ensem/"%(out_dir)
    chkdirs(sum_cmap_dir)
    for key in selected_list:
        seq_name = key
        print('process ', seq_name)
        sum_map_filename = sum_cmap_dir + seq_name + '.txt'
        cmap1 = np.loadtxt(cmap1dir + seq_name + ".txt", dtype=np.float32)
        cmap2 = np.loadtxt(cmap2dir + seq_name + ".txt", dtype=np.float32)
        cmap3 = np.loadtxt(cmap3dir + seq_name + ".txt", dtype=np.float32)
        cmap4 = np.loadtxt(cmap4dir + seq_name + ".txt", dtype=np.float32)
        sum_map = (cmap1 * 0.22 + cmap2 * 0.34 + cmap3 * 0.22 + cmap4 * 0.22)
        np.savetxt(sum_map_filename, sum_map, fmt='%.4f')
    
    cmap_dir= sum_cmap_dir
    hhbonds_dir = cmap_dir+'/hhbonds/'
    chkdirs(hhbonds_dir)
    os.chdir(hhbonds_dir)
    for filename in glob.glob(cmap_dir+'/*.txt'):
        id = os.path.basename(filename)
        id = re.sub('\.txt$', '', id)
        f = open(hhbonds_dir+"/"+id+".raw",'w')
        cmap = np.loadtxt(filename,dtype='float32')
        L = cmap.shape[0]
        for i in range(0,L):
            for j in range(0,L):
                f.write(str(i+1)+" "+str(j+1)+" 0 3.5 "+'%.4f'%(cmap[i][j])+"\n")
        f.close()
        os.system('egrep -v \"^>\" '+ path_of_fasta +id+'.fasta'+'  > '+id+'.hhbonds')
        os.system('cat '+id+'.raw >> '+id+'.hhbonds')
        os.system('rm -f '+id+'.raw')
    if only_predict_flag == False:
        print("Use coneva to evaluated. It may take 1 or 2 minutes.....\n")
        emoji_flag = False
        for key in selected_list:
            # print(key+" evaluated")print
            if emoji_flag:
                emoji_flag=False
                print('\r', '\\(￣︶￣*\\))  \\(￣︶￣*\\))  \\(￣︶￣*\\))  \\(￣︶￣*\\))  \\(￣︶￣*\\))', end='', flush=True)
            else:
                emoji_flag=True
                print('\r', ' ((/*￣︶￣)/  ((/*￣︶￣)/  ((/*￣︶￣)/  ((/*￣︶￣)/  ((/*￣︶￣)/', end='', flush=True)
            pdb_name = get_all_file_contain_str(path_of_pdb, key)
            for i in range(len(pdb_name)):
                pdb_file = path_of_pdb + pdb_name[i]
                if os.path.exists(pdb_file):
                    subprocess.call("perl "+lib_path+"/boneva.pl -rr "+hhbonds_dir+"/"+key+".hhbonds -pdb "+ pdb_file + " -d 3.5 -atom hhbonds -smin 3 >> "+hhbonds_dir+"/hhbonds.txt",shell=True)
                else:
                    print("Please check the pdb file: %s"%pdb_file)
        title_line = "\nPRECISION                     Top-5     Top-L/10  Top-L/5   Top-L/2   Top-L     Top-2L    "
        with open(final_acc_reprot, "a") as myfile:
            myfile.write(title_line)
            myfile.write('\n')
        print(title_line)
        
        top5_acc = topL10_acc = topL5_acc = topL2_acc = topL_acc = top2L_acc = 0 
        count = 0
        for line in open(hhbonds_dir+"/hhbonds.txt",'r'):
            line = line.rstrip()
            if(".pdb (precision)" in line):
                arr = line.split()
                print(arr[0])  
                with open(final_acc_reprot, "a") as myfile:
                    myfile.write(' ')
                    myfile.write(arr[0])
                    myfile.write('\n')
            if(".hhbonds (precision)" in line):
                count += 1
                print(line, end=' ')
                with open(final_acc_reprot, "a") as myfile:
                    myfile.write(line)
                _array = line.split(' ')
                array = [x for x in _array if x !='']
                top5_acc   += float(array[2])
                topL10_acc += float(array[3])
                topL5_acc  += float(array[4])
                topL2_acc  += float(array[5])
                topL_acc   += float(array[6])
                top2L_acc  += float(array[7])
        top5_acc   /= count
        topL10_acc /= count
        topL5_acc  /= count
        topL2_acc  /= count
        topL_acc   /= count
        top2L_acc  /= count
        final_line = "AVERAGE                       %.2f     %.2f     %.2f     %.2f     %.2f     %.2f    \n"%(top5_acc, topL10_acc, topL5_acc, topL2_acc, topL_acc, top2L_acc)
        print(final_line)
        with open(final_acc_reprot, "a") as myfile:
            myfile.write(final_line)
        os.system('rm -f hhbonds.txt')
    else:
        print ("Final pred_map filepath: %s"%(cmap_dir))
        print ("Final hhbonds  filepath: %s"%(rr_dir))
print ("END, Have Fun!\n")
