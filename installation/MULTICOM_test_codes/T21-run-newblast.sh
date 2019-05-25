#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_newblast_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_newblast_$dtime/

mkdir newblast
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/newblast/script/newblast.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/newblast/newblast_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta newblast  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_newblast_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_newblast_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_newblast_$dtime/newblast/newblast1.pdb" ]];then 
	printf "!!!!! Failed to run newblast, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/newblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_newblast_$dtime/newblast/newblast1.pdb\n\n"
fi

