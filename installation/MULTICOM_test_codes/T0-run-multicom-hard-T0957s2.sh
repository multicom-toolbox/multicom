#!/bin/bash

mkdir -p /home/jh7x3/multicom/test_out/T0957s2_multicom/
cd /home/jh7x3/multicom/test_out/T0957s2_multicom/

source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

/home/jh7x3/multicom/src/multicom_ve.pl /home/jh7x3/multicom/src/multicom_system_option_casp13 /home/jh7x3/multicom/examples/T0957s2.fasta  /home/jh7x3/multicom/test_out/T0957s2_multicom/   2>&1 | tee  /home/jh7x3/multicom/test_out/T0957s2_multicom.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0957s2_multicom.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0957s2_multicom/mcomb/casp1.pdb" ]];then 
	printf "!!!!! Failed to run multicom, check the installation </home/jh7x3/multicom/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0957s2_multicom/mcomb/casp1.pdb\n\n"
fi


perl /home/jh7x3/multicom/installation/scripts/validate_integrated_predictions.pl  T0957s2  /home/jh7x3/multicom/test_out/T0957s2_multicom/full_length_hard/meta /home/jh7x3/multicom/installation/benchmark/FM/


printf "\nCheck final predictions.."


perl /home/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T0957s2  /home/jh7x3/multicom/test_out/T0957s2_multicom/mcomb /home/jh7x3/multicom/installation/benchmark/FM/
