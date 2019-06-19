#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_muster/
cd /home/jh7x3/multicom/test_out/T1006_muster/

mkdir muster

touch /home/jh7x3/multicom/test_out/T1006_muster.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_muster/muster/muster1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/muster/script/tm_muster_main.pl /home/jh7x3/multicom/src/meta/muster/muster_option_version4 /home/jh7x3/multicom/examples/T1006.fasta muster  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_muster.log
	perl /home/jh7x3/multicom/src/meta/muster/script/filter_identical_muster.pl muster   2>&1 | tee -a /home/jh7x3/multicom/test_out/T1006_muster.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_muster.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_muster/muster/muster1.pdb" ]];then 
	printf "!!!!! Failed to run muster, check the installation </home/jh7x3/multicom/src/meta/muster/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_muster/muster/muster1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_muster.running
