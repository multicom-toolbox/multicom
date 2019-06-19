#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_pspro_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_pspro_$dtime/


touch /home/jh7x3/multicom/test_out/T1006_pspro_$dtime.running

if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_pspro_$dtime/T1006.ssa" ]];then 
	/home/jh7x3/multicom/tools/pspro2/bin/predict_ssa.sh /home/jh7x3/multicom/examples/T1006.fasta /home/jh7x3/multicom/test_out/T1006_pspro_$dtime/T1006.ssa  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_pspro_$dtime.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_pspro_$dtime.log>..\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_pspro_$dtime/T1006.ssa" ]];then 
	printf "\n!!!!! Failed to run pspro2, check the installation </home/jh7x3/multicom/tools/pspro2/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_pspro_$dtime/T1006_fasta.ssa\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_pspro_$dtime.running
