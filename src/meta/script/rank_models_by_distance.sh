#!/bin/sh

export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""
export HDF5_USE_FILE_LOCKING=FALSE


if [ $# -ne 5 ]
then
        echo "need 5 parameters: the installation path of distrank tool, a file containing a list of models in PDB format, predicted distance map, an input fasta sequence file, and output directory." 

#Parameter 1: a file containing a list of models. Each line stores the full path of a structural model. Absolute path is required.
#Parameter 2: predicted distance map. Absoluate path is required 
#Parameter 3: a sequence file in fasta format. Absolute path is required. 
#Parameter 4: an output directory. A ranking file is generated under the directory (rank.txt?). Absolute path is reuqired. 

#output: the scores of models are stored in rank.txt. The suffix (.pdb) of model names are omitted.  

        exit 1
fi

source $1/installation/env/distrank_virenv/bin/activate

python $1/lib/dfold_rank.py -f $2 -d $3 -fa $4 -o $5





