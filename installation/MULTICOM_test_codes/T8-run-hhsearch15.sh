#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhsearch15_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhsearch15_$dtime/

mkdir hhsearch15
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch1.5/hhsearch1.5_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhsearch15  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhsearch15_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhsearch15_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhsearch15_$dtime/hhsearch15/ss1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch15, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_hhsearch15_$dtime/hhsearch15/ss1.pdb\n\n"
fi

