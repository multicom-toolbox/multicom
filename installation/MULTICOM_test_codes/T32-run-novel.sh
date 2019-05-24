#!/bin/bash

dtime=$(date +%Y-%b-%d)



source /data/jh7x3/multicom_github/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-novel-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-novel-$dtime/

mkdir novel
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/novel/script/tm_novel_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/novel/novel_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta novel  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-novel-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-novel-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-novel-$dtime/novel/novel1.pdb" ]];then 
	printf "!!!!! Failed to run novel, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-novel-$dtime/novel/novel1.pdb\n\n"
fi

