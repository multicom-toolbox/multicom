# -*- coding: utf-8 -*-
"""
Created on Thu Jan 2 10:48:28 2020

@author: Zhiye
"""

from shutil import copyfile
import platform
import os
import numpy as np
import math
import sys
import random
import keras.backend as K
import itertools
from operator import itemgetter
from sklearn.metrics import recall_score, f1_score, confusion_matrix, matthews_corrcoef, precision_score

epsilon = K.epsilon()
# from Data_loading import getX_1D_2D,getX_2D_format

def chkdirs(fn):
  dn = os.path.dirname(fn)
  if not os.path.exists(dn): os.makedirs(dn)

def chkfiles(fn):
  if os.path.exists(fn):
    return True 
  else:
    return False

def build_dataset_dictionaries(path_lists):
  length_dict = {}
  n_dict = {}
  neff_dict = {}
  with open(path_lists + 'L.txt') as f:
    for line in f:
      cols = line.strip().split()
      length_dict[cols[0]] = int(cols[1])
  with open(path_lists + 'N.txt') as f:
    for line in f:
      cols = line.strip().split()
      n_dict[cols[0]] = int(float(cols[1]))
  with open(path_lists + 'Neff.txt') as f:
    for line in f:
      cols = line.strip().split()
      neff_dict[cols[0]] = int(float(cols[1]))
  tr_l = {}
  tr_n = {}
  tr_e = {}
  with open(path_lists + 'train.lst') as f:
    for line in f:
      tr_l[line.strip()] = length_dict[line.strip()]
      tr_n[line.strip()] = n_dict[line.strip()]
      tr_e[line.strip()] = neff_dict[line.strip()]
  te_l = {}
  te_n = {}
  te_e = {}
  with open(path_lists + 'test.lst') as f:
    for line in f:
      te_l[line.strip()] = length_dict[line.strip()]
      te_n[line.strip()] = n_dict[line.strip()]
      te_e[line.strip()] = neff_dict[line.strip()]
  print ('')
  print ('Data counts:')
  print ('Total : ' + str(len(length_dict)))
  print ('Train : ' + str(len(tr_l)))
  print ('Test  : ' + str(len(te_l)))
  print ('')
  return (tr_l, tr_n, tr_e, te_l, te_n, te_e)


def build_dataset_dictionaries_other(path_lists, list_name):
  length_dict = {}
  with open(path_lists + 'L.txt') as f:
    for line in f:
      cols = line.strip().split()
      length_dict[cols[0]] = int(cols[1])
  tr_l = {}
  with open(path_lists + list_name) as f:
    for line in f:
      if line.strip() not in length_dict:
        continue
      else:
        tr_l[line.strip()] = length_dict[line.strip()]
  # print ('Data counts:')
  # print ('Total : ' + str(len(length_dict)))
  # print ('Train : ' + str(len(tr_l)))
  return (tr_l)

def build_dataset_dictionaries_train(path_lists):
  length_dict = {}
  with open(path_lists + 'L.txt') as f:
    for line in f:
      cols = line.strip().split()
      length_dict[cols[0]] = int(cols[1])
  tr_l = {}
  with open(path_lists + 'train.lst') as f:
    for line in f:
      if line.strip() not in length_dict:
        continue
      else:
        tr_l[line.strip()] = length_dict[line.strip()]
  return (tr_l)

def build_dataset_dictionaries_test(path_lists):
  length_dict = {}
  with open(path_lists + 'L.txt') as f:
    for line in f:
      cols = line.strip().split()
      length_dict[cols[0]] = int(cols[1])
  te_l = {}
  with open(path_lists + 'test.lst') as f:
    for line in f:
      if line.strip() not in length_dict:
        continue
      else:
        te_l[line.strip()] = length_dict[line.strip()]
  return (te_l)

