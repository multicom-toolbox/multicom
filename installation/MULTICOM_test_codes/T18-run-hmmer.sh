#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/

mkdir hmmer
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hmmer/hmmer_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hmmer  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/hmmer/hmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hmmer/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/hmmer/hmmer1.pdb\n\n"
fi

