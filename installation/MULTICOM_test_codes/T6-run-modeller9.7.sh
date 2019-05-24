#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime/

perl /home/casp14/MULTICOM_TS/multicom/src/prosys/script/pir2ts_energy.pl /home/casp14/MULTICOM_TS/multicom/tools/modeller9v7/ /home/casp14/MULTICOM_TS/multicom/examples/ /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime/ /home/casp14/MULTICOM_TS/multicom/examples/T0967.pir 5  2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime/T0967.pdb" ]];then 
	printf "!!!!! Failed to run modeller9v7, check the installation </home/casp14/MULTICOM_TS/multicom/tools/modeller9v7/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-modeller9.7-$dtime/T0967.pdb\n\n"
fi

