#!/bin/sh
#update compass database

date >> /home/chengji/casp8/compass/database/update_log.txt

#/home/chengji/casp8/compass/script/build_compass_db.pl /home/chengji/software/new_compass/compass_search/mk_compass_db /home/chengji/software/prosys_database/library/ /home/chengji/software/prosys_database/fr_lib/sort90 /home/chengji/casp8/compass/database/compass_db_new
/home/chengji/casp8/compass/script/build_compass_db_v2.pl /home/chengji/software/new_compass/compass_search/mk_compass_db /home/chengji/software/prosys_database/library/ /home/chengji/software/prosys_database/fr_lib/sort90 /home/chengji/casp8/compass/database/compass_db_new

mv /home/chengji/casp8/compass/database/compass_db1 /home/chengji/casp8/compass/database/compass_db1_old

mv /home/chengji/casp8/compass/database/compass_db2 /home/chengji/casp8/compass/database/compass_db2_old

mv /home/chengji/casp8/compass/database/compass_db3 /home/chengji/casp8/compass/database/compass_db3_old

mv /home/chengji/casp8/compass/database/compass_db_new1 /home/chengji/casp8/compass/database/compass_db1

mv /home/chengji/casp8/compass/database/compass_db_new2 /home/chengji/casp8/compass/database/compass_db2

mv /home/chengji/casp8/compass/database/compass_db_new3 /home/chengji/casp8/compass/database/compass_db3

mv /home/chengji/casp8/compass/database/compass_db_new1.len /home/chengji/casp8/compass/database/compass_db1.len

mv /home/chengji/casp8/compass/database/compass_db_new2.len /home/chengji/casp8/compass/database/compass_db2.len

mv /home/chengji/casp8/compass/database/compass_db_new3.len /home/chengji/casp8/compass/database/compass_db3.len

date >> /home/chengji/casp8/compass/database/update_log.txt

echo done >> /home/chengji/casp8/compass/database/update_log.txt

