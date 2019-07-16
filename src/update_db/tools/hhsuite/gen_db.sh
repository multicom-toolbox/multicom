#!/bin/sh

/storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/hhsuite/gen_hhblits_profile.pl /storage/hpc/scratch/jh7x3/multicom/tools/hhsuite-2.0.16/ 8 /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/seq/ /storage/hpc/scratch/jh7x3/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite_dbs/a3m/

/storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/hhsuite/joinhmm2db.pl

