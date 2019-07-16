#!/bin/sh

#/disk2/chengji/hhsuite/gen_hhblits_profile.pl ~/software/hhsuite-2.0.8-linux-x86_64/ 8 ~/software/prosys_database/seq/ /disk2/chengji/nr20/nr20 ~/software/prosys_database/fr_lib/sort90  /disk2/chengji/hhsuite/a3m

/storage/hpc/scratch/jh7x3/multicom_beta1.0/src/update_db_v1.1/tools/hhsuite/gen_hhblits_profile.pl /storage/hpc/scratch/jh7x3/multicom_beta1.0/tools/hhsuite-3.2.0/ 8 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/seq/ /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/fr_lib/sort90  /storage/hpc/scratch/jh7x3/multicom_beta1.0/databases/prosys_database/hhsuite_dbs/a3m/

/storage/hpc/scratch/jh7x3/multicom_beta1.0/src/update_db_v1.1/tools/hhsuite/joinhmm2db.pl

