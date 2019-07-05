#!/bin/sh
if [ $# -ne 3 ]
then
        echo "need three parameters: target id, input fasta file, output directory."
        exit 1
fi

targetid=$1
fastafile=$2
outputdir=$3

source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/boost_1_55_0/lib/:/home/jh7x3/multicom_beta1.0/tools/OpenBLAS:$LD_LIBRARY_PATH

if [ ! -d "$outputdir" ]; then
  mkdir -p $outputdir
fi

/home/jh7x3/multicom_beta1.0/src/multicom_ve.pl /home/jh7x3/multicom_beta1.0/src/multicom_system_option_casp13 $fastafile $outputdir 
/home/jh7x3/multicom_beta1.0/src/visualize_multicom_cluster/P1_organize_prediction.sh $outputdir  $targetid  $outputdir/multicom_results
