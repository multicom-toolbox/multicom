#!/bin/sh

if [ ! -d "/home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs" ]; then
  mkdir /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs
  mkdir /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/profiles
fi




/home/jh7x3/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /home/jh7x3/multicom/tools/hhsuite-3.2.0/ 8 /home/jh7x3/multicom/databases/prosys_database/seq/ /home/jh7x3/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /home/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/profiles

perl /home/jh7x3/multicom/src/update_db/tools/hhsuite3/prepare_db.pl /home/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/profiles /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs

export HHLIB=/home/jh7x3/multicom/tools/hhsuite-3.2.0/
PATH=$PATH:$HHLIB/bin:$HHLIB/scripts


if [ ! -d "/home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/" ]; then
  mkdir /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/
else
  rm /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/*
fi

python $HHLIB/scripts/hhsuitedb.py -o /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/hhsuite3_sort90 --cpu 10 --ia3m=/home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/a3m/* --ihhm=/home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/hhm/* --ics219=/home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/cs219/* --force

cp /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/* /home/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/




