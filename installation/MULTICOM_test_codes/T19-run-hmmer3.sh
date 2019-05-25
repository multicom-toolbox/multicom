#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T0993s2_hmmer3_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_hmmer3_$dtime/

mkdir hmmer3
perl /home/jh7x3/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /home/jh7x3/multicom/src/meta/hmmer3/hmmer3_option /home/jh7x3/multicom/examples/T0993s2.fasta hmmer3  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_hmmer3_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_hmmer3_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_hmmer3_$dtime/hmmer3/jackhmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer3, check the installation </home/jh7x3/multicom/src/meta/hmmer3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_hmmer3_$dtime/hmmer3/jackhmmer1.pdb\n\n"
fi

