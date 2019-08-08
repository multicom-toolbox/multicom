#!/bin/sh

if [ ! -d "/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs" ]; then
  mkdir /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs
  mkdir /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/profiles
fi




/storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/hhsuite3/gen_hhblits_profile.pl /storage/hpc/scratch/jh7x3/multicom/tools/hhsuite-3.2.0/ 8 /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/seq/ /storage/hpc/scratch/jh7x3/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/profiles

perl /storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/hhsuite3/prepare_db.pl /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/profiles /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs

export HHLIB=/storage/hpc/scratch/jh7x3/multicom/tools/hhsuite-3.2.0/
PATH=$PATH:$HHLIB/bin:$HHLIB/scripts


if [ ! -d "/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/" ]; then
  mkdir /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/
else
  rm /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/*
fi

python $HHLIB/scripts/hhsuitedb.py -o /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/hhsuite3_sort90 --cpu 10 --ia3m=/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/a3m/* --ihhm=/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/hhm/* --ics219=/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/cs219/* --force

cp /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/work/* /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite3_dbs/




