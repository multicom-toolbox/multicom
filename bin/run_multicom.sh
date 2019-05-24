#!/bin/sh
if [ $# -ne 2 ]
then
        echo "need two parameters: input fasta file, output directory."
        exit 1
fi

fastafile=$1
outputdir=$2

source /home/casp14/MULTICOM_TS/jie_github/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/jie_github/multicom/tools/boost_1_55_0/lib/:/home/casp14/MULTICOM_TS/jie_github/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [ ! -d "$outputdir" ]; then
  mkdir -p $outputdir
fi

/home/casp14/MULTICOM_TS/jie_github/multicom/src/multicom_ve.pl /home/casp14/MULTICOM_TS/jie_github/multicom/src/multicom_system_option_casp13 $fastafile $outputdir 

