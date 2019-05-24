#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hmmer-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hmmer-$dtime/

mkdir hmmer
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hmmer/hmmer_option /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta hmmer  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hmmer-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hmmer-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hmmer-$dtime/hmmer/hmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hmmer/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hmmer-$dtime/hmmer/hmmer1.pdb\n\n"
fi

