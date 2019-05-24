#!/bin/sh
if [ $# -ne 2 ]
then
        echo "need two parameters: input fasta file, output directory."
        exit 1
fi

$GLOBAL_PATH="/home/casp14/MULTICOM_TS/jie_test/multicom/";

$GLOBAL_PATH/src/multicom_ve.pl $GLOBAL_PATH/src/multicom_system_option_casp13 $1 $2 

