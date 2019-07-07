#!/bin/bash
#SBATCH -J  pspro
#SBATCH -o pspro-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_pspro/
cd /home/jh7x3/multicom/test_out/T1006_pspro/


touch /home/jh7x3/multicom/test_out/T1006_pspro.running

if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_pspro/T1006.ssa" ]];then 
	/home/jh7x3/multicom/tools/pspro2/bin/predict_ssa.sh /home/jh7x3/multicom/examples/T1006.fasta /home/jh7x3/multicom/test_out/T1006_pspro/T1006.ssa  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_pspro.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_pspro.log>..\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_pspro/T1006.ssa" ]];then 
	printf "\n!!!!! Failed to run pspro2, check the installation </home/jh7x3/multicom/tools/pspro2/>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_pspro/T1006_fasta.ssa\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_pspro.running
