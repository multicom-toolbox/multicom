#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hhpred-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hhpred-$dtime/

mkdir hhpred
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhpred/script/tm_hhpred_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hhpred/hhpred_option /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta hhpred  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hhpred-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hhpred-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hhpred-$dtime/hhpred/hp1.pdb" ]];then 
	printf "!!!!! Failed to run hhpred, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hhpred/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-hhpred-$dtime/hhpred/hp1.pdb\n\n"
fi