def build_dataset_dictionaries_sample(path_lists):
  length_dict = {}
  with open(path_lists + 'L.txt') as f:
    for line in f:
      cols = line.strip().split()
      length_dict[cols[0]] = int(cols[1])
  ex_l = {}
  with open(path_lists + 'sample.lst') as f:
    for line in f:
      if line.strip() not in length_dict:
        continue
      else:
        ex_l[line.strip()] = length_dict[line.strip()]
  return (ex_l)

def subset_pdb_dict(dict, minL, maxL, count, randomize_flag):
  selected = {}
  # return a dict with random 'X' PDBs
  if (randomize_flag == 'random'):
    pdbs = list(dict.keys())
    sys.stdout.flush()
    random.shuffle(pdbs)
    i = 0
    for pdb in pdbs:
      if (dict[pdb] > minL and dict[pdb] <= maxL):
        selected[pdb] = dict[pdb]
        i = i + 1
        if i == count:
          break
  # return first 'X' PDBs sorted by L
  if (randomize_flag == 'ordered'):
    i = 0
    for key, value in sorted(dict.items(), key=lambda  x: x[1]):
      if (dict[key] > minL and dict[key] <= maxL):
        selected[key] = value
        i = i + 1
        if i == count:
          break
  return selected

def load_sample_data_2D(data_list, path_of_X, path_of_Y,seq_end, min_seq_sep,dist_string, reject_fea_file='None'):
  import pickle
  data_all_dict = dict()
  print("######### Loading data\n")
  accept_list = []
  notxt_flag = True
  if reject_fea_file != 'None':
    with open(reject_fea_file) as f:
      for line in f:
        if line.startswith('#'):
          feature_name = line.strip()
          feature_name = feature_name[0:]
          accept_list.append(feature_name)
  ex_l = build_dataset_dictionaries_sample(data_list)
  sample_dict = subset_pdb_dict(ex_l, 0, 500, seq_end, 'random') #can be random ordered
  sample_name = list(sample_dict.keys())
  sample_lens = list(sample_dict.values())
  feature_num = 0
  for i in range(0,len(sample_name)):
    pdb_name = sample_name[i]
    pdb_lens = sample_lens[i]
    print(pdb_name, "..",end='')
    
    featurefile =path_of_X + '/other/' + 'X-'  + pdb_name + '.txt'
    if ((len(accept_list) == 1 and ('# cov' not in accept_list and '# plm' not in accept_list and '# pre' not in accept_list and '# netout' not in accept_list)) or 
          (len(accept_list) == 2 and ('# cov' not in accept_list or '# plm' not in accept_list  or '# pre' not in accept_list or '# netout' not in accept_list)) or (len(accept_list) > 2)):
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

    ### load the data
    (featuredata,feature_index_all_dict) = getX_2D_format(featurefile, cov, plm, pre, netout, accept_list, pdb_lens, notxt_flag)
    # print("\n######",len(featuredata))

    feature_num = len(featuredata)
  return feature_num

def get_all_file_contain_str(dir, list):
    files = os.listdir(dir)
    tar_filename = []
    for file in files:
        if list in file:
            tar_filename.append(file)

    return tar_filename

def get_sub_map_index(index_file):
  index_list = np.loadtxt(index_file)[:,1]
  sub_map_index = [index_list[0] - 1, index_list[-1] - 1]
  sub_map_index = list(map(int, sub_map_index))
  summary=[]
  for k, g in itertools.groupby(enumerate(index_list), lambda x: x[1]-x[0]):
      summary.append(list(map(itemgetter(1), g)))
  sub_map_gap = []
  for i in range(len(summary)-1):
      # list file start from 1, array start from 0
      left = int(summary[i][-1] + 1) - 1
      right = int(summary[i+1][0] -1) - 1
      sub_map_gap.append([left, right])
  return sub_map_index, sub_map_gap

