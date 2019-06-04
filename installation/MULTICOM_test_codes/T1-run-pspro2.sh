#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime/
#/home/jh7x3/multicom/tools/pspro2/bin/predict_ss_sa_cm.sh /home/jh7x3/multicom/examples/T0993s2.fasta /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime/T0993s2.ssa &> /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime.log
/home/jh7x3/multicom/tools/pspro2/bin/predict_ssa.sh /home/jh7x3/multicom/examples/T0993s2.fasta /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime/T0993s2.ssa  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime.log>..\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime/T0993s2.ssa" ]];then 
	printf "\n!!!!! Failed to run pspro2, check the installation </home/jh7x3/multicom/tools/pspro2/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_pspro_$dtime/T0993s2_fasta.ssa\n\n"
fi
