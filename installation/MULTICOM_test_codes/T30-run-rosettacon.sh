#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/

mkdir rosettacon
perl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/rosettacon/script/tm_rosettacon_main.pl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/rosettacon/rosettacon_option /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta rosettacon  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/rosettacon/rocon1.pdb" ]];then 
	printf "!!!!! Failed to run rosettacon, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/rosettacon/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-rosettacon-$dtime/rosettacon/rocon1.pdb\n\n"
fi

