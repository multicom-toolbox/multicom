#!/bin/sh

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


if [ ! -d "$database_path/compass_db/" ]; then
  mkdir $database_path/compass_db/
fi

#update compass database

date >> $database_path/compass_db/update_log.txt

/storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/compass/build_compass_db_v3.pl /storage/hpc/scratch/jh7x3/multicom/tools/new_compass/compass_search/mk_compass_db $database_path/library/ $database_path/fr_lib/sort90 $database_path/compass_db/compass_db_new

mv $database_path/compass_db/compass_db1 $database_path/compass_db/compass_db1_old

mv $database_path/compass_db/compass_db2 $database_path/compass_db/compass_db2_old

mv $database_path/compass_db/compass_db3 $database_path/compass_db/compass_db3_old

mv $database_path/compass_db/compass_db4 $database_path/compass_db/compass_db4_old

mv $database_path/compass_db/compass_db5 $database_path/compass_db/compass_db5_old

#########

mv $database_path/compass_db/compass_db_new1 $database_path/compass_db/compass_db1

mv $database_path/compass_db/compass_db_new2 $database_path/compass_db/compass_db2

mv $database_path/compass_db/compass_db_new3 $database_path/compass_db/compass_db3

mv $database_path/compass_db/compass_db_new4 $database_path/compass_db/compass_db4

mv $database_path/compass_db/compass_db_new5 $database_path/compass_db/compass_db5

###############

mv $database_path/compass_db/compass_db_new1.len $database_path/compass_db/compass_db1.len

mv $database_path/compass_db/compass_db_new2.len $database_path/compass_db/compass_db2.len

mv $database_path/compass_db/compass_db_new3.len $database_path/compass_db/compass_db3.len

mv $database_path/compass_db/compass_db_new4.len $database_path/compass_db/compass_db4.len

mv $database_path/compass_db/compass_db_new5.len $database_path/compass_db/compass_db5.len

date >> $database_path/compass_db/update_log.txt

echo done >> $database_path/compass_db/update_log.txt

