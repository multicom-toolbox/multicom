#!/bin/bash
#SBATCH -J  blast
#SBATCH -o blast-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_blast/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_blast/

mkdir blast

touch  /home/jh7x3/multicom_beta1.0/test_out/T1006_blast.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_blast/blast/hs1.pdb" ]];then
	perl /home/jh7x3/multicom_beta1.0/src/meta/blast/script/main_blast_v2.pl /home/jh7x3/multicom_beta1.0/src/meta/blast/cm_option_adv /home/jh7x3/multicom_beta1.0/examples/T1006.fasta blast  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_blast.log
	perl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /home/jh7x3/multicom_beta1.0/src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /home/jh7x3/multicom_beta1.0/examples/T1006.fasta blast
fi



printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_blast.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_blast/blast/hs1.pdb" ]];then 
	printf "!!!!! Failed to run blast, check the installation </home/jh7x3/multicom_beta1.0/src/meta/blast/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_blast/blast/hs1.pdb\n\n"
fi
rm /home/jh7x3/multicom_beta1.0/test_out/T1006_blast.running
