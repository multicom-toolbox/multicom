#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime/
/home/jh7x3/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /home/jh7x3/multicom/examples/T0993s2.fasta  /home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime/T0993s2 2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime.log

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime/T0993s2.ss" ]];then 
	printf "\n!!!!! Failed to run SCRATCH, check the installation </home/jh7x3/multicom/tools/SCRATCH-1D_1.1/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_SCRATCH_$dtime/T0993s2.ss\n\n"
fi
