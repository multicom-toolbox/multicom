#!/bin/sh

#input file, output file
if [ $# -ne 2 ]
then
	echo "need input file, output file."
	exit 1
fi

#1: gapped
#0: not filter low complexity

#use NR
~/prosys/script/cm_psiblast_temp.pl ~/pspro/blast2.2.8 ~/pspro/data/nr/nr ~/prosys/database/cm/pdb_cm $1 $2

