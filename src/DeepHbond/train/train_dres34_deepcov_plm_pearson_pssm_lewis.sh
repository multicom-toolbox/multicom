#!/bin/bash -l
#SBATCH -J  DeepHBond
#SBATCH -o DeepHBond-%j.out
#SBATCH --partition gpu3
#SBATCH --nodes=1
#SBATCH --ntasks=1         # leave at '1' unless using a MPI code
#SBATCH --cpus-per-task=1  # cores per task
#SBATCH --mem-per-cpu=18G  # memory per core (default is 1GB/core)
#SBATCH --time 2-00:00    # days-hours:minutes
#SBATCH --qos=normal
#SBATCH --account=general-gpu  # investors will replace this with their account name
#SBATCH --gres gpu:"GeForce GTX 1080 Ti":1

module load cuda/cuda-9.0.176
module load cudnn/cudnn-7.1.4-cuda-9.0.176
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
# python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_GRESRC' 'DEEPCOV_6463' 'cov_v3' 64 20 3 70 1 $feature_dir $output_dir $acclog_dir 20 5
# python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_GRESRC' 'DEEPCOV_6463' 'plm_v3' 64 34 3 70 1 $feature_dir $output_dir $acclog_dir 20 11
# python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_GRESRC' 'DEEPCOV_6463' 'pre_v3' 64 34 3 70 1 $feature_dir $output_dir $acclog_dir 20 6
# python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_RESOTHERRC' 'DEEPCOV_6463' 'other_v3' 64 34 3 70 1 $feature_dir $output_dir $acclog_dir 20 9
python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_RESOTHERRC' 'DEEPCOV_6463' 'other_hb' 64 34 3 70 1 $feature_dir $output_dir $acclog_dir 20 10
# python $global_dir/lib/train_dncon4_tune_net_test.py 'DNCON4_GRESRC' 'DEEPCOV_6463' 'other_v3' 64 5 3 70 1 $feature_dir $output_dir $acclog_dir 20 11


# test deephbond 
#1 'DNCON4_GRESRC  DEEPCOV_6463  plm_v3  layer 20 length 450 min_hbond 3  
#2 'DNCON4_GRESRC  DEEPCOV_6463  plm_v3  layer 20 length 450 min_hbond 5  
#3 'DNCON4_GRESRC  DEEPCOV_6463  plm_v3  layer 20 length 450 min_hbond 10 

#4 'DNCON4_GRESRC  DEEPCOV_6463  plm_v3  layer 20 length 450 min_hbond 20 
#5 'DNCON4_GRESRC  DEEPCOV_6463  cov_v3  layer 20 length 450 min_hbond 20 
#6 'DNCON4_RESPRERC    DEEPCOV_6463  pre_v3    layer 34 length 320 min_hbond 20 0.85 18885220
#7 'DNCON4_RESOTHERRC  DEEPCOV_6463  other_v3  layer 34 length 320 min_hbond 20 0.85 18885223
#8 'DNCON4_RESOTHERRC  DEEPCOV_6463  other_hb  layer 34 length 320 min_hbond 20 0.85 

#new lable 
#9  'DNCON4_RESOTHERRC  DEEPCOV_6463  other_v3  layer 34 length 320 min_hbond 20 0.5 18911652
#10 'DNCON4_RESOTHERRC  DEEPCOV_6463  other_hb  layer 34 length 320 min_hbond 20 0.5 18911656
#11 'DNCON4_GRESRC      DEEPCOV_6463  other_v3  layer  5 length 320 min_hbond 20 0.5 18911612 