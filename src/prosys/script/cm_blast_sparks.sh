#!/bin/sh

#input file, output file
if [ $# -ne 2 ]
then
	echo "need input file, output file."
	exit 1
fi

#1: gapped
#0: not filter low complexity
~/prosys/script/cm_blast_temp.pl ~/pspro/blast2.2.8 /home/jianlinc/prosys/database/sparks/sparks  $1 $2 1 0



