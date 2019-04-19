#!/bin/sh
#blast a single sequence against a database
#We should use psi-blast to blast a profile to a database. 
~/pspro/blast2.2.8/blastall -i $1 -d ~/pspro/data/pdb_large/dataset -p blastp -F F -g F -o $2
#~/pspro/blast2.2.8/blastall -i $1 -d ~/pspro/data/pdb_large/dataset -p blastp  -o $2
