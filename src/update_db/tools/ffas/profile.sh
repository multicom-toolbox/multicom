#!/bin/sh

#inputs: multiple sequence alignment file, output file

 #calculate ffas profiles 
export FFAS=/home/jhou4/tools/multicom/tools/ffas_soft/
export PATH=$PATH:/home/jhou4/tools/multicom/tools/ffas_soft/

#cat 1UCSA.ffas.mu | profil > 1UCSA.ffas 
#profil 1UCSA.ffas.mu > ff_T0579

cat $1 | profil >> $2

