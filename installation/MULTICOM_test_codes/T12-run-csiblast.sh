#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csiblast-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csiblast-$dtime/

mkdir csiblast
perl /home/casp14/MULTICOM_TS/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /home/casp14/MULTICOM_TS/multicom/src/meta/csblast/csiblast_option /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta csiblast  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csiblast-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csiblast-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csiblast-$dtime/csiblast/csiblast1.pdb" ]];then 
	printf "!!!!! Failed to run csiblast, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/csblast/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-csiblast-$dtime/csiblast/csiblast1.pdb\n\n"
fi

