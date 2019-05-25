#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch-$dtime/

mkdir hhsearch
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch/hhsearch_option_cluster /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhsearch  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch-$dtime/hhsearch/hh1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsearch-$dtime/hhsearch/hh1.pdb\n\n"
fi

