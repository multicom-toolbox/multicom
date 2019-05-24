#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsuite-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsuite-$dtime/

mkdir hhsuite
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsuite/script/tm_hhsuite_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsuite/hhsuite_option /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta hhsuite  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsuite-$dtime.log
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsuite/script/tm_hhsuite_main_simple.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsuite/super_option /home/casp14/MULTICOM_TS/multicom/test/T0967.fasta hhsuite
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsuite/script/filter_identical_hhsuite.pl hhsuite

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsuite-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsuite-$dtime/hhsuite/hhsuite1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hhsuite/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsuite-$dtime/hhsuite/hhsuite1.pdb\n\n"
fi

