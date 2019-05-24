#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-unicon3d-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-unicon3d-$dtime/

mkdir unicon3d
perl /home/casp14/MULTICOM_TS/multicom/src/meta/unicon3d/script/tm_unicon3d_main.pl /home/casp14/MULTICOM_TS/multicom/src/meta/unicon3d/Unicon3D_option /home/casp14/MULTICOM_TS/multicom/examples/T0993s2.fasta unicon3d  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-unicon3d-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-unicon3d-$dtime.log>\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-unicon3d-$dtime/unicon3d/ss1.pdb" ]];then 
	printf "!!!!! Failed to run unicon3d, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/test_out/T0993s2-unicon3d-$dtime/unicon3d/ss1.pdb\n\n"
fi

