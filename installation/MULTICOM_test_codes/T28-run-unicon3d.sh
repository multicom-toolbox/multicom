#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-unicon3d-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-unicon3d-$dtime/

mkdir unicon3d
perl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/unicon3d/script/tm_unicon3d_main.pl /data/jh7x3/multicom_github/jie_test/multicom/src/meta/unicon3d/Unicon3D_option /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta unicon3d  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-unicon3d-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-unicon3d-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-unicon3d-$dtime/unicon3d/ss1.pdb" ]];then 
	printf "!!!!! Failed to run unicon3d, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-unicon3d-$dtime/unicon3d/ss1.pdb\n\n"
fi

