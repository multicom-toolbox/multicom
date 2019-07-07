#!/bin/bash
#SBATCH -J  csblast
#SBATCH -o csblast-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_csblast/
cd /home/jh7x3/multicom/test_out/T1006_csblast/

mkdir csblast


touch /home/jh7x3/multicom/test_out/T1006_csblast.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_csblast/csblast/csblast1.pdb" ]];then
	perl /home/jh7x3/multicom/src/meta/csblast/script/multicom_csblast_v2.pl /home/jh7x3/multicom/src/meta/csblast/csblast_option /home/jh7x3/multicom/examples/T1006.fasta csblast  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_csblast.log
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_csblast.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_csblast/csblast/csblast1.pdb" ]];then 
	printf "!!!!! Failed to run csblast, check the installation </home/jh7x3/multicom/src/meta/csblast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_csblast/csblast/csblast1.pdb\n\n"
fi
rm /home/jh7x3/multicom/test_out/T1006_csblast.running
