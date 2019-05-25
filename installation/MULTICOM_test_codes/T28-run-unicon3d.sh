#!/bin/bash

dtime=$(date +%m%d%y)


source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom/test_out/T0993s2_unicon3d_$dtime/
cd /home/jh7x3/multicom/test_out/T0993s2_unicon3d_$dtime/

mkdir unicon3d
perl /home/jh7x3/multicom/src/meta/unicon3d/script/tm_unicon3d_main.pl /home/jh7x3/multicom/src/meta/unicon3d/Unicon3D_option /home/jh7x3/multicom/examples/T0993s2.fasta unicon3d  2>&1 | tee  /home/jh7x3/multicom/test_out/T0993s2_unicon3d_$dtime.log


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T0993s2_unicon3d_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T0993s2_unicon3d_$dtime/unicon3d/ss1.pdb" ]];then 
	printf "!!!!! Failed to run unicon3d, check the installation </home/jh7x3/multicom/src/meta/unicon3d/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T0993s2_unicon3d_$dtime/unicon3d/ss1.pdb\n\n"
fi

