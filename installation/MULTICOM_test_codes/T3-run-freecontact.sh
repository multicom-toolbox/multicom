#!/bin/bash

dtime=$(date +%Y-%b-%d)


export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-freecontact-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-freecontact-$dtime/
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/freecontact-1.0.21/bin/freecontact < /home/casp14/MULTICOM_TS/multicom/examples/T0967.aln > /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-freecontact-$dtime/T0967.freecontact.rr

col_num=$(head -1 /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-freecontact-$dtime/T0967.freecontact.rr | tr ' ' '\n' | wc -l)

if [[ $col_num != 6 ]]
then 
	printf "\n!!!!! Failed to run freecontact, check the installation </home/casp14/MULTICOM_TS/multicom/tools/DNCON2/freecontact-1.0.21/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-freecontact-$dtime/T0967.freecontact.rr\n\n"
fi
