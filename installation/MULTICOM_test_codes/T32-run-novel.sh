#!/bin/bash

dtime=$(date +%Y-%b-%d)



source /home/casp14/MULTICOM_TS/jie_github/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/jie_github/multicom/tools/boost_1_55_0/lib/:/home/casp14/MULTICOM_TS/jie_github/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-novel-$dtime/
cd /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-novel-$dtime/

mkdir novel
perl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/novel/script/tm_novel_main.pl /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/novel/novel_option /home/casp14/MULTICOM_TS/jie_github/multicom/examples/T0993s2.fasta novel  2>&1 | tee  /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-novel-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-novel-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-novel-$dtime/novel/novel1.pdb" ]];then 
	printf "!!!!! Failed to run novel, check the installation </home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/jie_github/multicom/test_out/T0993s2-novel-$dtime/novel/novel1.pdb\n\n"
fi