def get_y_from_this_list_casp(selected_ids, path, index_path, min_seq_sep, l_max, y_dist, lable_type = 'bin'):
  for pdb in selected_ids:
    file_names = get_all_file_contain_str(path, pdb)
    # print(file_names)
    Y = np.zeros((len(file_names), l_max * l_max))
    sub_map_index = list()
    sub_map_gap = list()
    if len(file_names) > 1:
      for i in range(len(file_names)):
          sub_map_index1, sub_map_gap1 = get_sub_map_index(index_path+'/'+file_names[i].split('-')[1]+'-'+file_names[i].split('-')[2])
          sub_map_index.append(sub_map_index1)
          sub_map_gap.append(sub_map_gap1)
          Y[i,:] =  getY(path + '/' + file_names[i], min_seq_sep, l_max)
    else:
      sub_map_index1, sub_map_gap1 = get_sub_map_index(index_path+'/'+file_names[0].split('-')[1]+'-'+file_names[0].split('-')[2])
      sub_map_index.append(sub_map_index1)
      sub_map_gap.append(sub_map_gap1)
      Y[0,:] =  getY(path + '/' + file_names[0], min_seq_sep, l_max)
  return Y, sub_map_index, sub_map_gap

def get_y_from_this_list(selected_ids, path, min_seq_sep, l_max, y_dist, lable_type = 'bin'):
  xcount = len(selected_ids)
  Y = np.zeros((xcount, l_max * l_max))
  i = 0
  if lable_type == 'bin':
    for pdb in sorted(selected_ids):
      y_file = path + '/' +  pdb + '.txt'
      if not os.path.isfile(y_file):
        print("%s not exits!" % y_file)
        return False
      Y[i, :]  = getY(y_file, min_seq_sep, l_max)
      i = i + 1
  elif lable_type == 'real':
    for pdb in sorted(selected_ids):
      Y[i, :]  = getY(path + pdb + '.txt', 0, l_max)
      i = i + 1
  return Y

#get binary y lable
def getY(true_file, min_seq_sep, l_max): #hhbond < 3
  # calcualte the length of the protein (the first feature)
  Y = np.zeros((l_max, l_max))
  true_y = np.loadtxt(true_file)
  tmp_y = (np.triu(true_y, min_seq_sep) + np.tril(true_y, -min_seq_sep))
  L = true_y.shape[0]
  if L > l_max:
      print("error l_max too small")
      return False
  else:
    Y[0:L,0:L] = tmp_y
  Y = Y.flatten()
  return Y

