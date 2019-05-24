#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch151-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch151-$dtime/

mkdir hhsearch151
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch151/hhsearch151_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhsearch151  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch151-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch151-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch151-$dtime/hhsearch151/hg1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch151, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch151/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch151-$dtime/hhsearch151/hg1.pdb\n\n"
fi

