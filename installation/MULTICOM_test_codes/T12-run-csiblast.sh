#!/bin/bash
#SBATCH -J  csiblast
#SBATCH -o csiblast-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast/

mkdir csiblast
touch /home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast/csiblast/csiblast1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/csblast/script/multicom_csiblast_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/csblast/csiblast_option /home/jh7x3/multicom_beta1.0/examples/T1006.fasta csiblast  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast/csiblast/csiblast1.pdb" ]];then 
	printf "!!!!! Failed to run csiblast, check the installation </home/jh7x3/multicom_beta1.0/src/meta/csblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast/csiblast/csiblast1.pdb\n\n"
fi
rm /home/jh7x3/multicom_beta1.0/test_out/T1006_csiblast.running
