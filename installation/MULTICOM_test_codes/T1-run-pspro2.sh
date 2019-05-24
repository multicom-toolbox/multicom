#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime/
#/home/casp14/MULTICOM_TS/multicom/tools/pspro2/bin/predict_ss_sa_cm.sh /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime/ &> /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime.log
/home/casp14/MULTICOM_TS/multicom/tools/pspro2/bin/predict_ssa.sh /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime/  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime.log>..\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime/T0993s2_fasta.sspro" ]];then 
	printf "\n!!!!! Failed to run pspro2, check the installation </home/casp14/MULTICOM_TS/multicom/tools/pspro2/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-pspro-$dtime/T0993s2_fasta.sspro\n\n"
fi
