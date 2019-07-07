#!/bin/bash
#SBATCH -J  fusioncon
#SBATCH -o fusioncon-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00


dtime=$(date +%m%d%y)



source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom/test_out/T1006_fusioncon/
cd /home/jh7x3/multicom/test_out/T1006_fusioncon/

mkdir fusioncon

touch /home/jh7x3/multicom/test_out/T1006_fusioncon.log
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_fusioncon/fusioncon/fusicon1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/fusioncon/script/tm_fusioncon_main.pl /home/jh7x3/multicom/src/meta/fusioncon/fusioncon_option /home/jh7x3/multicom/examples/T1006.fasta fusioncon  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_fusioncon.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_fusioncon.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_fusioncon/fusioncon/fusicon1.pdb" ]];then 
	printf "!!!!! Failed to run fusioncon, check the installation </home/jh7x3/multicom/src/meta/fusioncon/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_fusioncon/fusioncon/fusicon1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_fusioncon.log
