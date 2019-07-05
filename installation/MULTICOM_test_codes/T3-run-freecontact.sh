#!/bin/bash
#SBATCH -J  freecontact
#SBATCH -o freecontact-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/boost_1_55_0/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/OpenBLAS/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/DNCON2/freecontact-1.0.21/lib:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact/

touch /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact/T1006.freecontact.rr" ]];then 
	/home/jh7x3/multicom_beta1.0/tools/DNCON2/freecontact-1.0.21/bin/freecontact < /home/jh7x3/multicom_beta1.0/examples/T1006.aln > /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact/T1006.freecontact.rr  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact.log
fi



col_num=$(head -1 /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact/T1006.freecontact.rr | tr ' ' '\n' | wc -l)

if [[ $col_num != 6 ]]
then 
	printf "\n!!!!! Failed to run freecontact, check the installation </home/jh7x3/multicom_beta1.0/tools/DNCON2/freecontact-1.0.21/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact/T1006.freecontact.rr\n\n"
fi

rm /home/jh7x3/multicom_beta1.0/test_out/T1006_freecontact.running
