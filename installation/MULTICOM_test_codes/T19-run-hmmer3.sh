#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hmmer3/
cd /home/jh7x3/multicom/test_out/T1006_hmmer3/

mkdir hmmer3
touch /home/jh7x3/multicom/test_out/T1006_hmmer3.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hmmer3/hmmer3/jackhmmer1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /home/jh7x3/multicom/src/meta/hmmer3/hmmer3_option /home/jh7x3/multicom/examples/T1006.fasta hmmer3  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hmmer3.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hmmer3.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hmmer3/hmmer3/jackhmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer3, check the installation </home/jh7x3/multicom/src/meta/hmmer3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hmmer3/hmmer3/jackhmmer1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_hmmer3.running
