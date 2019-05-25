#!/bin/bash

dtime=$(date +%m%d%y)



source /data/jh7x3/multicom_github/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_deepsf_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_deepsf_$dtime/

mkdir deepsf
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/deepsf/script/tm_deepsf_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/deepsf/deepsf_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta deepsf  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_deepsf_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_deepsf_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_deepsf_$dtime/deepsf/deepsf1.pdb" ]];then 
	printf "!!!!! Failed to run deepsf, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/deepsf/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_deepsf_$dtime/deepsf/deepsf1.pdb\n\n"
fi

