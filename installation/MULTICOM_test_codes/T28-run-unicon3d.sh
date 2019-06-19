#!/bin/bash

dtime=$(date +%m%d%y)


source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom/test_out/T1006_unicon3d/
cd /home/jh7x3/multicom/test_out/T1006_unicon3d/

mkdir unicon3d

touch /home/jh7x3/multicom/test_out/T1006_unicon3d.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_unicon3d/unicon3d/Unicon3d-1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/unicon3d/script/tm_unicon3d_main.pl /home/jh7x3/multicom/src/meta/unicon3d/Unicon3D_option /home/jh7x3/multicom/examples/T1006.fasta unicon3d  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_unicon3d.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_unicon3d.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_unicon3d/unicon3d/Unicon3d-1.pdb" ]];then 
	printf "!!!!! Failed to run unicon3d, check the installation </home/jh7x3/multicom/src/meta/unicon3d/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_unicon3d/unicon3d/Unicon3d-1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_unicon3d.running
