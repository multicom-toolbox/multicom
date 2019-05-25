#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime/

perl /data/jh7x3/multicom_github/jie_test/multicom/src/prosys/script/pir2ts_energy.pl /data/jh7x3/multicom_github/jie_test/multicom/tools/modeller9v7/ /data/jh7x3/multicom_github/jie_test/multicom/examples/ /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime/ /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.pir 5  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime/T0993s2.pdb" ]];then 
	printf "!!!!! Failed to run modeller9v7, check the installation </data/jh7x3/multicom_github/jie_test/multicom/tools/modeller9v7/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_modeller9.7_$dtime/T0993s2.pdb\n\n"
fi

