#!/bin/sh
if [ $# -ne 3 ]
then
        echo "need three parameters: target id, input fasta file, output directory."
        exit 1
fi

targetid=$1
fastafile=$2
outputdir=$3

source /storage/hpc/scratch/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/storage/hpc/scratch/jh7x3/multicom/tools/boost_1_55_0/lib/:/storage/hpc/scratch/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [ ! -d "$outputdir" ]; then
  mkdir -p $outputdir
fi

/storage/hpc/scratch/jh7x3/multicom/src/multicom_ve.pl /storage/hpc/scratch/jh7x3/multicom/src/multicom_system_option_casp13 $fastafile $outputdir 
/storage/hpc/scratch/jh7x3/multicom/src/visualize_multicom_cluster/P1_organize_prediction.sh $outputdir  $targetid  $outputdir/multicom_results
