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


if len(sys.argv) == 9:
    db_tool_dir = os.path.abspath(sys.argv[1])
    fasta = os.path.abspath(sys.argv[2])
    CV_dir = [sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]] # ensemble use four model average
    outdir = os.path.abspath(sys.argv[7]) #also as feature dir
    option = str(sys.argv[8])
elif len(sys.argv) == 6:
    db_tool_dir = os.path.abspath(sys.argv[1])
    fasta = os.path.abspath(sys.argv[2])
    CV_dir = [sys.argv[3]] # ensemble use four model average
    outdir = os.path.abspath(sys.argv[4])
    option = str(sys.argv[5])
else:
  print('please input the right parameters\n')
  # print("dncon4.py [db_tool_dir] [fasta_file] [model_dir] [outdir]")
  sys.exit(1)


print("Model dir:", CV_dir)
only_predict_flag = True # if do not have lable set True
lib_path = sys.path[0]
GLOABL_Path = os.path.dirname(sys.path[0])
print("Find gloabl path :", GLOABL_Path)
path_of_X = outdir
path_of_Y = outdir
path_of_fasta = outdir

feature_list = 'other'# ['combine', 'combine_all2d', 'other', 'ensemble']  # combine will output three map and it combine, other just output one pred
data_list_choose = 'test'# ['train', 'test', 'train_sub', 'all']
Maximum_length = 2000  # casp12 700
dist_string = "80"
loss_function = 'binary_crossentropy'
if_use_binsize = False #False True

db_tool_dir = os.path.abspath(sys.argv[1])
script_path = GLOABL_Path+'/scripts/'
target = os.path.basename(fasta)
target = re.sub("\.fasta","",target)

########
if not os.path.exists(fasta):
    print("Cannot fasta file:"+fasta)
    sys.exit(1)

if not os.path.exists(outdir):
    os.makedirs(outdir)
    print("Create output folder path:"+outdir)

if os.path.exists(outdir+"/X-"+target+".txt") and os.path.exists(outdir+"/"+target+".cov") and os.path.exists(outdir+"/"+target+".plm") and os.path.exists(outdir+"/"+target+".pre"):
    print("All features exists, skip!")
else:
    #DATABASE_FLAG
    uniref90_dir ='/storage/htc/bdm/zhiye/DNCON4_db_tools//databases/uniref90_04_2020'
    metaclust50_dir ='/storage/htc/bdm/zhiye/DNCON4_db_tools//databases/Metaclust_2018_06'
    hhsuitedb_dir ='/storage/htc/bdm/zhiye/DNCON4_db_tools//databases/UniRef30_2020_03'
    ebi_uniref100_dir ='/storage/htc/bdm/zhiye/DNCON4_db_tools//databases/myg_uniref100_04_2020'
    #######end of configure
    #step1: generate alignment
    if os.path.exists(outdir+"/alignment/"+target+".aln") and os.path.getsize(outdir+"/alignment/"+target+".aln") > 0:
        print("alignment generated.....skip")
    else:
        if hhsuitedb_dir.split('/')[-1] =='':
            hhsuitedb_name = hhsuitedb_dir.split('/')[-2]
        else:
            hhsuitedb_name = hhsuitedb_dir.split('/')[-1]
        if option == 'ALN':
            os.system(db_tool_dir+"/tools/DeepAlign1.0/hhjack_hhmsearch3.sh "+fasta+" "+outdir+"/alignment "+db_tool_dir+"/tools/ "+db_tool_dir+"/databases/"+" "+uniref90_dir+"/uniref90 "+hhsuitedb_dir+"/"+hhsuitedb_name+" "+metaclust50_dir+"/metaclust_50")
        elif option == 'MSA':
            os.system("python "+db_tool_dir+"/tools/deepmsa/hhsuite2/scripts/build_MSA.py "+fasta+" -hhblitsdb="+hhsuitedb_dir+"/"+hhsuitedb_name+" -jackhmmerdb="
                +uniref90_dir+"/uniref90 -hmmsearchdb="+ebi_uniref100_dir+"/myg_uniref100 -tmpdir="+outdir+"/alignment/tmp -outdir="
                +outdir+"/alignment -ncpu=8 -overwrite=0")
        else:
            print("Default set DeepAln pipline!\n")
            os.system(db_tool_dir+"/tools/DeepAlign1.0/hhjack_hhmsearch3.sh "+fasta+" "+outdir+"/alignment "+db_tool_dir+"/tools/ "+db_tool_dir+"/databases/"+" "+uniref90_dir+"/uniref90 "+hhsuitedb_dir+"/"+hhsuitedb_name+" "+metaclust50_dir+"/metaclust_50")
        if os.path.exists(outdir+"/alignment/"+target+".aln") and os.path.getsize(outdir+"/alignment/"+target+".aln") > 0:
            print("alignment generated successfully....")
        else:
            print("alignment generation failed....")

    #step2: generate other features
    if os.path.exists(outdir+"/X-"+target+".txt") and os.path.getsize(outdir+"/X-"+target+".txt") > 0:
        print("DNCON2 features generated.....skip")
    else:
        os.system("perl "+script_path+"/generate-other.pl "+db_tool_dir+" "+fasta+" "+outdir+" "+uniref90_dir+"/uniref90")
        if os.path.exists(outdir+"/X-"+target+".txt") and os.path.getsize(outdir+"/X-"+target+".txt") > 0:
            print("DNCON2 features generated successfully....")
        else:
            print("DNCON2 features generation failed....")

    #step3: generate cov
    if os.path.exists(outdir+"/"+target+".cov") and os.path.getsize(outdir+"/"+target+".cov") > 0:
        print("cov generated.....skip")
    else:
        os.system(script_path+"/cov21stats "+outdir+"/alignment/"+target+".aln "+outdir+"/"+target+".cov")
        if os.path.exists(outdir+"/"+target+".cov") and os.path.getsize(outdir+"/"+target+".cov") > 0:
            print("cov generated successfully....")
        else:
            print("cov generation failed....")

    #step4: generate plm
    if os.path.exists(outdir+"/ccmpred/"+target+".plm") and os.path.getsize(outdir+"/ccmpred/"+target+".plm") > 0:
        print("plm generated.....skip")
        os.system("mv "+outdir+"/ccmpred/"+target+".plm "+outdir)
    elif os.path.exists(outdir+"/"+target+".plm") and os.path.getsize(outdir+"/"+target+".plm") > 0:
        print("plm generated.....skip")
    else:
        print("plm generation failed....")

    #step5: generate pre
    if os.path.exists(outdir+"/"+target+".pre") and os.path.getsize(outdir+"/"+target+".pre") > 0:
        print("pre generated.....skip")
    else:
        os.system(script_path+"/calNf_ly "+outdir+"/alignment/"+target+".aln 0.8 > "+outdir+"/"+target+".weight")
        os.system("python -W ignore "+script_path+"/generate_pre.py "+outdir+"/alignment/"+target+".aln "+outdir+"/"+target)
        os.system("rm "+outdir+"/"+target+".weight")
        if os.path.exists(outdir+"/"+target+".pre") and os.path.getsize(outdir+"/"+target+".pre") > 0:
            print("pre generated successfully....")
        else:
            print("pre generation failed....")
