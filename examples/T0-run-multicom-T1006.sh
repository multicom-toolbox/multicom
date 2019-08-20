#!/bin/bash
#SBATCH -J  T1006
#SBATCH -o T1006-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00
 
mkdir -p /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/
cd /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/

source /storage/hpc/scratch/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/storage/hpc/scratch/jh7x3/multicom/tools/boost_1_55_0/lib/:/storage/hpc/scratch/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [[ ! -f "/storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/mcomb/casp1.pdb" ]];then 
	/storage/hpc/scratch/jh7x3/multicom/src/multicom_ve.pl /storage/hpc/scratch/jh7x3/multicom/src/multicom_system_option_casp13 /storage/hpc/scratch/jh7x3/multicom/examples/T1006.fasta  /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/   2>&1 | tee  /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom.log
fi


printf "\nFinished.."
printf "\nCheck log file </storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom.log>\n\n"

/storage/hpc/scratch/jh7x3/multicom/src/visualize_multicom_cluster/P1_organize_prediction.sh /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/  T1006  /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/multicom_results


perl /storage/hpc/scratch/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T1006  /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/full_length/meta /storage/hpc/scratch/jh7x3/multicom/installation/benchmark/TBM/T1006  /storage/hpc/scratch/jh7x3/multicom/installation/benchmark/TBM/T1006.pdb  meta 2>&1 | tee -a /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom.log



printf "\nCheck final predictions.."


perl /storage/hpc/scratch/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T1006  /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom/mcomb /storage/hpc/scratch/jh7x3/multicom/installation/benchmark/TBM/T1006/mcomb /storage/hpc/scratch/jh7x3/multicom/installation/benchmark/TBM/T1006.pdb casp 2>&1 | tee -a /storage/hpc/scratch/jh7x3/multicom/test_out/T1006_multicom.log
