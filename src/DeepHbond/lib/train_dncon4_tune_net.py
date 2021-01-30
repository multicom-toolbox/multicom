import sys
import os
from shutil import copyfile
import platform
from glob import glob

if len(sys.argv) != 13:
  print('please input the right parameters')
  sys.exit(1)
current_os_name = platform.platform()
print('%s' % current_os_name)

if 'Ubuntu' in current_os_name.split('-'): #on local
  sysflag='local'
elif 'centos' in current_os_name.split('-'): #on lewis or multicom
  sysflag='lewis'

GLOBAL_PATH=os.path.dirname(os.path.dirname(__file__)) #this will auto get the DNCON4 folder name

sys.path.insert(0, GLOBAL_PATH+'/lib/')
print (GLOBAL_PATH)
from Model_training import *
from DataProcess_lib import *
from training_strategy import *


net_name = str(sys.argv[1]) # DNCON4_RES
dataset = str(sys.argv[2])  # DNCON2, DNCON4, DEEPCOV, RESPRE
fea_file = str(sys.argv[3])
nb_filters=int(sys.argv[4]) 
nb_layers=int(sys.argv[5]) 
filtsize=int(sys.argv[6]) 
out_epoch=int(sys.argv[7])
in_epoch=int(sys.argv[8]) 
feature_dir = sys.argv[9] 
outputdir = sys.argv[10] 
acclog_dir = sys.argv[11]
index = float(sys.argv[12])


CV_dir=outputdir+'/'+net_name+'_'+dataset+'_'+fea_file+'_filter'+str(nb_filters)+'_layers'+str(nb_layers)+'_ftsize'+str(filtsize)+'_'+str(index)

lib_dir=GLOBAL_PATH+'/lib/'

gpu_mem = gpu_schedul_strategy(sysflag, gpu_mem_rate = 0.8, allow_growth = True)

rerun_epoch=0
if not os.path.exists(CV_dir):
  os.makedirs(CV_dir)
else:
  h5_num = len(glob(CV_dir + '/model_weights/*.h5'))
  rerun_epoch = h5_num
  if rerun_epoch <= 0:
    rerun_epoch = 0
    print("This parameters already exists, quit")
    # sys.exit(1)
  print("####### Restart at epoch ", rerun_epoch)

def chkdirs(fn):
  dn = os.path.dirname(fn)
  if not os.path.exists(dn): os.makedirs(dn)

def chkfiles(fn):
  if os.path.exists(fn):
    return True 
  else:
    return False

dist_string = '80'

path_of_lists   = GLOBAL_PATH+'/data/'+dataset+'/lists-test-train/'
reject_fea_file = GLOBAL_PATH+'/lib/feature_txt/feature_to_use_'+fea_file+'.txt'
path_of_Y       = feature_dir #feature_dir + '/features/' + dataset + '/'
path_of_X       = feature_dir #feature_dir + '/features/' + dataset + '/'
if nb_layers > 40 and nb_layers <=50:
  Maximum_length=400 # 500 will OOM  
elif nb_layers > 50:
  if gpu_mem < 10000: #gpu mem less than 10G 
    print("Too deep, will get OOM error! Please try sallow one: nb_layer set as 34")
    sys.exit(1)
  else:
    Maximum_length=480 
else:
  Maximum_length=480 

sample_datafile=path_of_lists + '/sample.lst'
train_datafile=path_of_lists + '/train.lst'
val_datafile=path_of_lists + '/test.lst'

import time

feature_num = load_sample_data_2D(path_of_lists, path_of_X, path_of_Y,7000,0,dist_string, reject_fea_file)
# add error info 
start_time = time.time()

best_acc=Train_DeepHBond_2D_generator(feature_num,CV_dir,feature_dir,net_name,out_epoch,in_epoch,rerun_epoch, filtsize,
  nb_filters,nb_layers,lib_dir, 1,path_of_lists,path_of_Y, path_of_X,Maximum_length,dist_string, reject_fea_file,
  runcount= index, if_use_binsize = False) #True

model_prefix = net_name
acc_history_out = "%s/%s.acc_history" % (acclog_dir, model_prefix)
chkdirs(acc_history_out)
if chkfiles(acc_history_out):
    print ('acc_file_exist,pass!')
    pass
else:
    print ('create_acc_file!')
    with open(acc_history_out, "w") as myfile:
        myfile.write("time\t netname\t filternum\t layernum\t kernelsize\t batchsize\t accuracy\n")

time_str = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
acc_history_content = "%s\t %s\t %s\t %s\t %s\t %s\t %.4f\n" % (time_str, model_prefix, str(nb_filters),str(nb_layers),str(filtsize),str(1),best_acc)
with open(acc_history_out, "a") as myfile: myfile.write(acc_history_content) 
print("--- %s seconds ---" % (time.time() - start_time))
print("outputdir:", CV_dir)