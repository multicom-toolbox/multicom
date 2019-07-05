#!/bin/sh

#The main script to update MULTICOM database (in a loop mode) --- update all the databases except hhpred
/home/jh7x3/multicom_beta1.0/src/update_db/scripts/casp12_update_once.pl /home/jh7x3/multicom_beta1.0/src/prosys/script/update_main.pl /home/jh7x3/multicom_beta1.0/src/update_db/bin/update_nr.sh /home/jh7x3/multicom_beta1.0/src/update_db/tools/compass/update_compass_db_v2.sh /home/jh7x3/multicom_beta1.0/src/update_db/tools/hhsearch1.5/make_hhsearch1.5_db.sh /home/chengji/casp8/prc/make_prc_db.sh  /home/jh7x3/multicom_beta1.0/options/db_option


