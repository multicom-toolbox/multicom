#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/
cd /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/

mkdir hmmer
perl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hmmer/hmmer_option /home/casp14/MULTICOM_TS/jie_test/multicom/examples/T0993s2.fasta hmmer  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hmmer-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hmmer-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/hmmer/hmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer, check the installation </home/casp14/MULTICOM_TS/jie_test/multicom/src/meta/hmmer/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_test/multicom/test_out/T0993s2-hmmer-$dtime/hmmer/hmmer1.pdb\n\n"
fi

