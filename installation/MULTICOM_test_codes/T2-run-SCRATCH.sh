#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_SCRATCH/
cd /home/jh7x3/multicom/test_out/T1006_SCRATCH/

touch /home/jh7x3/multicom/test_out/T1006_SCRATCH.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_SCRATCH/T1006.ss" ]];then 
	/home/jh7x3/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /home/jh7x3/multicom/examples/T1006.fasta  /home/jh7x3/multicom/test_out/T1006_SCRATCH/T1006 2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_SCRATCH.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_SCRATCH.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_SCRATCH/T1006.ss" ]];then 
	printf "\n!!!!! Failed to run SCRATCH, check the installation </home/jh7x3/multicom/tools/SCRATCH-1D_1.1/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_SCRATCH/T1006.ss\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_SCRATCH.running
