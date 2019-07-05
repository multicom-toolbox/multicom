#!/bin/bash
#SBATCH -J  sam
#SBATCH -o sam-hard-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard/

mkdir sam
touch /home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard/sam/sam1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/sam/script/tm_sam_main_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/sam/sam_option_hard /home/jh7x3/multicom_beta1.0/examples/T1006.fasta sam  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard/sam/sam1.pdb" ]];then 
	printf "!!!!! Failed to run sam, check the installation </home/jh7x3/multicom_beta1.0/src/meta/sam/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard/sam/sam1.pdb\n\n"
fi
rm /home/jh7x3/multicom_beta1.0/test_out/T1006_sam_hard.running
