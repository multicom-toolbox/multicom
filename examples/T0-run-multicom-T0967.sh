#!/bin/bash
#SBATCH -J  T0967
#SBATCH -o T0967-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00

mkdir -p /home/test/jie_test/multicom/test_out/T0967_multicom/
cd /home/test/jie_test/multicom/test_out/T0967_multicom/

source /home/test/jie_test/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/test/jie_test/multicom/tools/boost_1_55_0/lib/:/home/test/jie_test/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [[ ! -f "/home/test/jie_test/multicom/test_out/T0967_multicom/mcomb/casp1.pdb" ]];then 
	/home/test/jie_test/multicom/src/multicom_ve.pl /home/test/jie_test/multicom/src/multicom_system_option_casp13 /home/test/jie_test/multicom/examples/T0967.fasta  /home/test/jie_test/multicom/test_out/T0967_multicom/   2>&1 | tee  /home/test/jie_test/multicom/test_out/T0967_multicom.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/test/jie_test/multicom/test_out/T0967_multicom.log>\n\n"

/home/test/jie_test/multicom/src/visualize_multicom_cluster/P1_organize_prediction.sh /home/test/jie_test/multicom/test_out/T0967_multicom/  T0967  /home/test/jie_test/multicom/test_out/T0967_multicom/multicom_results


if [[ ! -f "/home/test/jie_test/multicom/test_out/T0967_multicom/mcomb/casp1.pdb" ]];then 
	printf "!!!!! Failed to run multicom, check the installation </home/test/jie_test/multicom/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/test/jie_test/multicom/test_out/T0967_multicom/mcomb/casp1.pdb\n\n"
fi


perl /home/test/jie_test/multicom/installation/scripts/validate_integrated_predictions_final.pl  T0967  /home/test/jie_test/multicom/test_out/T0967_multicom/full_length/meta /home/test/jie_test/multicom/installation/benchmark/TBM/T0967  /home/test/jie_test/multicom/installation/benchmark/TBM/T0967.pdb  meta 2>&1 | tee -a /home/test/jie_test/multicom/test_out/T0967_multicom.log


printf "\nCheck final predictions.."


perl /home/test/jie_test/multicom/installation/scripts/validate_integrated_predictions_final.pl  T0967  /home/test/jie_test/multicom/test_out/T0967_multicom/mcomb /home/test/jie_test/multicom/installation/benchmark/TBM/T0967/mcomb /home/test/jie_test/multicom/installation/benchmark/TBM/T0967.pdb casp 2>&1 | tee -a /home/test/jie_test/multicom/test_out/T0967_multicom.log
