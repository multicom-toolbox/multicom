#!/bin/sh

#inputs: multiple sequence alignment file, output file

 #calculate ffas profiles
export FFAS=/home/jh7x3/multicom_beta1.0/src/update_db/tools/ffas
export PATH=$PATH:/home/jh7x3/multicom_beta1.0/src/update_db/tools/ffas/soft

#cat 1UCSA.ffas.mu | profil > 1UCSA.ffas 
#profil 1UCSA.ffas.mu > ff_T0579

cat $1 | profil >> $2

