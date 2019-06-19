#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhsuite/
cd /home/jh7x3/multicom/test_out/T1006_hhsuite/

mkdir hhsuite

touch /home/jh7x3/multicom/test_out/T1006_hhsuite.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsuite/hhsuite/hhsuite1.pdb" ]];then
	perl /home/jh7x3/multicom/src/meta/hhsuite/script/tm_hhsuite_main.pl /home/jh7x3/multicom/src/meta/hhsuite/hhsuite_option /home/jh7x3/multicom/examples/T1006.fasta hhsuite  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhsuite.log
	perl /home/jh7x3/multicom/src/meta/hhsuite/script/tm_hhsuite_main_simple.pl /home/jh7x3/multicom/src/meta/hhsuite/super_option /home/jh7x3/multicom/test/T1006.fasta hhsuite
	perl /home/jh7x3/multicom/src/meta/hhsuite/script/filter_identical_hhsuite.pl hhsuite
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhsuite.log>\n\n"

if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsuite/hhsuite/hhsuite1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite, check the installation </home/jh7x3/multicom/src/meta/hhsuite/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhsuite/hhsuite/hhsuite1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_hhsuite.running

