#!/bin/bash
#SBATCH -J  hhsearch15
#SBATCH -o hhsearch15-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15/

mkdir hhsearch15

touch /home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15/hhsearch15/ss1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch1.5/hhsearch1.5_option /home/jh7x3/multicom_beta1.0/examples/T1006.fasta hhsearch15  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15/hhsearch15/ss1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch15, check the installation </home/jh7x3/multicom_beta1.0/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15/hhsearch15/ss1.pdb\n\n"
fi

rm /home/jh7x3/multicom_beta1.0/test_out/T1006_hhsearch15.running
