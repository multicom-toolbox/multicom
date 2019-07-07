#!/bin/bash
#SBATCH -J  hhsearch151
#SBATCH -o hhsearch151-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhsearch151/
cd /home/jh7x3/multicom/test_out/T1006_hhsearch151/

mkdir hhsearch151

touch /home/jh7x3/multicom/test_out/T1006_hhsearch151.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsearch151/hhsearch151/hg1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /home/jh7x3/multicom/src/meta/hhsearch151/hhsearch151_option /home/jh7x3/multicom/examples/T1006.fasta hhsearch151  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhsearch151.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhsearch151.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsearch151/hhsearch151/hg1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch151, check the installation </home/jh7x3/multicom/src/meta/hhsearch151/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhsearch151/hhsearch151/hg1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_hhsearch151.running
