#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/
/data/jh7x3/multicom_github/jie_test/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/T0993s2 2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime.log

printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/T0993s2.ss" ]];then 
	printf "\n!!!!! Failed to run SCRATCH, check the installation </data/jh7x3/multicom_github/jie_test/multicom/tools/SCRATCH-1D_1.1/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-SCRATCH-$dtime/T0993s2.ss\n\n"
fi