##########

if not os.path.exists(fasta):
    print("Cannot fasta file:"+fasta)
    sys.exit(1)

if not os.path.exists(outdir):
    print("Features not exists"+outdir)
    sys.exit(1)

# gpu_schedul_strategy("local", allow_growth=True)

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

##
length = 0
f = open(fasta, 'r')
for line in f.readlines():
    if line.startswith('>'):
        continue
    else:
        length = len(line.strip('\n'))
if length == 0:
    print("Read fasta: %s length wrong!"%fasta)
selected_list = {}
selected_list[target] = length

print('Total Number to predict = ',str(len(selected_list)))

iter_num = 0
if isinstance(CV_dir, str) == True:
    iter_num = 1
    CV_dir = [CV_dir]
else:
    iter_num = len(CV_dir)
chkdirs(outdir)

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

    # pred_history_out = "%s/predict%d.acc_history" % (outdir, index) 
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

    model_predict= "%s/pred_map%d/"%(outdir, index)
    chkdirs(model_predict)
    if 'other' == feature_list:
        if len(reject_fea_file) == 1:
            OTHER = reject_fea_path + reject_fea_file[0]
            # print(OTHER)
        elif len(reject_fea_file) >= 2:
            OTHER = []
            for feafile_num in range(len(reject_fea_file)):
                OTHER.append(reject_fea_path + reject_fea_file[feafile_num])

    for key in selected_list:
        value = selected_list[key]
        p1 = {key: value}
        if if_use_binsize:
            Maximum_length = Maximum_length
        else:
            Maximum_length = value
        if len(p1) < 1:
            continue
        print("start predict %s %d" %(key, value))

        if 'other' in feature_list:
            if len(reject_fea_file) == 1:
                selected_list_2D_other = get_x_2D_from_this_list_pred(p1, path_of_X, Maximum_length, reject_fea_file = OTHER, pdb_len = value)
                if type(selected_list_2D_other) == bool:
                    continue
                DNCON4_prediction_other = DNCON4.predict([selected_list_2D_other], batch_size= 1)  
            elif len(reject_fea_file)>=2:
                pred_temp = []
                bool_flag = False
                for fea_num in range(len(OTHER)):
                    temp = get_x_2D_from_this_list_pred(p1, path_of_X, Maximum_length, dist_string, reject_fea_file[fea_num], value)
                    # print("selected_list_2D.shape: ",temp.shape)
                    if type(temp) == bool:
                        bool_flag= True
                    pred_temp.append(temp)
                if bool_flag == True:
                    continue
                else:
                    DNCON4_prediction_other = DNCON4.predict(pred_temp, batch_size= 1)

            CMAP = DNCON4_prediction_other.reshape(Maximum_length, Maximum_length)
            other_cmap_file = "%s/%s.txt" % (model_predict, key)
            np.savetxt(other_cmap_file, CMAP, fmt='%.4f')

### use boneva to evaluate
if iter_num == 1: # this is single model predictor
    cmap_dir= "%s/pred_map%d/"%(outdir, index)
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
        os.system('egrep -v \"^>\" '+ fasta + ' > '+id+'.hhbonds')
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
        print ("Final hhbonds  filepath: %s"%(hhbonds_dir))
elif iter_num == 4: # this is multiple model predictor, now modele number is 4
    cmap1dir = "%s/pred_map0/"%(outdir)
    cmap2dir = "%s/pred_map1/"%(outdir)
    cmap3dir = "%s/pred_map2/"%(outdir)
    cmap4dir = "%s/pred_map3/"%(outdir)
    sum_cmap_dir = "%s/pred_map_ensem/"%(outdir)
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
        os.system('egrep -v \"^>\" '+ fasta + ' > '+id+'.hhbonds')
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
        print ("Final hhbonds  filepath: %s"%(hhbonds_dir))
print ("END, Have Fun!\n")