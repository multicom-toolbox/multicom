#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/

mkdir raptorx
perl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/raptorx/script/tm_raptorx_main.pl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/raptorx/raptorx_option_version3 /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta hhsearch15  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-raptorx-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-raptorx-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/raptorx/rap1.pdb" ]];then 
	printf "!!!!! Failed to run raptorx, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/raptorx/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-raptorx-$dtime/raptorx/rap1.pdb\n\n"
fi

