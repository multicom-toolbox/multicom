#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime/
#/data/jh7x3/multicom_github/jie_test/multicom/tools/pspro2/bin/predict_ss_sa_cm.sh /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime/ &> /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime.log
/data/jh7x3/multicom_github/jie_test/multicom/tools/pspro2/bin/predict_ssa.sh /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime/  2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime.log>..\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime/T0993s2_fasta.sspro" ]];then 
	printf "\n!!!!! Failed to run pspro2, check the installation </data/jh7x3/multicom_github/jie_test/multicom/tools/pspro2/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2_pspro_$dtime/T0993s2_fasta.sspro\n\n"
fi
