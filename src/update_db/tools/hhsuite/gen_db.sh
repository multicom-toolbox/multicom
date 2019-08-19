#!/bin/sh

#/storage/htc/bdm/jh7x3/multicom/src/update_db/tools/hhsuite/gen_hhblits_profile.pl /storage/htc/bdm/jh7x3/multicom/tools/hhsuite-2.0.16/ 8 /storage/htc/bdm/jh7x3/multicom/databases/prosys_database/seq/ /storage/htc/bdm/jh7x3/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /storage/htc/bdm/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /storage/htc/bdm/jh7x3/multicom/databases/prosys_database/hhsuite_dbs/a3m/

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


perl /storage/htc/bdm/jh7x3/multicom/src/update_db/tools/hhsuite/joinhmm2db.pl $database_path

