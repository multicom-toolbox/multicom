#!/bin/bash
#SBATCH -J  hmmer
#SBATCH -o hmmer-hard-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3/

mkdir hmmer3
touch /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3/hmmer3/jackhmmer1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/hmmer3/script/tm_hmmer3_main.pl /home/jh7x3/multicom_beta1.0/src/meta/hmmer3/hmmer3_option /home/jh7x3/multicom_beta1.0/examples/T1006.fasta hmmer3  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3/hmmer3/jackhmmer1.pdb" ]];then 
	printf "!!!!! Failed to run hmmer3, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hmmer3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3/hmmer3/jackhmmer1.pdb\n\n"
fi
rm /home/jh7x3/multicom_beta1.0/test_out/T1006_hmmer3.running
