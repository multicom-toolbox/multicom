#!/bin/sh
if [ $# -ne 3 ]
then
        echo "need thre parameters: option file, input fasta file, output directory."
        exit 1
fi

source /home/casp13/python_virtualenv/bin/activate

python -c "import keras"


/home/casp13/MULTICOM_package/casp8/confold2/script/tm_confold2_main.pl $1 $2 $3

