#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-psiblast-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-psiblast-$dtime/

mkdir psiblast
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/psiblast/script/main_psiblast_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/psiblast/cm_option_adv /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta psiblast  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-psiblast-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-psiblast-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-psiblast-$dtime/psiblast/psiblast1.pdb" ]];then 
	printf "!!!!! Failed to run psiblast, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/psiblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-psiblast-$dtime/psiblast/psiblast1.pdb\n\n"
fi

