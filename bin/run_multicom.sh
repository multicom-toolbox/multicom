#!/bin/sh
if [ $# -ne 2 ]
then
        echo "need two parameters: input fasta file, output directory."
        exit 1
fi

GLOBAL_PATH='/home/casp13/deepsf_3d/Github/test/DeepSF/';

#/storage/htc/bdm/tools/MULTICOM_CLUSTER/MULTICOM_lite/library/multicom_vc.pl /storage/htc/bdm/tools/MULTICOM_CLUSTER/MULTICOM_lite/library/multicom_option_casp12 $1 $2 
$GLOBAL_PATH/src/multicom_ve.pl $GLOBAL_PATH/src/multicom_system_option_casp13 $1 $2 

