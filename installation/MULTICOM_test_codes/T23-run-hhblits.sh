#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhblits-$dtime/
cd /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhblits-$dtime/

mkdir hhblits
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhblits/script/tm_hhblits_main.pl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhblits/hhblits_option /home/casp14/MULTICOM_TS/jie_github/multicom/examples/T0993s2.fasta hhblits  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhblits-$dtime.log
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhblits/script/filter_identical_hhblits.pl hhblits

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhblits-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhblits-$dtime/hhblits/blits1.pdb" ]];then 
	printf "!!!!! Failed to run hhblits, check the installation </home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhblits/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhblits-$dtime/hhblits/blits1.pdb\n\n"
fi

