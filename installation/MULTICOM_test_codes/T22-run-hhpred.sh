#!/bin/bash
#SBATCH -J  hhpred
#SBATCH -o hhpred-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhpred/
cd /home/jh7x3/multicom/test_out/T1006_hhpred/

mkdir hhpred

touch /home/jh7x3/multicom/test_out/T1006_hhpred.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhpred/hhpred/hp1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhpred/script/tm_hhpred_main.pl /home/jh7x3/multicom/src/meta/hhpred/hhpred_option /home/jh7x3/multicom/examples/T1006.fasta hhpred  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhpred.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhpred.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhpred/hhpred/hp1.pdb" ]];then 
	printf "!!!!! Failed to run hhpred, check the installation </home/jh7x3/multicom/src/meta/hhpred/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhpred/hhpred/hp1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_hhpred.running
