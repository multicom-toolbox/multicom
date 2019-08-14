#!/bin/bash
#SBATCH -J  T1006
#SBATCH -o T1006-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00
 
mkdir -p /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/
cd /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/

source /storage/htc/bdm/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/storage/htc/bdm/jh7x3/multicom/tools/boost_1_55_0/lib/:/storage/htc/bdm/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

if [[ ! -f "/storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/mcomb/casp1.pdb" ]];then 
	/storage/htc/bdm/jh7x3/multicom/src/multicom_ve.pl /storage/htc/bdm/jh7x3/multicom/src/multicom_system_option_casp13 /storage/htc/bdm/jh7x3/multicom/examples/T1006.fasta  /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/   2>&1 | tee  /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom.log
fi


printf "\nFinished.."
printf "\nCheck log file </storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom.log>\n\n"

/storage/htc/bdm/jh7x3/multicom/src/visualize_multicom_cluster/P1_organize_prediction.sh /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/  T1006  /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/multicom_results


perl /storage/htc/bdm/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T1006  /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/full_length/meta /storage/htc/bdm/jh7x3/multicom/installation/benchmark/TBM/T1006  /storage/htc/bdm/jh7x3/multicom/installation/benchmark/TBM/T1006.pdb  meta 2>&1 | tee -a /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom.log



printf "\nCheck final predictions.."


perl /storage/htc/bdm/jh7x3/multicom/installation/scripts/validate_integrated_predictions_final.pl  T1006  /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom/mcomb /storage/htc/bdm/jh7x3/multicom/installation/benchmark/TBM/T1006/mcomb /storage/htc/bdm/jh7x3/multicom/installation/benchmark/TBM/T1006.pdb casp 2>&1 | tee -a /storage/htc/bdm/jh7x3/multicom/test_out/T1006_multicom.log
