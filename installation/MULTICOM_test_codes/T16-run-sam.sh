#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-sam-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-sam-$dtime/

mkdir sam
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/sam/script/tm_sam_main_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/sam/sam_option_nr /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta sam  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-sam-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-sam-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-sam-$dtime/sam/sam1.pdb" ]];then 
	printf "!!!!! Failed to run sam, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/sam/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-sam-$dtime/sam/sam1.pdb\n\n"
fi

