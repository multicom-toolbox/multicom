#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhblits_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_hhblits_$dtime/

mkdir hhblits
perl /home/jh7x3/multicom/src/meta/hhblits/script/tm_hhblits_main.pl /home/jh7x3/multicom/src/meta/hhblits/hhblits_option /home/jh7x3/multicom/examples/T1006.fasta hhblits  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhblits_$dtime.log
perl /home/jh7x3/multicom/src/meta/hhblits/script/filter_identical_hhblits.pl hhblits

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhblits_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhblits_$dtime/hhblits/blits1.pdb" ]];then 
	printf "!!!!! Failed to run hhblits, check the installation </home/jh7x3/multicom/src/meta/hhblits/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhblits_$dtime/hhblits/blits1.pdb\n\n"
fi

