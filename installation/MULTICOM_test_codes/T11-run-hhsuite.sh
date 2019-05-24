#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsuite-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsuite-$dtime/

mkdir hhsuite
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsuite/script/tm_hhsuite_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsuite/hhsuite_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta hhsuite  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsuite-$dtime.log
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsuite/script/tm_hhsuite_main_simple.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsuite/super_option /data/jh7x3/multicom_github/jie_test/multicom/test/T0993s2.fasta hhsuite
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsuite/script/filter_identical_hhsuite.pl hhsuite

printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsuite-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsuite-$dtime/hhsuite/hhsuite1.pdb" ]];then 
	printf "!!!!! Failed to run hhsuite, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsuite/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-hhsuite-$dtime/hhsuite/hhsuite1.pdb\n\n"
fi

