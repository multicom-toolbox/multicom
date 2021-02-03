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

mkdir -p $outputdir/hhsuite

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhsuite/script/tm_hhsuite_main_v2.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhsuite/hhsuite_option_v2 $fastafile hhsuite  2>&1 | tee  hhsuite.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhsuite.log>\n\n"


if [[ ! -f "$outputdir/hhsuite/hhsuite1.pdb" ]];then
	printf "!!!!! Failed to run hhsuite, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/meta/hhsuite/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhsuite/hhsuite1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
