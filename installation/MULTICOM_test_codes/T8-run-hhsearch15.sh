#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hhsearch15-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hhsearch15-$dtime/

mkdir hhsearch15
perl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hhsearch1.5/hhsearch1.5_option /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta hhsearch15  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hhsearch15-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hhsearch15-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hhsearch15-$dtime/hhsearch15/ss1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch15, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hhsearch15-$dtime/hhsearch15/ss1.pdb\n\n"
fi

