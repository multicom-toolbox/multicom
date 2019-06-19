#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_ffas/
cd /home/jh7x3/multicom/test_out/T1006_ffas/

mkdir ffas

touch /home/jh7x3/multicom/test_out/T1006_ffas.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_ffas/ffas/ff1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/ffas/script/tm_ffas_main.pl /home/jh7x3/multicom/src/meta/ffas/ffas_option /home/jh7x3/multicom/examples/T1006.fasta ffas  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_ffas.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_ffas.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_ffas/ffas/ff1.pdb" ]];then 
	printf "!!!!! Failed to run ffas, check the installation </home/jh7x3/multicom/src/meta/ffas/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_ffas/ffas/ff1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_ffas.running