def getX_2D_format(feature_file, cov, plm, pre, netout, accept_list, pdb_len = 0, notxt_flag = True, logfile = None):
  # calcualte the length of the protein (the first feature)
  if logfile != None:
    chkdirs(logfile)

  L = 0
  Data = []
  feature_all_dict = dict()
  feature_index_all_dict = dict() # to make sure the feature are same ordered 
  feature_name='None'
  feature_index=0
  # print(reject_list)
  if notxt_flag == True:
    L = pdb_len
  else:
    with open(feature_file) as f:
      for line in f:
        if line.startswith('#'):
          continue
        L = line.strip().split()
        L = int(round(math.exp(float(L[0]))))
        break
    with open(feature_file) as f:
      accept_flag = 1
      for line in f:
        if line.startswith('#'):
          if line.strip() not in accept_list:
            accept_flag = 0
          else:
            accept_flag = 1
          feature_name = line.strip()
          continue
        if accept_flag == 0:
          continue
        
        if line.startswith('#'):
          continue
        this_line = line.strip().split()
        if len(this_line) == 0:
          continue
        if len(this_line) == 1:
          # 0D feature
          continue
          # feature_namenew = feature_name + ' 0D'
          # feature_index +=1
          # if feature_index in feature_index_all_dict:
          #   print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
          #   exit;
          # else:
          #   feature_index_all_dict[feature_index] = feature_namenew

          # feature0D = np.zeros((L, L))
          # feature0D[:, :] = float(this_line[0])
          # #feature0D = np.zeros((1, L))
          # #feature0D[0, :] = float(this_line[0])
          
          # if feature_index in feature_all_dict:
          #   print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
          #   exit;
          # else:
          #   feature_all_dict[feature_index] = feature0D
        elif len(this_line) == L:
          # 1D feature
          # continue
          feature1D1 = np.zeros((L, L))
          feature1D2 = np.zeros((L, L))
          for i in range (0, L):
            feature1D1[i, :] = float(this_line[i])
            feature1D2[:, i] = float(this_line[i])
          
          ### load feature 1
          feature_index +=1
          feature_namenew = feature_name + ' 1D1'
          if feature_index in feature_index_all_dict:
            print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
            exit;
          else:
            feature_index_all_dict[feature_index] = feature_namenew
          
          if feature_index in feature_all_dict:
            print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
            exit;
          else:
            feature_all_dict[feature_index] = feature1D1
          
          ### load feature 2
          feature_index +=1
          feature_namenew = feature_name + ' 1D2'
          if feature_index in feature_index_all_dict:
            print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
            exit;
          else:
            feature_index_all_dict[feature_index] = feature_namenew

          if feature_index in feature_all_dict:
            print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
            exit;
          else:
            feature_all_dict[feature_index] = feature1D2
        elif len(this_line) == L * L:
          # 2D feature
          feature2D = np.asarray(this_line).reshape(L, L)
          feature_index +=1
          feature_namenew = feature_name + ' 2D'
          if feature_index in feature_index_all_dict:
            print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
            exit
          else:
            feature_index_all_dict[feature_index] = feature_namenew
          
          if feature_index in feature_all_dict:
            print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
            exit
          else:
            feature_all_dict[feature_index] = feature2D
        else:
          print (line)
          print ('Error!! Unknown length of feature in !!' + feature_file)
          print ('Expected length 0, ' + str(L) + ', or ' + str (L*L) + ' - Found ' + str(len(this_line)))
          sys.exit()
  #Add Covariance Matrix 
  if '# cov' in accept_list:   
      cov_rawdata = np.fromfile(cov, dtype=np.float32)
      length = int(math.sqrt(cov_rawdata.shape[0]/21/21))
      if length != L:
          print("Cov Bad Alignment, want %d get %d, pls check! %s" %(L, length, cov))
          if logfile != None:
            with open(logfile, "a") as myfile:
              myfile.write("Cov Bad Alignment, pls check! %s\n" %(cov))
            return False, False
          else:
            print("Cov Bad Alignment, pls check! %s\n" %(cov))
            return False, False
            # sys.exit()
      inputs_cov = cov_rawdata.reshape(1,441,L,L) #????
      for i in range(441):
          feature2D = inputs_cov[0][i]
          feature_namenew = '# Covariance Matrix '+str(i+1)+ ' 2D'
          feature_index +=1
          if feature_index in feature_index_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_index_all_dict[feature_index] = feature_namenew
          if feature_index in feature_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_all_dict[feature_index] = feature2D
  #Add Pseudo_Likelihood Maximization
  if '# plm' in accept_list:  
      plm_rawdata = np.fromfile(plm, dtype=np.float32)
      length = int(math.sqrt(plm_rawdata.shape[0]/21/21))
      if length != L:
          print("Plm Bad Alignment, want %d get %d, pls check! %s" %(L, length, plm))
          if logfile != None:
            with open(logfile, "a") as myfile:
              myfile.write("Plm Bad Alignment, pls check! %s\n" %(plm))
            return False, False
          else:
            print("Plm Bad Alignment, pls check! %s\n" %(plm))
            return False, False
            # sys.exit()
      inputs_plm = plm_rawdata.reshape(1,441,L,L)
      for i in range(441):
          feature2D = inputs_plm[0][i]
          feature_namenew = '# Pseudo_Likelihood Maximization '+str(i+1)+ ' 2D'
          feature_index +=1
          if feature_index in feature_index_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_index_all_dict[feature_index] = feature_namenew
          if feature_index in feature_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_all_dict[feature_index] = feature2D
  if '# pre' in accept_list:  
      pre_rawdata = np.fromfile(pre, dtype=np.float32)
      length = int(math.sqrt(pre_rawdata.shape[0]/21/21))
      if length != L:
          print("Pre Bad Alignment, want %d get %d, pls check! %s" %(L, length, pre))
          if logfile != None:
            with open(logfile, "a") as myfile:
              myfile.write("Pre Bad Alignment, pls check! %s\n" %(pre))
            return False, False
          else:
            print("Pre Bad Alignment, pls check! %s\n" %(pre))
            return False, False
            # sys.exit()
      inputs_pre = pre_rawdata.reshape(1,441,L,L)
      for i in range(441):
          feature2D = inputs_pre[0][i]
          feature_namenew = '# Pre Maximization '+str(i+1)+ ' 2D'
          feature_index +=1
          if feature_index in feature_index_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_index_all_dict[feature_index] = feature_namenew
          if feature_index in feature_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_all_dict[feature_index] = feature2D
  if '# netout' in accept_list:
      netout_raw=np.load(netout)
      length = netout_raw.shape[0]
      chn = netout_raw.shape[-1]
      if length != L:
          print("Net Bad Alignment, pls check!")
          return False, False
          # sys.exit()
      inputs_netout =  netout_raw.transpose(2, 0, 1)
      inputs_netout =  inputs_netout.reshape(1,chn,L,L)
      for i in range(chn):
          feature2D = inputs_netout[0][i]
          feature_namenew = '# Network output '+str(i+1)+ ' 2D'
          feature_index +=1
          if feature_index in feature_index_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_index_all_dict[feature_index] = feature_namenew
          if feature_index in feature_all_dict:
              print("Duplicate feature name ",feature_namenew, " in file ",feature_file)
              sys.exit()
          else:
              feature_all_dict[feature_index] = feature2D
  return (feature_all_dict,feature_index_all_dict)

