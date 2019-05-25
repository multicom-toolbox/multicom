#!/bin/bash

dtime=$(date +%m%d%y)


source /data/jh7x3/multicom_github/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime/
/data/jh7x3/multicom_github/jie_test/multicom/tools/DNCON2/dncon2-v1.0.sh /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime/  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime/T0993s2.dncon2.rr" ]];then 
	printf "!!!!! Failed to run DNCON2, check the installation </data/jh7x3/multicom_github/jie_test/multicom/tools/DNCON2/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_dncon2_$dtime/T0993s2.dncon2.rr\n\n"
fi

