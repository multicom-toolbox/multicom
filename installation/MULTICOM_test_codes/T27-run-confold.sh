#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-confold-$dtime/
cd /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-confold-$dtime/

mkdir confold
sh /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/confold2/script/tm_confold2_main.sh /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/confold2/CONFOLD_option /home/casp14/MULTICOM_TS/jie_github/multicom/examples/T0993s2.fasta confold  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-confold-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-confold-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-confold-$dtime/confold/confold2-1.pdb" ]];then 
	printf "!!!!! Failed to run confold, check the installation </home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/confold2/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-confold-$dtime/confold/confold2-1.pdb\n\n"
fi

