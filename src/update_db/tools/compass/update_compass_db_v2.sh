#!/bin/sh
#update compass database

date >> /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/update_log.txt

/storage/hpc/scratch/jh7x3/multicom_beta1.0/src/update_db_v1.1/tools/compass/build_compass_db_v3.pl /storage/hpc/scratch/jh7x3/multicom_beta1.0/tools/new_compass/compass_search/mk_compass_db /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/library/ /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/fr_lib/sort90 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db1 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db1_old

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db2 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db2_old

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db3 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db3_old

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db4 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db4_old

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db5 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db5_old

#########

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new1 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db1

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new2 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db2

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new3 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db3

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new4 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db4

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new5 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db5

###############

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new1.len /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db1.len

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new2.len /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db2.len

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new3.len /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db3.len

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new4.len /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db4.len

mv /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db_new5.len /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/compass_db5.len

date >> /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/update_log.txt

echo done >> /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/compass_db/update_log.txt

