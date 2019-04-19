#!/bin/sh

#input file, output file
if [ $# -ne 3 ]
then
	echo "need input file, output file, evalue(1.0)."
	exit 1
fi

#1: gapped
#0: not filter low complexity
#1: e-value threshold for choosing templates 
~/prosys/script/cm_blast_temp.pl ~/pspro/blast2.2.8 ~/prosys/database/cm/pdb_cm $1 $2 1 0 $3 



