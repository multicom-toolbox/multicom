#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime/


touch /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime/T1006.pdb" ]];then 
	perl /home/jh7x3/multicom/src/prosys/script/pir2ts_energy.pl /home/jh7x3/multicom/tools/modeller-9.16/ /home/jh7x3/multicom/examples/ /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime/ /home/jh7x3/multicom/examples/T1006.pir 5  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime/T1006.pdb" ]];then 
	printf "!!!!! Failed to run modeller-9.16, check the installation </home/jh7x3/multicom/tools/modeller-9.16/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime/T1006.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_modeller9.16_$dtime.running
