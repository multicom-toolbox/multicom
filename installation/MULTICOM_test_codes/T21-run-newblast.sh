#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-newblast-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-newblast-$dtime/

mkdir newblast
perl /home/casp14/MULTICOM_TS/multicom/src/meta/newblast/script/newblast.pl /home/casp14/MULTICOM_TS/multicom/src/meta/newblast/newblast_option /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta newblast  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-newblast-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-newblast-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-newblast-$dtime/newblast/newblast1.pdb" ]];then 
	printf "!!!!! Failed to run newblast, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/newblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-newblast-$dtime/newblast/newblast1.pdb\n\n"
fi