def get_x_2D_feature_number(selected_ids, feature_dir,  reject_fea_file='None'):
  accept_list = []
  notxt_flag = True
  if reject_fea_file != 'None':
    with open(reject_fea_file) as f:
      for line in f:
        if line.startswith('#'):
          feature_name = line.strip()
          feature_name = feature_name[0:]
          accept_list.append(feature_name)
  feature_num = 0
  path_of_X = feature_dir
  pdb_name = list(selected_ids.keys())[0]
  pdb_lens = list(selected_ids.values())[0]
  # print(pdb_name, pdb_lens)
  
  featurefile =path_of_X + '/other/' + 'X-'  + pdb_name + '.txt'
  if ((len(accept_list) == 1 and ('# cov' not in accept_list and '# plm' not in accept_list and '# pre' not in accept_list and '# netout' not in accept_list)) or 
        (len(accept_list) == 2 and ('# cov' not in accept_list or '# plm' not in accept_list  or '# pre' not in accept_list or '# netout' not in accept_list)) or (len(accept_list) > 2)):
    notxt_flag = False
    if not os.path.isfile(featurefile):
                print("feature file not exists: ",featurefile, " pass!")
  cov = path_of_X + '/cov/' + pdb_name + '.cov'
  if '# cov' in accept_list:
    if not os.path.isfile(cov):
                print("Cov Matrix file not exists: ",cov, " pass!")   
  plm = path_of_X + '/plm/' + pdb_name + '.plm'
  if '# plm' in accept_list:
    if not os.path.isfile(plm):
                print("plm matrix file not exists: ",plm, " pass!")        
  pre = path_of_X + '/pre/' + pdb_name + '.pre'
  if '# pre' in accept_list:
    if not os.path.isfile(pre):
                print("pre matrix file not exists: ",pre, " pass!")
  netout = path_of_X + '/net_out/' + pdb_name + '.npy'
  if '# netout' in accept_list:      
    if not os.path.isfile(netout):
                print("netout matrix file not exists: ",netout, " pass!") 

  ### load the data
  (featuredata,feature_index_all_dict) = getX_2D_format(featurefile, cov, plm, pre, netout, accept_list, int(pdb_lens), notxt_flag)
  # print("\n######",len(featuredata))

  feature_num = len(featuredata)
  return feature_num

