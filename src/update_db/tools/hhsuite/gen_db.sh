#!/bin/sh

/home/jh7x3/multicom/src/update_db/tools/hhsuite/gen_hhblits_profile.pl /home/jh7x3/multicom/tools/hhsuite-2.0.16/ 8 /home/jh7x3/multicom/databases/prosys_database/seq/ /home/jh7x3/multicom/databases/uniprot30/uniclust30_2018_08/uniclust30_2018_08 /home/jh7x3/multicom/databases/prosys_database/fr_lib/sort90  /home/jh7x3/multicom/databases/prosys_database/hhsuite_dbs/a3m/

/home/jh7x3/multicom/src/update_db/tools/hhsuite/joinhmm2db.pl

