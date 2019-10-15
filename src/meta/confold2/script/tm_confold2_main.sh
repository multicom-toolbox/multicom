#!/bin/sh
if [ $# -ne 3 ]
then
        echo "need thre parameters: option file, input fasta file, output directory."
        exit 1
fi


/home/test/jie_test/multicom/src/meta/confold2/script/tm_confold2_main.pl $1 $2 $3

