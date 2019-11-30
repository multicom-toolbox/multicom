#!/bin/sh

#/home/jhou4/tools/multicom/src/update_db/tools/hhsuite/gen_hhblits_profile.pl /home/jhou4/tools/multicom/tools/hhsuite-2.0.16/ 8 /home/jhou4/tools/multicom/databases/prosys_database/seq/ /home/jhou4/tools/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /home/jhou4/tools/multicom/databases/prosys_database/fr_lib/sort90  /home/jhou4/tools/multicom/databases/prosys_database/hhsuite_dbs/a3m/

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


perl /home/jhou4/tools/multicom/src/update_db/tools/hhsuite/joinhmm2db.pl $database_path

