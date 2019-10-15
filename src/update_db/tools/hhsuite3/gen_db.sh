#!/bin/sh

if [ $# -ne 2 ]
then
        echo "need two parameters: databasae directory, option file."
        exit 1
fi

database_path=$1
option_file=$2


if [ ! -d "$database_path/hhsuite3_dbs" ]; then
  mkdir $database_path/hhsuite3_dbs
  mkdir $database_path/hhsuite3_dbs/profiles
fi




#/home/test/jie_test/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /home/test/jie_test/multicom/tools/hhsuite-3.2.0/ 8 $database_path/seq/ /home/test/jie_test/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 $database_path/fr_lib/sort90  $database_path/hhsuite3_dbs/profiles

/home/test/jie_test/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile_proc.pl $option_file $database_path/fr_lib/sort90  $database_path/hhsuite3_dbs/profiles

perl /home/test/jie_test/multicom/src/update_db/tools/hhsuite3/prepare_db.pl $database_path/fr_lib/sort90  $database_path/hhsuite3_dbs/profiles $database_path/hhsuite3_dbs

export HHLIB=/home/test/jie_test/multicom/tools/hhsuite-3.2.0/
PATH=$PATH:$HHLIB/bin:$HHLIB/scripts


if [ ! -d "$database_path/hhsuite3_dbs/work/" ]; then
  mkdir $database_path/hhsuite3_dbs/work/
else
  rm $database_path/hhsuite3_dbs/work/*
fi

python $HHLIB/scripts/hhsuitedb.py -o $database_path/hhsuite3_dbs/work/hhsuite3_sort90 --cpu 10 --ia3m=$database_path/hhsuite3_dbs/a3m/* --ihhm=$database_path/hhsuite3_dbs/hhm/* --ics219=$database_path/hhsuite3_dbs/cs219/* --force

cp $database_path/hhsuite3_dbs/work/* $database_path/hhsuite3_dbs/




