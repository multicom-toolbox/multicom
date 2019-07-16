#!/bin/sh

#The main script to update MULTICOM database (in a loop mode) --- update all the databases except hhpred
/storage/hpc/scratch/jh7x3/multicom/src/update_db/scripts/casp12_update_once.pl /storage/hpc/scratch/jh7x3/multicom/src/prosys/script/update_main.pl /storage/hpc/scratch/jh7x3/multicom/src/update_db/bin/update_nr.sh /storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/compass/update_compass_db_v2.sh /storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/hhsearch1.5/make_hhsearch1.5_db.sh/storage/hpc/scratch/jh7x3/multicom/src/update_db/tools/prc/make_prc_db.sh  /storage/hpc/scratch/jh7x3/multicom/src/update_db/options/db_option


