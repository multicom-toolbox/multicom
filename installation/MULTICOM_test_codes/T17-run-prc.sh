#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-prc-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-prc-$dtime/

mkdir prc
perl /home/casp14/MULTICOM_TS/multicom/src/meta/prc/script/tm_prc_main_v2.pl /home/casp14/MULTICOM_TS/multicom/src/meta/prc/prc_option /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta prc  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-prc-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-prc-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-prc-$dtime/prc/prc1.pdb" ]];then 
	printf "!!!!! Failed to run prc, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/prc/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-prc-$dtime/prc/prc1.pdb\n\n"
fi

