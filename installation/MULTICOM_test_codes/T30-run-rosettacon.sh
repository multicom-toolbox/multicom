#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/

mkdir rosettacon
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/rosettacon/script/tm_rosettacon_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/rosettacon/rosettacon_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta rosettacon  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/rosettacon/rocon1.pdb" ]];then 
	printf "!!!!! Failed to run rosettacon, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/rosettacon/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/rosettacon/rocon1.pdb\n\n"
fi

