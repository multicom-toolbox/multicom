#!/bin/sh

#input file, output file
if [ $# -ne 3 ]
then
	echo "need input file, output file, evalue(1.0)."
	exit 1
fi

#1: gapped
#0: not filter low complexity

#use NR
#evalue 1.0
#~/prosys/script/cm_psiblast_temp.pl ~/pspro/blast2.2.8 ~/pspro/data/nr/nr ~/prosys/database/cm/pdb_cm $1 $2 1

#not use NR
#evalue 1.0
~/prosys/script/cm_psiblast_temp.pl ~/pspro/blast2.2.8 none ~/prosys/database/cm/pdb_cm $1 $2 $3 




