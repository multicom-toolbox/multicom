#!/bin/bash -l
#SBATCH -J db1_20070425
#SBATCH -o db1_20070425.log
#SBATCH --partition gpu3
#SBATCH --nodes=1
#SBATCH --ntasks=1         # leave at '1' unless using a MPI code
#SBATCH --cpus-per-task=20  # cores per task
#SBATCH --mem-per-cpu=2G  # memory per core (default is 1GB/core)
#SBATCH --time 2-00:00     # days-hours:minutes
#SBATCH --qos=normal
#SBATCH --account=general-gpu  # investors will replace this with their account name
#SBATCH --gres gpu:"Tesla K40m":1


#The main script to update MULTICOM database by specific weeks




database_path='/home/test/jie_test/multicom/databases/prosys_database_test/'
end_date=20070428
thread_num=20
week_interval=1
run_mode='sbatch'

################# do not change the code below
start_date=20070101
database_script=/home/test/jie_test/multicom/src/update_db/


if [ ! -d "$database_path" ]; then
	mkdir -p $database_path
fi

if [ ! -d "$database_path/run_sbatch" ]; then
	mkdir -p $database_path/run_sbatch
fi


perl /home/test/jie_test/multicom/src/update_db/scripts/update_db_sbatch.pl  $database_path  $database_script  $database_path/run_sbatch/  20070101 20070425  $thread_num  $week_interval $run_mode
