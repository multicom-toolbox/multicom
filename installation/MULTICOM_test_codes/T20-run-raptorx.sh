#!/bin/bash
#SBATCH -J  raptorx
#SBATCH -o raptorx-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx/

mkdir raptorx

touch /home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx/raptorx/rapt1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/raptorx/script/tm_raptorx_main.pl /home/jh7x3/multicom_beta1.0/src/meta/raptorx/raptorx_option_version3 /home/jh7x3/multicom_beta1.0/examples/T1006.fasta raptorx  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx/raptorx/rapt1.pdb" ]];then 
	printf "!!!!! Failed to run raptorx, check the installation </home/jh7x3/multicom_beta1.0/src/meta/raptorx/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx/raptorx/rapt1.pdb\n\n"
fi

rm /home/jh7x3/multicom_beta1.0/test_out/T1006_raptorx.running
