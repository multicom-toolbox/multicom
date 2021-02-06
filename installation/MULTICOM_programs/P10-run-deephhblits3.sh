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

mkdir -p $outputdir/deephhblits3

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephhblits3/script/tm_deephhblits3_main.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephhblits3/deephhblits3_option $fastafile $deepmsa deephhblits3  2>&1 | tee  deephhblits3.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/deephhblits3.log>\n\n"


if [[ ! -f "$outputdir/deephhblits3/dhhbl1.pdb" ]];then
	printf "!!!!! Failed to run deephhblits3, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephhblits3/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/deephhblits3/dhhbl1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
