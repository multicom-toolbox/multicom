#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-confold-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-confold-$dtime/

mkdir confold
sh /data/jh7x3/multicom_github/jie_test/multicom/src/meta/confold2/script/tm_confold2_main.sh /data/jh7x3/multicom_github/jie_test/multicom/src/meta/confold2/CONFOLD_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta confold  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-confold-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-confold-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-confold-$dtime/confold/confold2-1.pdb" ]];then 
	printf "!!!!! Failed to run confold, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/confold2/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-confold-$dtime/confold/confold2-1.pdb\n\n"
fi

