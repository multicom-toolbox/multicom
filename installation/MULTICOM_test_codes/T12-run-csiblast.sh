#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-csiblast-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-csiblast-$dtime/

mkdir csiblast
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/csblast/csiblast_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta csiblast  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-csiblast-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-csiblast-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-csiblast-$dtime/csiblast/csiblast1.pdb" ]];then 
	printf "!!!!! Failed to run csiblast, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/csblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-csiblast-$dtime/csiblast/csiblast1.pdb\n\n"
fi

