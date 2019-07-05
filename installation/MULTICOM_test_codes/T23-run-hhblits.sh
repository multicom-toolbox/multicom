#!/bin/bash
#SBATCH -J  hhblits
#SBATCH -o hhblits-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits/

mkdir hhblits

touch  /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits/hhblits/blits1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/hhblits/script/tm_hhblits_main.pl /home/jh7x3/multicom_beta1.0/src/meta/hhblits/hhblits_option /home/jh7x3/multicom_beta1.0/examples/T1006.fasta hhblits  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits.log
	perl /home/jh7x3/multicom_beta1.0/src/meta/hhblits/script/filter_identical_hhblits.pl hhblits  2>&1 | tee -a /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits/hhblits/blits1.pdb" ]];then 
	printf "!!!!! Failed to run hhblits, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hhblits/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits/hhblits/blits1.pdb\n\n"
fi

rm  /home/jh7x3/multicom_beta1.0/test_out/T1006_hhblits.running
