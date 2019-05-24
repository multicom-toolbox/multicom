#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hmmer3-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hmmer3-$dtime/

mkdir hmmer3
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hmmer3/hmmer3_option /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta hmmer3  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hmmer3-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hmmer3-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hmmer3-$dtime/hmmer3/jackhmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer3, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hmmer3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hmmer3-$dtime/hmmer3/jackhmmer1.pdb\n\n"
fi

