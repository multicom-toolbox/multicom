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

mkdir -p $outputdir/hhblits3

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhblits3/script/tm_hhblits3_main.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhblits3/hhblits3_option_2020 $fastafile  hhblits3  2>&1 | tee  hhblits3.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhblits3.log>\n\n"


if [[ ! -f "$outputdir/hhblits3/hhbl1.pdb" ]];then
	printf "!!!!! Failed to run hhblits3, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhblits3/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhblits3/hhbl1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