def get_x_2D_from_this_list(selected_ids, feature_dir, l_max, dist_string, feature_num = None, reject_fea_file='None', pdb_len = 0):
  xcount = len(selected_ids)
  # fea_len = feature_2D_all[0].shape[0]
  F_2D = feature_num
  X_2D = np.zeros((xcount, l_max, l_max, F_2D))
  pdb_indx = 0
  accept_list = []
  notxt_flag = True
  if reject_fea_file != 'None':
    with open(reject_fea_file) as f:
      for line in f:
        if line.startswith('#'):
          feature_name = line.strip()
          feature_name = feature_name[0:]
          accept_list.append(feature_name)
  for pdb_name in sorted(selected_ids):
      # print(pdb_name, "..",end='')

      featurefile =feature_dir + '/other/' + 'X-'  + pdb_name + '.txt'
      if ((len(accept_list) == 1 and ('# cov' not in accept_list and '# plm' not in accept_list and '# pre' not in accept_list and '# netout' not in accept_list)) or 
        (len(accept_list) == 2 and ('# cov' not in accept_list or '# plm' not in accept_list or '# pre' not in accept_list or '# netout' not in accept_list)) or (len(accept_list) > 2)):
        notxt_flag = False
        if not os.path.isfile(featurefile):
                    print("feature file not exists: ",featurefile, " pass!")
                    continue   
      cov = feature_dir + '/cov/' + pdb_name + '.cov'  
      if '# cov' in accept_list:
        if not os.path.isfile(cov):
                    print("Cov Matrix file not exists: ",cov, " pass!")
                    continue     
      plm = feature_dir + '/plm/' + pdb_name + '.plm'   
      if '# plm' in accept_list:
        if not os.path.isfile(plm):
                    print("plm matrix file not exists: ",plm, " pass!")
                    continue 
      pre = feature_dir + '/pre/' + pdb_name + '.pre'   
      if '# pre' in accept_list:
        if not os.path.isfile(pre):
                    print("pre matrix file not exists: ",pre, " pass!")
                    continue 
      netout = feature_dir + '/net_out/' + pdb_name + '.npy'
      if '# netout' in accept_list:      
        if not os.path.isfile(netout):
                    print("netout matrix file not exists: ",netout, " pass!")
                    continue 
      ### load the data
      (featuredata,feature_index_all_dict) = getX_2D_format(featurefile, cov, plm, pre, netout, accept_list, pdb_len, notxt_flag)     
      ### merge 1D data to L*m
      ### merge 2D data to  L*L*n
      feature_num_local = len(featuredata)
      feature_2D_all=[]
      for key in sorted(feature_index_all_dict.keys()):
          featurename = feature_index_all_dict[key]
          feature = featuredata[key]
          feature = np.asarray(feature)
          #print("keys: ", key, " featurename: ",featurename, " feature_shape:", feature.shape)
          
          if feature.shape[0] == feature.shape[1]:
            feature_2D_all.append(feature)
          else:
            print("Wrong dimension")
     
      L = feature_2D_all[0].shape[0]
      F = len(feature_2D_all)
      X_tmp = np.zeros((L, L, F))
      for i in range (0, F):
        X_tmp[:,:, i] = feature_2D_all[i]      
      
      feature_2D_all = X_tmp
      #print feature_2D_all.shape #(123, 123, 18) 

      if len(feature_2D_all[0, 0, :]) != feature_num:
        print('ERROR! 2D Feature length ',pdb_name)
        exit;

      ### expand to lmax
      if feature_2D_all[0].shape[0] <= l_max:
        # print("extend to lmax: ",feature_2D_all.shape)
        L = feature_2D_all.shape[0]
        F = feature_2D_all.shape[2]
        X_tmp = np.zeros((l_max, l_max, F))
        for i in range (0, F):
          X_tmp[0:L,0:L, i] = feature_2D_all[:,:,i]
        feature_2D_all_complete = X_tmp

      X_2D[pdb_indx, :, :, :] = feature_2D_all_complete
      pdb_indx = pdb_indx + 1
  return X_2D
  
