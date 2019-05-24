#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite3-$dtime/
cd /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite3-$dtime/

mkdir hhsuite3
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite3/script/tm_hhsuite3_main.pl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite3/hhsuite3_option /home/casp14/MULTICOM_TS/jie_github/multicom/examples/T0993s2.fasta hhsuite3  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite3-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite3-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite3-$dtime/hhsuite3/hhsu1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite3, check the installation </home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite3-$dtime/hhsuite3/hhsu1.pdb\n\n"
fi

