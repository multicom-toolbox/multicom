#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_blast_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_blast_$dtime/

mkdir blast
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/blast/script/main_blast_v2.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/blast/cm_option_adv /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta blast  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_blast_$dtime.log
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta blast


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_blast_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_blast_$dtime/blast/hs1.pdb" ]];then 
	printf "!!!!! Failed to run blast, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/blast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_blast_$dtime/blast/hs1.pdb\n\n"
fi