def get_x_2D_from_this_list_pred(selected_ids, feature_dir, l_max, feature_num = None, reject_fea_file='None', pdb_len = 0):
  xcount = len(selected_ids)
  sample_pdb = ''
  for pdb in selected_ids:
    sample_pdb = pdb
    break
  accept_list = []
  notxt_flag = True
  if reject_fea_file != 'None':
    with open(reject_fea_file) as f:
      for line in f:
        if line.startswith('#'):
          feature_name = line.strip()
          feature_name = feature_name[0:]
          accept_list.append(feature_name)

  featurefile =feature_dir + '/' + 'X-'  + sample_pdb + '.txt'
  cov =feature_dir + '/' + sample_pdb + '.cov'
  plm =feature_dir + '/' + sample_pdb + '.plm'
  pre =feature_dir + '/' + sample_pdb + '.pre'
  netout = feature_dir + '/' + sample_pdb + '.npy'
  # print(featurefile)
  if ((len(accept_list) == 1 and ('# cov' not in accept_list and '# plm' not in accept_list and '# pre' not in accept_list and '# netout' not in accept_list)) or 
        (len(accept_list) == 2 and ('# cov' not in accept_list or '# plm' not in accept_list or '# pre' not in accept_list or '# netout' not in accept_list)) or (len(accept_list) > 2)):
    notxt_flag = False
    # print
    if not os.path.isfile(featurefile):
                print("feature file not exists: ",featurefile, " pass!")   
                return False
  if '# cov' in accept_list:
    if not os.path.isfile(cov):
                print("Cov Matrix file not exists: ",cov, " pass!")
                return False
  if '# plm' in accept_list:
    if not os.path.isfile(plm):
                print("plm matrix file not exists: ",plm, " pass!")
                return False
  if '# pre' in accept_list:
    if not os.path.isfile(pre):
                print("pre matrix file not exists: ",pre, " pass!")
                return False
  if '# netout' in accept_list:      
    if not os.path.isfile(netout):
                print("netout matrix file not exists: ",netout, " pass!")
                return False

  (featuredata,feature_index_all_dict) = getX_2D_format(featurefile, cov, plm, pre, netout, accept_list, pdb_len, notxt_flag)    

  
  ### merge 1D data to L*m
  ### merge 2D data to  L*L*n
  feature_2D_all=[]
  for key in sorted(feature_index_all_dict.keys()):
      featurename = feature_index_all_dict[key]
      feature = featuredata[key]
      feature = np.asarray(feature)
      #print("keys: ", key, " featurename: ",featurename, " feature_shape:", feature.shape)
      
      if feature.shape[0] == feature.shape[1]:
        feature_2D_all.append(feature)
      else:
        print("Wrong dimension")
  
  # fea_len = feature_2D_all[0].shape[0]
  F_2D = len(feature_2D_all)
  # feature_2D_all = np.asarray(feature_2D_all)
  #print(feature_2D_all.shape)
  # print("Total ",F_2D, " 2D features")
  X_2D = np.zeros((xcount, l_max, l_max, F_2D))
  pdb_indx = 0
  for pdb_name in sorted(selected_ids):
      # print(pdb_name, "..",end='')

      featurefile =feature_dir + '/' + 'X-'  + sample_pdb + '.txt'
      if ((len(accept_list) == 1 and ('# cov' not in accept_list and '# plm' not in accept_list and '# pre' not in accept_list and '# netout' not in accept_list)) or 
        (len(accept_list) == 2 and ('# cov' not in accept_list or '# plm' not in accept_list or '# pre' not in accept_list or '# netout' not in accept_list)) or (len(accept_list) > 2)):
        notxt_flag = False
        if not os.path.isfile(featurefile):
                    print("feature file not exists: ",featurefile, " pass!")
                    continue   
      cov = feature_dir + '/' + pdb_name + '.cov'  
      if '# cov' in accept_list:
        if not os.path.isfile(cov):
                    print("Cov Matrix file not exists: ",cov, " pass!")
                    continue     
      plm = feature_dir + '/' + pdb_name + '.plm'   
      if '# plm' in accept_list:
        if not os.path.isfile(plm):
                    print("plm matrix file not exists: ",plm, " pass!")
                    continue 
      pre = feature_dir + '/' + pdb_name + '.pre'   
      if '# pre' in accept_list:
        if not os.path.isfile(pre):
                    print("pre matrix file not exists: ",pre, " pass!")
                    continue 
      netout = feature_dir + '/' + pdb_name + '.npy'
      if '# netout' in accept_list:      
        if not os.path.isfile(netout):
                    print("netout matrix file not exists: ",netout, " pass!")
                    continue 
      ### load the data
      (featuredata,feature_index_all_dict) = getX_2D_format(featurefile, cov, plm, pre, netout, accept_list, pdb_len, notxt_flag)   
      ### merge 1D data to L*m
      ### merge 2D data to  L*L*n
      feature_2D_all=[]
      for key in sorted(feature_index_all_dict.keys()):
          featurename = feature_index_all_dict[key]
          feature = featuredata[key]
          feature = np.asarray(feature)
          #print("keys: ", key, " featurename: ",featurename, " feature_shape:", feature.shape)
          
          if feature.shape[0] == feature.shape[1]:
            feature_2D_all.append(feature)
          else:
            print("Wrong dimension")
     
      L = feature_2D_all[0].shape[0]
      F = len(feature_2D_all)
      X_tmp = np.zeros((L, L, F))
      for i in range (0, F):
        X_tmp[:,:, i] = feature_2D_all[i]      
      
      feature_2D_all = X_tmp
      #print feature_2D_all.shape #(123, 123, 18) 
      if len(feature_2D_all[0, 0, :]) != F_2D:
        print('ERROR! 2D Feature length of ',sample_pdb,' not equal to ',pdb_name)
        exit;

      ### expand to lmax
      if feature_2D_all[0].shape[0] <= l_max:
        # print("extend to lmax: ",feature_2D_all.shape)
        L = feature_2D_all.shape[0]
        F = feature_2D_all.shape[2]
        X_tmp = np.zeros((l_max, l_max, F))
        for i in range (0, F):
          X_tmp[0:L,0:L, i] = feature_2D_all[:,:,i]
        feature_2D_all_complete = X_tmp
      X_2D[pdb_indx, :, :, :] = feature_2D_all_complete
      pdb_indx = pdb_indx + 1
  return X_2D

