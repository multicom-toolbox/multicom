#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-prc-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-prc-$dtime/

mkdir prc
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/prc/script/tm_prc_main_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/prc/prc_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta prc  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-prc-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-prc-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-prc-$dtime/prc/prc1.pdb" ]];then 
	printf "!!!!! Failed to run prc, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/prc/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-prc-$dtime/prc/prc1.pdb\n\n"
fi

