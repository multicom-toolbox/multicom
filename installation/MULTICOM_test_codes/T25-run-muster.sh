#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-muster-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-muster-$dtime/

mkdir muster
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/muster/script/tm_muster_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/muster/muster_option_version4 /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta muster  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-muster-$dtime.log
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/muster/script/filter_identical_muster.pl muster

printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-muster-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-muster-$dtime/muster/muster1.pdb" ]];then 
	printf "!!!!! Failed to run muster, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/muster/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-muster-$dtime/muster/muster1.pdb\n\n"
fi

