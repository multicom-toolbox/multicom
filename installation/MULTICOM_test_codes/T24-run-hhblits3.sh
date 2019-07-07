#!/bin/bash
#SBATCH -J  hhblits3
#SBATCH -o hhblits3-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhblits3/
cd /home/jh7x3/multicom/test_out/T1006_hhblits3/

mkdir hhblits3

touch /home/jh7x3/multicom/test_out/T1006_hhblits3.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhblits3/hhblits3/hhbl2.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhblits3/script/tm_hhblits3_main.pl /home/jh7x3/multicom/src/meta/hhblits3/hhblits3_option /home/jh7x3/multicom/examples/T1006.fasta hhblits3  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhblits3.log
	perl /home/jh7x3/multicom/src/meta/hhblits3/script/filter_identical_hhblits.pl hhblits3 2>&1 | tee -a /home/jh7x3/multicom/test_out/T1006_hhblits3.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhblits3.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhblits3/hhblits3/hhbl2.pdb" ]];then 
	printf "!!!!! Failed to run hhblits3, check the installation </home/jh7x3/multicom/src/meta/hhblits3/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhblits3/hhblits3/hhbl2.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_hhblits3.running
