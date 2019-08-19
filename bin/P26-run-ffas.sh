#!/bin/bash

if [ $# != 3 ]; then
	echo "$0 <target id> <fasta> <output-directory>"
	exit
fi

targetid=$1
fastafile=$2
outputdir=$3

mkdir -p $outputdir
cd $outputdir

if [[ "$fastafile" != /* ]]
then
   echo "Please provide absolute path for $fastafile"
   exit
fi

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/ffas

cd $outputdir
perl /storage/htc/bdm/jh7x3/multicom/src/meta/ffas/script/tm_ffas_main.pl /storage/htc/bdm/jh7x3/multicom/src/meta/ffas/ffas_option /storage/htc/bdm/jh7x3/multicom/examples/T1006.fasta ffas  2>&1 | tee  ffas.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/ffas.log>\n\n"


if [[ ! -f "$outputdir/ffas/ff1.pdb" ]];then 
	printf "!!!!! Failed to run ffas, check the installation </storage/htc/bdm/jh7x3/multicom/src/meta/ffas/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/ffas/ff1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi


