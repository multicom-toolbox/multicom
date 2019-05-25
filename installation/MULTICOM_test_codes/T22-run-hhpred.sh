#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhpred-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhpred-$dtime/

mkdir hhpred
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhpred/script/tm_hhpred_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhpred/hhpred_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhpred  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhpred-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhpred-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhpred-$dtime/hhpred/hp1.pdb" ]];then 
	printf "!!!!! Failed to run hhpred, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhpred/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhpred-$dtime/hhpred/hp1.pdb\n\n"
fi

