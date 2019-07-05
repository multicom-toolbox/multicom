#!/bin/sh
#update compass database

date >> /home/jh7x3/multicom_beta1.0/databases/compass_db/update_log.txt

/home/jh7x3/multicom_beta1.0/src/update_db/tools/compass/build_compass_db_v3.pl /home/jh7x3/multicom_beta1.0/tools/new_compass/compass_search/mk_compass_db /home/jh7x3/multicom_beta1.0/databases/library/ /home/jh7x3/multicom_beta1.0/databases/fr_lib/sort90 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db1 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db1_old

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db2 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db2_old

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db3 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db3_old

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db4 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db4_old

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db5 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db5_old

#########

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new1 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db1

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new2 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db2

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new3 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db3

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new4 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db4

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new5 /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db5

###############

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new1.len /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db1.len

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new2.len /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db2.len

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new3.len /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db3.len

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new4.len /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db4.len

mv /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db_new5.len /home/jh7x3/multicom_beta1.0/databases/compass_db/compass_db5.len

date >> /home/jh7x3/multicom_beta1.0/databases/compass_db/update_log.txt

echo done >> /home/jh7x3/multicom_beta1.0/databases/compass_db/update_log.txt

