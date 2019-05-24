#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosettacon-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosettacon-$dtime/

mkdir rosettacon
perl /home/casp14/MULTICOM_TS/multicom/src/meta/rosettacon/script/tm_rosettacon_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/rosettacon/rosettacon_option /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta rosettacon  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosettacon-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosettacon-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosettacon-$dtime/rosettacon/rocon1.pdb" ]];then 
	printf "!!!!! Failed to run rosettacon, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/rosettacon/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosettacon-$dtime/rosettacon/rocon1.pdb\n\n"
fi

