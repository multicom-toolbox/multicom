#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime/

perl /home/jh7x3/multicom/src/prosys/script/pir2ts_energy.pl /home/jh7x3/multicom/tools/modeller9v7/ /home/jh7x3/multicom/examples/ /home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime/ /home/jh7x3/multicom/examples/T0993s2.pir 5  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime/T0993s2.pdb" ]];then 
	printf "!!!!! Failed to run modeller9v7, check the installation </home/jh7x3/multicom/tools/modeller9v7/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_modeller9.7_$dtime/T0993s2.pdb\n\n"
fi

