#!/bin/bash -l
export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""
export HDF5_USE_FILE_LOCKING=FALSE
temp_dir=$(pwd)
##GLOBAL_FLAG
global_dir=/storage/htc/bdm/tianqi/MULTICOM2/DeepHbond
## ENV_FLAG
# source $global_dir/env/dncon4_virenv/bin/activate
models_dir[0]=$global_dir/models/pretrain/deephbond_agrc_20_msa/1.dres152_deepcov_cov_ccmpred_pearson_pssm/
models_dir[1]=$global_dir/models/pretrain/deephbond_agrc_20_msa/2.dres152_deepcov_plm_pearson_pssm/
models_dir[2]=$global_dir/models/pretrain/deephbond_agrc_20_msa/3.res152_deepcov_pre_freecontact/
models_dir[3]=$global_dir/models/pretrain/deephbond_agrc_20_msa/4.res152_deepcov_other/
output_dir=$global_dir/predictors/results/CASP12_MSA_deephbond_agrc_20_msa/
## FEATURE_FLAG
feature_dir=/storage/htc/bdm/zhiye/DNCON4_db_tools/
printf "$global_dir\n"

#################CV_dir output_dir dataset database_path
python $global_dir/lib/Model_evaluate.py ${models_dir[@]} $output_dir 'CASP12_MSA' $feature_dir
