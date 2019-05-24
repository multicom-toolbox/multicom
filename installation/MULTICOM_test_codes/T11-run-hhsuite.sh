#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite-$dtime/
cd /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite-$dtime/

mkdir hhsuite
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite/script/tm_hhsuite_main.pl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite/hhsuite_option /home/casp14/MULTICOM_TS/jie_github/multicom/examples/T0993s2.fasta hhsuite  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite-$dtime.log
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite/script/tm_hhsuite_main_simple.pl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite/super_option /home/casp14/MULTICOM_TS/jie_github/multicom/test/T0993s2.fasta hhsuite
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite/script/filter_identical_hhsuite.pl hhsuite

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite-$dtime/hhsuite/hhsuite1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite, check the installation </home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsuite/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-hhsuite-$dtime/hhsuite/hhsuite1.pdb\n\n"
fi

