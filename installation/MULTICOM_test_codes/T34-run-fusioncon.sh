#!/bin/bash

dtime=$(date +%m%d%y)



source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom/test_out/T0993s2_fusioncon_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_fusioncon_$dtime/

mkdir fusioncon
perl /home/jh7x3/multicom/src/meta/fusioncon/script/tm_fusioncon_main.pl /home/jh7x3/multicom/src/meta/fusioncon/fusioncon_option /home/jh7x3/multicom/examples/T0993s2.fasta fusioncon  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_fusioncon_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_fusioncon_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_fusioncon_$dtime/fusioncon/fusicon1.pdb" ]];then 
	printf "!!!!! Failed to run fusioncon, check the installation </home/jh7x3/multicom/src/meta/fusioncon/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_fusioncon_$dtime/fusioncon/fusicon1.pdb\n\n"
fi

