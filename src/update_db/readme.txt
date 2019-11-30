
perl update_db_sbatch.pl <database_dir> <script_dir> <from_db_date> <end_db_date> <thread_num> <by_weeks> <run mode>



### test example

cd /home/jhou4/tools/multicom/src/update_db/example

*** On local server 

sh run_db_20070425_thread.sh


 
*** On Lewis server 

sh run_db_20070425_sbatch.sh





Examples:

perl /home/jhou4/tools/multicom/src/update_db/scripts/update_db_sbatch.pl  /home/jhou4/tools/multicom/databases/prosys_database/  /home/jhou4/tools/multicom/src/update_db/ /home/jhou4/tools/multicom/databases/prosys_database/run_sbatch/  20070101 20070428  20  1  thread

perl /home/jhou4/tools/multicom/src/update_db/scripts/update_db_sbatch.pl  /home/jhou4/tools/multicom/databases/prosys_database/  /home/jhou4/tools/multicom/src/update_db/ /home/jhou4/tools/multicom/databases/prosys_database/run_sbatch/  20070101 20070428  20  1  sbatch


cd /home/jhou4/tools/multicom/databases/prosys_database/run_sbatch



