#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard/

mkdir hmmer
touch /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard/hmmer/hmmer1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/hmmer/script/tm_hmmer_main_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/hmmer/hmmer_option_hard /home/jh7x3/multicom_beta1.0/examples/T1006.fasta hmmer  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard/hmmer/hmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hmmer/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard/hmmer/hmmer1.pdb\n\n"
fi
rm /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer_hard.running
