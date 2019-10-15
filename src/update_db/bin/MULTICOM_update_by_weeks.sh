#!/bin/sh

#The main script to update MULTICOM database by specific weeks


database_path='/home/test/jie_test/multicom/databases/prosys_database/'
end_date=20070428
thread_num=20
week_interval=1
run_mode='thread'

################# do not change the code below
start_date=20070101
database_script=/home/test/jie_test/multicom/src/update_db/


if [ ! -d "$database_path" ]; then
	mkdir $database_path
fi

if [ ! -d "$database_path/run_sbatch" ]; then
	mkdir $database_path/run_sbatch
fi

perl /home/test/jie_test/multicom/src/update_db/scripts/update_db_sbatch.pl  $database_path  $database_script  $database_path/run_sbatch/  $start_date $end_date  $thread_num  $week_interval $run_mode