def evaluate_prediction (true_map, pred_map, min_seq_sep):

  true_map = (np.triu(true_map, min_seq_sep) + np.tril(true_map, -min_seq_sep))
  pred_map = (np.triu(pred_map, min_seq_sep) + np.tril(pred_map, -min_seq_sep))

  true_map = np.squeeze(true_map)
  pred_map = np.squeeze(pred_map)

  #trans prob_map into bin_map
  pred_map[pred_map >=0.5]=1
  pred_map[pred_map < 0.5]=0


  (avg_prec, avg_recall, avg_f1, avg_mcc, sum_hbond, diff_hbond) = print_detailed_evaluations(true_map, pred_map)
  return (avg_prec, avg_recall, avg_f1, avg_mcc, sum_hbond, diff_hbond)

def print_detailed_evaluations(true_map, pred_map):
  avg_prec = 0.0
  avg_recall = 0.0
  avg_f1 = 0.0
  avg_mcc = 0.0
  sum_hbond = 0.0
  diff_hbond = 0.0

  mcc    = matthews_corrcoef(true_map, pred_map)
  prec   = precision_score(true_map, pred_map)
  recall = recall_score(true_map, pred_map)
  F1     = f1_score(true_map, pred_map)
  sum_hbond = true_map.sum()
  diff_hbond = (pred_map-true_map).sum()

  return (prec, recall, F1, mcc, sum_hbond, diff_hbond)


