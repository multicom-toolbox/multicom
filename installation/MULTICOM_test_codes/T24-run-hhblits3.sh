#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits3_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits3_$dtime/

mkdir hhblits3
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits3/script/tm_hhblits3_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits3/hhblits3_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhblits3  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits3_$dtime.log
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits3/script/filter_identical_hhblits.pl hhblits3

printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits3_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits3_$dtime/hhblits3/hhbl2.pdb" ]];then 
	printf "!!!!! Failed to run hhblits3, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhblits3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhblits3_$dtime/hhblits3/hhbl2.pdb\n\n"
fi

