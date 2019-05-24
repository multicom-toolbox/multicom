#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-muster-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-muster-$dtime/

mkdir muster
perl /home/casp14/MULTICOM_TS/multicom/src/meta/muster/script/tm_muster_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/muster/muster_option_version4 /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta muster  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-muster-$dtime.log
perl /home/casp14/MULTICOM_TS/multicom/src/meta/muster/script/filter_identical_muster.pl muster

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-muster-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-muster-$dtime/muster/muster1.pdb" ]];then 
	printf "!!!!! Failed to run muster, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/muster/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-muster-$dtime/muster/muster1.pdb\n\n"
fi

