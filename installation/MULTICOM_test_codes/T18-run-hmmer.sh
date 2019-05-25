#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T0993s2_hmmer_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_hmmer_$dtime/

mkdir hmmer
perl /home/jh7x3/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /home/jh7x3/multicom/src/meta/hmmer/hmmer_option /home/jh7x3/multicom/examples/T0993s2.fasta hmmer  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_hmmer_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_hmmer_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_hmmer_$dtime/hmmer/hmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer, check the installation </home/jh7x3/multicom/src/meta/hmmer/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_hmmer_$dtime/hmmer/hmmer1.pdb\n\n"
fi

