#!/bin/sh

#The main script to update MULTICOM database (in a loop mode) --- update all the databases except hhpred
./casp12_sync_only.pl /home/chengji/software/prosys/script/update_main_sync_only.pl ./update_nr.sh /home/chengji/casp8/compass/database/update_compass_db.sh /home/chengji/casp8/hhsearch1.5/make_hhsearch1.5_db.sh /home/chengji/casp8/prc/make_prc_db.sh  db_option


