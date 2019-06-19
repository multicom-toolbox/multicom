#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_csiblast/
cd /home/jh7x3/multicom/test_out/T1006_csiblast/

mkdir csiblast
touch /home/jh7x3/multicom/test_out/T1006_csiblast.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_csiblast/csiblast/csiblast1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /home/jh7x3/multicom/src/meta/csblast/csiblast_option /home/jh7x3/multicom/examples/T1006.fasta csiblast  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_csiblast.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_csiblast.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_csiblast/csiblast/csiblast1.pdb" ]];then 
	printf "!!!!! Failed to run csiblast, check the installation </home/jh7x3/multicom/src/meta/csblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_csiblast/csiblast/csiblast1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_csiblast.running
