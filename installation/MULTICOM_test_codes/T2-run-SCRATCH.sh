#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime/
/home/casp14/MULTICOM_TS/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime/T0967 2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime.log

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime.log>..\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime/T0967.ss" ]];then 
	printf "\n!!!!! Failed to run SCRATCH, check the installation </home/casp14/MULTICOM_TS/multicom/tools/SCRATCH-1D_1.1/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-SCRATCH-$dtime/T0967.ss\n\n"
fi
