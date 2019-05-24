#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csblast-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csblast-$dtime/

mkdir csblast
perl /home/casp14/MULTICOM_TS/multicom/src/meta/csblast/script/multicom_csblast_v2.pl /home/casp14/MULTICOM_TS/multicom/src/meta/csblast/csblast_option /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta csblast  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csblast-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csblast-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csblast-$dtime/csblast/csblast1.pdb" ]];then 
	printf "!!!!! Failed to run csblast, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/csblast/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csblast-$dtime/csblast/csblast1.pdb\n\n"
fi

