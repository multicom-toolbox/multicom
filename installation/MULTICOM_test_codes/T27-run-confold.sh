#!/bin/bash

dtime=$(date +%m%d%y)


source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom/test_out/T1006_confold/
cd /home/jh7x3/multicom/test_out/T1006_confold/

mkdir confold

touch /home/jh7x3/multicom/test_out/T1006_confold.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_confold/confold/confold2-1.pdb" ]];then 
	sh /home/jh7x3/multicom/src/meta/confold2/script/tm_confold2_main.sh /home/jh7x3/multicom/src/meta/confold2/CONFOLD_option /home/jh7x3/multicom/examples/T1006.fasta confold  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_confold.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_confold.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_confold/confold/confold2-1.pdb" ]];then 
	printf "!!!!! Failed to run confold, check the installation </home/jh7x3/multicom/src/meta/confold2/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_confold/confold/confold2-1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_confold.running
