#!/bin/bash -l
export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""
export HDF5_USE_FILE_LOCKING=FALSE

##GLOBAL_FALG
global_dir=/mnt/data/zhiye/Python/DeepHBond
## ENV_FLAG
source $global_dir/env/deephbond_virenv/bin/activate
## FEATURE_FLAG
feature_dir=/storage/htc/bdm/zhiye/DNCON4_db_tools/
output_dir=$global_dir/models/custom/gresrc_plm/
acclog_dir=$global_dir/models/custom/All_Validation_Acc
printf "$global_dir\n"

#################net_name dataset fea_file nb_filters nb_layers filtsize out_epoch in_epoch feature_dir outputdir acclog_dir index
python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_GRESRC' 'DEEPCOV_6463' 'plm_v3' 64 20 3 70 1 $feature_dir $output_dir $acclog_dir 3 1

#1 