#!/bin/bash

dtime=$(date +%m%d%y)



source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom/test_out/T1006_novel_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_novel_$dtime/

mkdir novel

touch /home/jh7x3/multicom/test_out/T1006_novel_$dtime.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_novel_$dtime/novel/novel1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/novel/script/tm_novel_main.pl /home/jh7x3/multicom/src/meta/novel/novel_option /home/jh7x3/multicom/examples/T1006.fasta novel  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_novel_$dtime.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_novel_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_novel_$dtime/novel/novel1.pdb" ]];then 
	printf "!!!!! Failed to run novel, check the installation </home/jh7x3/multicom/src/meta/novel/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_novel_$dtime/novel/novel1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_novel_$dtime.running
