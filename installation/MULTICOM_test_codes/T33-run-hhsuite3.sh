#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime/

mkdir hhsuite3

touch /home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime.log
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime/hhsuite3/hhsu1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhsuite3/script/tm_hhsuite3_main.pl /home/jh7x3/multicom/src/meta/hhsuite3/hhsuite3_option /home/jh7x3/multicom/examples/T1006.fasta hhsuite3  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime/hhsuite3/hhsu1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite3, check the installation </home/jh7x3/multicom/src/meta/hhsuite3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime/hhsuite3/hhsu1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_hhsuite3_$dtime.log
