#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/
/home/casp14/MULTICOM_TS/jie_test/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/T0993s2 2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime.log

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/T0993s2.ss" ]];then 
	printf "\n!!!!! Failed to run SCRATCH, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/tools/SCRATCH-1D_1.1/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/T0993s2.ss\n\n"
fi
