#!/bin/bash -l
export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""
export HDF5_USE_FILE_LOCKING=FALSE
temp_dir=$(pwd)
##GLOBAL_FLAG
global_dir=/storage/htc/bdm/tianqi/MULTICOM2/DeepHbond
## ENV_FLAG
source $global_dir/env/dncon4_virenv/bin/activate
models_dir[0]=$global_dir/models/pretrain/deephbond_agrc_20/1.dres152_deepcov_cov_ccmpred_pearson_pssm/
models_dir[1]=$global_dir/models/pretrain/deephbond_agrc_20/2.dres152_deepcov_plm_pearson_pssm/
models_dir[2]=$global_dir/models/pretrain/deephbond_agrc_20/3.res152_deepcov_pre_freecontact/
models_dir[3]=$global_dir/models/pretrain/deephbond_agrc_20/4.res152_deepcov_other/
output_dir=/mnt/data/zhiye/Python/Forfun
fasta=/mnt/data/zhiye/Python/Forfun/T0949.fasta
## DBTOOL_FLAG
db_tool_dir=/storage/htc/bdm/zhiye/DNCON4_db_tools/
printf "$global_dir\n"

#################CV_dir output_dir dataset database_path
python $global_dir/lib/Model_predict.py $db_tool_dir $fasta ${models_dir[@]} $output_dir
