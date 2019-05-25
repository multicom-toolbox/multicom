#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T0993s2_sam_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_sam_$dtime/

mkdir sam
perl /home/jh7x3/multicom/src/meta/sam/script/tm_sam_main_v2.pl /home/jh7x3/multicom/src/meta/sam/sam_option_nr /home/jh7x3/multicom/examples/T0993s2.fasta sam  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_sam_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_sam_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_sam_$dtime/sam/sam1.pdb" ]];then 
	printf "!!!!! Failed to run sam, check the installation </home/jh7x3/multicom/src/meta/sam/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_sam_$dtime/sam/sam1.pdb\n\n"
fi

