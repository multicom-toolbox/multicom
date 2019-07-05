#!/bin/bash
#SBATCH -J  muster
#SBATCH -o muster-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_muster/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_muster/

mkdir muster

touch /home/jh7x3/multicom_beta1.0/test_out/T1006_muster.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_muster/muster/muster1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/muster/script/tm_muster_main.pl /home/jh7x3/multicom_beta1.0/src/meta/muster/muster_option_version4 /home/jh7x3/multicom_beta1.0/examples/T1006.fasta muster  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_muster.log
	perl /home/jh7x3/multicom_beta1.0/src/meta/muster/script/filter_identical_muster.pl muster   2>&1 | tee -a /home/jh7x3/multicom_beta1.0/test_out/T1006_muster.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_muster.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_muster/muster/muster1.pdb" ]];then 
	printf "!!!!! Failed to run muster, check the installation </home/jh7x3/multicom_beta1.0/src/meta/muster/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_muster/muster/muster1.pdb\n\n"
fi

rm /home/jh7x3/multicom_beta1.0/test_out/T1006_muster.running
