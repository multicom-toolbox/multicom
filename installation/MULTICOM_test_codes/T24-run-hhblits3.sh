#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhblits3-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhblits3-$dtime/

mkdir hhblits3
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhblits3/script/tm_hhblits3_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hhblits3/hhblits3_option /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta hhblits3  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhblits3-$dtime.log
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhblits3/script/filter_identical_hhblits.pl hhblits3

printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhblits3-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhblits3-$dtime/hhblits3/hhbl1.pdb" ]];then 
	printf "!!!!! Failed to run hhblits3, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hhblits3/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhblits3-$dtime/hhblits3/hhbl1.pdb\n\n"
fi

