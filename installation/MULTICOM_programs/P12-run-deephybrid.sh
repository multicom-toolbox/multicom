#!/bin/bash

if [ $# != 4 ]; then
	echo "$0 <target id> <fasta> <msa> <output-directory>"
	exit
fi

targetid=$1
fastafile=$2
deepmsa=$3
outputdir=$4

mkdir -p $outputdir
cd $outputdir

if [[ "$fastafile" != /* ]]
then
   echo "Please provide absolute path for $fastafile"
   exit
fi

if [[ "$deepmsa" != /* ]]
then
   echo "Please provide absolute path for $deepmsa"
   exit
fi

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/deephybrid

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephybrid/script/tm_deephybrid_main_v2.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephybrid/deephybrid_option_v2 $fastafile $deepmsa deephybrid  2>&1 | tee  deephybrid.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/deephybrid.log>\n\n"


if [[ ! -f "$outputdir/deephybrid/dhybrid1.pdb" ]];then
	printf "!!!!! Failed to run deephybrid, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/meta/deephybrid/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/deephybrid/dhybrid1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
