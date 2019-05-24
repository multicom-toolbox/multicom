#!/bin/sh
if [ $# -ne 2 ]
then
        echo "need two parameters: input fasta file, output directory."
        exit 1
fi

fastafile=$1
outputdir=$2

source /data/jh7x3/multicom_github/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [ ! -d "$outputdir" ]; then
  mkdir -p $outputdir
fi

/data/jh7x3/multicom_github/jie_test/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/jie_test/multicom/src/multicom_system_option_casp13 $fastafile $outputdir 

