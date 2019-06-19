#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime/

mkdir hhsearch151

touch /home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime/hhsearch151/hg1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /home/jh7x3/multicom/src/meta/hhsearch151/hhsearch151_option /home/jh7x3/multicom/examples/T1006.fasta hhsearch151  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime/hhsearch151/hg1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch151, check the installation </home/jh7x3/multicom/src/meta/hhsearch151/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime/hhsearch151/hg1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_hhsearch151_$dtime.running
