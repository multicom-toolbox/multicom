#!/bin/sh
# Confold2 for protein tertiary structure prediction using contact#
if [ $# -lt 4 ]
then
	echo "need three parameters : target id, path of fasta sequence, directory of output"
	exit 1
fi

targetid=$1 #test
fasta=$2 #/home/casp13/confold2/confold-v2.0/example/test.fa
multicom_full_length_hard=$3
outputfolder=$4
contact_file=$5
ss_file=$6

source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate


if [ -z $contact_file ]; then contact_file='None'; else echo "Setting contact file to $contact_file" ; fi
if [ -z $ss_file ]; then ss_file='None'; else echo "Setting contact file to $ss_file" ; fi

echo "perl /home/jh7x3/multicom_beta1.0/src/meta/confoldtemp/script/run_confold2_template.pl $targetid   $fasta /home/jh7x3/multicom_beta1.0/src/meta/confoldtemp/script/CONFOLD_Template_option   $outputfolder   $contact_file  $ss_file\n"
perl /home/jh7x3/multicom_beta1.0/src/meta/confoldtemp/script/run_confold2_template.pl $targetid   $fasta /home/jh7x3/multicom_beta1.0/src/meta/confoldtemp/script/CONFOLD_Template_option $multicom_full_length_hard  $outputfolder   $contact_file   $ss_file

