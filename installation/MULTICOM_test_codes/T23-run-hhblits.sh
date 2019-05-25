#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits_$dtime/

mkdir hhblits
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits/script/tm_hhblits_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits/hhblits_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhblits  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits_$dtime.log
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits/script/filter_identical_hhblits.pl hhblits

printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits_$dtime/hhblits/blits1.pdb" ]];then 
	printf "!!!!! Failed to run hhblits, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits_$dtime/hhblits/blits1.pdb\n\n"
fi

