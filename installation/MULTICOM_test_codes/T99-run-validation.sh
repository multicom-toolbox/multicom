#!/bin/bash
#SBATCH -J  validation
#SBATCH -o validation-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time 2-00:00

cd /home/jh7x3/multicom/test_out/ 
source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
perl /home/jh7x3/multicom/installation/scripts/validate_predictions.pl  T1006  /home/jh7x3/multicom/test_out/ /home/jh7x3/multicom/installation/benchmark/TBM
