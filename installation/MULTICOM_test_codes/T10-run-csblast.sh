#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_csblast_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_csblast_$dtime/

mkdir csblast
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/csblast/script/multicom_csblast_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/csblast/csblast_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta csblast  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_csblast_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_csblast_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_csblast_$dtime/csblast/csblast1.pdb" ]];then 
	printf "!!!!! Failed to run csblast, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/csblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_csblast_$dtime/csblast/csblast1.pdb\n\n"
fi

