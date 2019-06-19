#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime/

mkdir hhpred

touch /home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime/hhpred/hp1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhpred/script/tm_hhpred_main.pl /home/jh7x3/multicom/src/meta/hhpred/hhpred_option_hard /home/jh7x3/multicom/examples/T1006.fasta hhpred  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime/hhpred/hp1.pdb" ]];then 
	printf "!!!!! Failed to run hhpred, check the installation </home/jh7x3/multicom/src/meta/hhpred/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime/hhpred/hp1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_hhpred_hard_$dtime.running
