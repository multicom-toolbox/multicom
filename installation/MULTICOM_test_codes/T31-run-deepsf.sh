#!/bin/bash

dtime=$(date +%Y-%b-%d)



source /data/jh7x3/multicom_github/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-deepsf-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-deepsf-$dtime/

mkdir deepsf
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/deepsf/script/tm_deepsf_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/deepsf/deepsf_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta deepsf  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-deepsf-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-deepsf-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-deepsf-$dtime/deepsf/deepsf1.pdb" ]];then 
	printf "!!!!! Failed to run deepsf, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-deepsf-$dtime/deepsf/deepsf1.pdb\n\n"
fi

