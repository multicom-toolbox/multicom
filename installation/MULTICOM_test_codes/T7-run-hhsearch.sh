#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsearch-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsearch-$dtime/

mkdir hhsearch
perl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /home/casp14/MULTICOM_TS/multicom/src/meta/hhsearch/hhsearch_option_cluster /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta hhsearch  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsearch-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsearch-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsearch-$dtime/hh1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hhsearch/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-hhsearch-$dtime/hh1.pdb\n\n"
fi

