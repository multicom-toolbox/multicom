#!/bin/sh

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


if [ ! -d "$database_path/hhsuite3_dbs" ]; then
  mkdir $database_path/hhsuite3_dbs
  mkdir $database_path/hhsuite3_dbs/profiles
fi




/storage/htc/bdm/jh7x3/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /storage/htc/bdm/jh7x3/multicom/tools/hhsuite-3.2.0/ 8 $database_path/seq/ /storage/htc/bdm/jh7x3/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 $database_path/fr_lib/sort90  $database_path/hhsuite3_dbs/profiles

perl /storage/htc/bdm/jh7x3/multicom/src/update_db/tools/hhsuite3/prepare_db.pl $database_path/fr_lib/sort90  $database_path/hhsuite3_dbs/profiles $database_path/hhsuite3_dbs

export HHLIB=/storage/htc/bdm/jh7x3/multicom/tools/hhsuite-3.2.0/
PATH=$PATH:$HHLIB/bin:$HHLIB/scripts


if [ ! -d "$database_path/hhsuite3_dbs/work/" ]; then
  mkdir $database_path/hhsuite3_dbs/work/
else
  rm $database_path/hhsuite3_dbs/work/*
fi

python $HHLIB/scripts/hhsuitedb.py -o $database_path/hhsuite3_dbs/work/hhsuite3_sort90 --cpu 10 --ia3m=$database_path/hhsuite3_dbs/a3m/* --ihhm=$database_path/hhsuite3_dbs/hhm/* --ics219=$database_path/hhsuite3_dbs/cs219/* --force

cp $database_path/hhsuite3_dbs/work/* $database_path/hhsuite3_dbs/




