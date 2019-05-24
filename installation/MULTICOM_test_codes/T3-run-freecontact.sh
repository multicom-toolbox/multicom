#!/bin/bash

dtime=$(date +%Y-%b-%d)


export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/boost_1_55_0/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/OpenBLAS/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/jie_test/multicom/tools/DNCON2/freecontact-1.0.21/lib:$LD_LIBRARY_PATH

mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-freecontact-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-freecontact-$dtime/
/data/jh7x3/multicom_github/jie_test/multicom/tools/DNCON2/freecontact-1.0.21/bin/freecontact < /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.aln > /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-freecontact-$dtime/T0993s2.freecontact.rr

col_num=$(head -1 /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-freecontact-$dtime/T0993s2.freecontact.rr | tr ' ' '\n' | wc -l)

if [[ $col_num != 6 ]]
then 
	printf "\n!!!!! Failed to run freecontact, check the installation </data/jh7x3/multicom_github/jie_test/multicom/tools/DNCON2/freecontact-1.0.21/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-freecontact-$dtime/T0993s2.freecontact.rr\n\n"
fi
