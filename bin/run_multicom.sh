#!/bin/sh
if [ $# -ne 2 ]
then
        echo "need two parameters: input fasta file, output directory."
        exit 1
fi

/storage/htc/bdm/tools/MULTICOM_CLUSTER/MULTICOM_lite/library/multicom_vc.pl /storage/htc/bdm/tools/MULTICOM_CLUSTER/MULTICOM_lite/library/multicom_option_casp12 $1 $2 

