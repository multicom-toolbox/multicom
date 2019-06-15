#!/bin/bash

dtime=$(date +%m%d%y)

source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH


mkdir -p /home/jh7x3/multicom/test_out/T1006_rosettacon_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_rosettacon_$dtime/

mkdir rosettacon
perl /home/jh7x3/multicom/src/meta/rosettacon/script/tm_rosettacon_main.pl /home/jh7x3/multicom/src/meta/rosettacon/rosettacon_option /home/jh7x3/multicom/examples/T1006.fasta rosettacon  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_rosettacon_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_rosettacon_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_rosettacon_$dtime/rosettacon/rocon1.pdb" ]];then 
	printf "!!!!! Failed to run rosettacon, check the installation </home/jh7x3/multicom/src/meta/rosettacon/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_rosettacon_$dtime/rosettacon/rocon1.pdb\n\n"
fi

