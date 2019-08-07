#!/bin/bash
#SBATCH -J  T1008
#SBATCH -o T1008-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00

mkdir -p /home/jh7x3/multicom/test_out/T1008_multicom/
cd /home/jh7x3/multicom/test_out/T1008_multicom/

source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jh7x3/multicom/tools/boost_1_55_0/lib/:/home/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [[ ! -f "/home/jh7x3/multicom/test_out/T1008_multicom/mcomb/casp1.pdb" ]];then 
	/home/jh7x3/multicom/src/multicom_ve.pl /home/jh7x3/multicom/src/multicom_system_option_casp13 /home/jh7x3/multicom/examples/T1008.fasta  /home/jh7x3/multicom/test_out/T1008_multicom/   2>&1 | tee  /home/jh7x3/multicom/test_out/T1008_multicom.log
fi

printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1008_multicom.log>\n\n"

/home/jh7x3/multicom/src/visualize_multicom_cluster/P1_organize_prediction.sh /home/jh7x3/multicom/test_out/T1008_multicom/  T1008  /home/jh7x3/multicom/test_out/T1008_multicom/multicom_results


if [[ ! -f "/home/jh7x3/multicom/test_out/T1008_multicom/mcomb/casp1.pdb" ]];then 
	printf "!!!!! Failed to run multicom, check the installation </home/jh7x3/multicom/src/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1008_multicom/mcomb/casp1.pdb\n\n"
fi


perl /home/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T1008  /home/jh7x3/multicom/test_out/T1008_multicom/full_length_hard/meta /home/jh7x3/multicom/installation/benchmark/FM/T1008 /home/jh7x3/multicom/installation/benchmark/FM/T1008.pdb  meta  2>&1 | tee -a /home/jh7x3/multicom/test_out/T1008_multicom.log


printf "\nCheck final predictions.."


perl /home/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T1008  /home/jh7x3/multicom/test_out/T1008_multicom/mcomb /home/jh7x3/multicom/installation/benchmark/FM/T1008/mcomb /home/jh7x3/multicom/installation/benchmark/FM/T1008.pdb casp 2>&1 | tee -a /home/jh7x3/multicom/test_out/T1008_multicom.log
