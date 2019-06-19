#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhblits/
cd /home/jh7x3/multicom/test_out/T1006_hhblits/

mkdir hhblits

touch  /home/jh7x3/multicom/test_out/T1006_hhblits.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhblits/hhblits/blits1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhblits/script/tm_hhblits_main.pl /home/jh7x3/multicom/src/meta/hhblits/hhblits_option /home/jh7x3/multicom/examples/T1006.fasta hhblits  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhblits.log
	perl /home/jh7x3/multicom/src/meta/hhblits/script/filter_identical_hhblits.pl hhblits  2>&1 | tee -a /home/jh7x3/multicom/test_out/T1006_hhblits.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhblits.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhblits/hhblits/blits1.pdb" ]];then 
	printf "!!!!! Failed to run hhblits, check the installation </home/jh7x3/multicom/src/meta/hhblits/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhblits/hhblits/blits1.pdb\n\n"
fi

rm  /home/jh7x3/multicom/test_out/T1006_hhblits.running
