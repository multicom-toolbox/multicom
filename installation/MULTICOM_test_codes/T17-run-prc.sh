#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_prc/
cd /home/jh7x3/multicom/test_out/T1006_prc/

mkdir prc

touch /home/jh7x3/multicom/test_out/T1006_prc.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_prc/prc/prc1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/prc/script/tm_prc_main_v2.pl /home/jh7x3/multicom/src/meta/prc/prc_option /home/jh7x3/multicom/examples/T1006.fasta prc  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_prc.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_prc.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_prc/prc/prc1.pdb" ]];then 
	printf "!!!!! Failed to run prc, check the installation </home/jh7x3/multicom/src/meta/prc/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_prc/prc/prc1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_prc.running
