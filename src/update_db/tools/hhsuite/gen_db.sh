#!/bin/sh

#/home/test/jie_test/multicom/src/update_db/tools/hhsuite/gen_hhblits_profile.pl /home/test/jie_test/multicom/tools/hhsuite-2.0.16/ 8 /home/test/jie_test/multicom/databases/prosys_database/seq/ /home/test/jie_test/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /home/test/jie_test/multicom/databases/prosys_database/fr_lib/sort90  /home/test/jie_test/multicom/databases/prosys_database/hhsuite_dbs/a3m/

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


perl /home/test/jie_test/multicom/src/update_db/tools/hhsuite/joinhmm2db.pl $database_path

