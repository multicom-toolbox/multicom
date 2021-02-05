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

mkdir -p $outputdir/sbl

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhblits3/script/tm_sbl_main.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhblits3/sbl_option $fastafile  sbl  2>&1 | tee  sbl.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/sbl.log>\n\n"


if [[ ! -f "$outputdir/sbl/sbl1.pdb" ]];then
	printf "!!!!! Failed to run sbl, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/sbl/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/sbl/sbl1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi