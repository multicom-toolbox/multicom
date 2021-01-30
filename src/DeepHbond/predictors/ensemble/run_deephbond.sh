
export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""
export HDF5_USE_FILE_LOCKING=FALSE
temp_dir=$(pwd)
##GLOBAL_FLAG
global_dir=/storage/htc/bdm/tianqi/MULTICOM2/DeepHbond
## ENV_FLAG
source $global_dir/env/deephbond_virenv/bin/activate 

python $global_dir/lib/run_deephbond.py -f /data/casp14/test/DFOLD2/T1019s1/abintio/T1019s1.fasta -o /data/casp14/test/DFOLD2/T1019s1/abintio 
