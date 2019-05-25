#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-compass-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-compass-$dtime/

mkdir compass
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/compass/script/tm_compass_main_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/compass/compass_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta compass  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-compass-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-compass-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-compass-$dtime/compass/com1.pdb" ]];then 
	printf "!!!!! Failed to run compass, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/compass/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-compass-$dtime/compass/com1.pdb\n\n"
fi

