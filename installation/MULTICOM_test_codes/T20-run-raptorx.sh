#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/

mkdir raptorx
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/raptorx/script/tm_raptorx_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/raptorx/raptorx_option_version3 /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta raptorx  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-raptorx-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-raptorx-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/raptorx/rap1.pdb" ]];then 
	printf "!!!!! Failed to run raptorx, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/raptorx/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/raptorx/rap1.pdb\n\n"
fi

