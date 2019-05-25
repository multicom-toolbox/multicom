#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_ffas_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_ffas_$dtime/

mkdir ffas
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/ffas/script/tm_ffas_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/ffas/ffas_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta ffas  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_ffas_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_ffas_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_ffas_$dtime/ffas/ff1.pdb" ]];then 
	printf "!!!!! Failed to run ffas, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/ffas/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_ffas_$dtime/ffas/ff1.pdb\n\n"
fi

