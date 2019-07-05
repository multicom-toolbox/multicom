#!/bin/bash
#SBATCH -J  modeller9.16
#SBATCH -o modeller9.16-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16/


touch /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16/T1006.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/prosys/script/pir2ts_energy.pl /home/jh7x3/multicom_beta1.0/tools/modeller-9.16/ /home/jh7x3/multicom_beta1.0/examples/ /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16/ /home/jh7x3/multicom_beta1.0/examples/T1006.pir 5  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16/T1006.pdb" ]];then 
	printf "!!!!! Failed to run modeller-9.16, check the installation </home/jh7x3/multicom_beta1.0/tools/modeller-9.16/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16/T1006.pdb\n\n"
fi

rm /home/jh7x3/multicom_beta1.0/test_out/T1006_modeller9.16.running
