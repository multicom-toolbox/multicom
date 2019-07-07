#!/bin/bash
#SBATCH -J  modeller9.7
#SBATCH -o modeller9.7-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00


dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_modeller9.7/
cd /home/jh7x3/multicom/test_out/T1006_modeller9.7/


touch /home/jh7x3/multicom/test_out/T1006_modeller9.7.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_modeller9.7/T1006.pdb" ]];then 
	perl /home/jh7x3/multicom/src/prosys/script/pir2ts_energy.pl /home/jh7x3/multicom/tools/modeller9v7/ /home/jh7x3/multicom/examples/ /home/jh7x3/multicom/test_out/T1006_modeller9.7/ /home/jh7x3/multicom/examples/T1006.pir 5  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_modeller9.7.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_modeller9.7.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_modeller9.7/T1006.pdb" ]];then 
	printf "!!!!! Failed to run modeller9v7, check the installation </home/jh7x3/multicom/tools/modeller9v7/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_modeller9.7/T1006.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_modeller9.7.running
