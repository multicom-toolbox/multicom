#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-sam-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-sam-$dtime/

mkdir sam
perl /home/casp14/MULTICOM_TS/multicom/src/meta/sam/script/tm_sam_main_v2.pl /home/casp14/MULTICOM_TS/multicom/src/meta/sam/sam_option_nr /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta sam  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-sam-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-sam-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-sam-$dtime/sam/sam1.pdb" ]];then 
	printf "!!!!! Failed to run sam, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/sam/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-sam-$dtime/sam/sam1.pdb\n\n"
fi

