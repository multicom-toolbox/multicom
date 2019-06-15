#!/bin/bash

mkdir -p /home/jh7x3/multicom/test_out/T1006_multicom/
cd /home/jh7x3/multicom/test_out/T1006_multicom/

source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

/home/jh7x3/multicom/src/multicom_ve.pl /home/jh7x3/multicom/src/multicom_system_option_casp13 /home/jh7x3/multicom/examples/T1006.fasta  /home/jh7x3/multicom/test_out/T1006_multicom/   2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_multicom.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_multicom.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_multicom/mcomb/casp1.pdb" ]];then 
	printf "!!!!! Failed to run multicom, check the installation </home/jh7x3/multicom/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_multicom/mcomb/casp1.pdb\n\n"
fi

