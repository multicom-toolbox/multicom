#!/bin/bash
#SBATCH -J  deepsf
#SBATCH -o deepsf-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)



source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/boost_1_55_0/lib/:/home/jh7x3/multicom_beta1.0/tools/OpenBLAS:$LD_LIBRARY_PATH

mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf/

mkdir deepsf

touch /home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf.running
if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf/deepsf/deepsf1.pdb" ]];then 
	perl /home/jh7x3/multicom_beta1.0/src/meta/deepsf/script/tm_deepsf_main.pl /home/jh7x3/multicom_beta1.0/src/meta/deepsf/deepsf_option /home/jh7x3/multicom_beta1.0/examples/T1006.fasta deepsf  2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf/deepsf/deepsf1.pdb" ]];then 
	printf "!!!!! Failed to run deepsf, check the installation </home/jh7x3/multicom_beta1.0/src/meta/deepsf/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf/deepsf/deepsf1.pdb\n\n"
fi

rm /home/jh7x3/multicom_beta1.0/test_out/T1006_deepsf.running
