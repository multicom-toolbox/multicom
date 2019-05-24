#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer3-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer3-$dtime/

mkdir hmmer3
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hmmer3/hmmer3_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hmmer3  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer3-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer3-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer3-$dtime/hmmer3/jackhmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer3, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hmmer3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer3-$dtime/hmmer3/jackhmmer1.pdb\n\n"
fi
