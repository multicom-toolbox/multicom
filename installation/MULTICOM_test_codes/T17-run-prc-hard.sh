#!/bin/bash
#SBATCH -J  prc
#SBATCH -o prc-hard-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_prc_hard/
cd /home/jh7x3/multicom/test_out/T1006_prc_hard/

mkdir prc

touch /home/jh7x3/multicom/test_out/T1006_prc_hard.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_prc_hard/prc/prc1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/prc/script/tm_prc_main_v2.pl /home/jh7x3/multicom/src/meta/prc/prc_option_hard /home/jh7x3/multicom/examples/T1006.fasta prc  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_prc_hard.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_prc_hard.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_prc_hard/prc/prc1.pdb" ]];then 
	printf "!!!!! Failed to run prc, check the installation </home/jh7x3/multicom/src/meta/prc/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_prc_hard/prc/prc1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_prc_hard.running
