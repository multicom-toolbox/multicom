#!/bin/sh
# Run Rosetta with contact information #
if [ $# -lt 3 ]
then
	echo "need at least three parameters : target id, path of fasta sequence, directory of output, contact file (optional)"
	exit 1
fi

targetid=$1 #T0898
fasta=$2 #/home/casp13/Human_QA_package/Jie_dev_casp13/data/casp12_original_seq/T0898.fasta
dir_output=$3 #/home/casp13/Human_QA_package/HQA_cp12new//T0898/T0898
contact_file=$4 #/home/casp13/Human_QA_package/HQA_cp12new//T0898
fragmentdir=$5 #/home/casp13/Human_QA_package/HQA_cp12new//T0898



source /home/casp13/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp13/tools/rosetta_bin_linux_2018.09.60072_bundle/main/source/build/src/release/linux/3.10/64/x86/gcc/4.8/static/:$LD_LIBRARY_PATH

perl /home/casp13/dncon2-Rosetta/scripts/run_CASP13_rosetta_withcontact_mediumL.pl $targetid   $fasta  $dir_output  $contact_file $fragmentdir
