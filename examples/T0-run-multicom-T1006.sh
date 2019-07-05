#!/bin/bash
#SBATCH -J  T1006
#SBATCH -o T1006-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

mkdir -p /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/
cd /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/

source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom_beta1.0/tools/boost_1_55_0/lib/:/home/jh7x3/multicom_beta1.0/tools/OpenBLAS:$LD_LIBRARY_PATH

if [[ ! -f "/home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/mcomb/casp1.pdb" ]];then 
	/home/jh7x3/multicom_beta1.0/src/multicom_ve.pl /home/jh7x3/multicom_beta1.0/src/multicom_system_option_casp13 /home/jh7x3/multicom_beta1.0/examples/T1006.fasta  /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/   2>&1 | tee  /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom_beta1.0/test_out/T1006_multicom.log>\n\n"

/home/jh7x3/multicom_beta1.0/src/visualize_multicom_cluster/P1_organize_prediction.sh /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/  T1006  /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/multicom_results


perl /home/jh7x3/multicom_beta1.0/installation/scripts/validate_integrated_predictions_final.pl  T1006  /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/full_length/meta /home/jh7x3/multicom_beta1.0/installation/benchmark/TBM/T1006  /home/jh7x3/multicom_beta1.0/installation/benchmark/TBM/T1006.pdb  meta 2>&1 | tee -a /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom.log



printf "\nCheck final predictions.."


perl /home/jh7x3/multicom_beta1.0/installation/scripts/validate_integrated_predictions_final.pl  T1006  /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom/mcomb /home/jh7x3/multicom_beta1.0/installation/benchmark/TBM/T1006/mcomb /home/jh7x3/multicom_beta1.0/installation/benchmark/TBM/T1006.pdb casp 2>&1 | tee -a /home/jh7x3/multicom_beta1.0/test_out/T1006_multicom.log
