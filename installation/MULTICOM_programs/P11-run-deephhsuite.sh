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

mkdir -p $outputdir/deephhsuite

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephhsuite/script/tm_deephhsuite_main_v2.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/deephhsuite/deephhsuite_option_v2 $fastafile deephhsuite  2>&1 | tee  deephhsuite.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/deephhsuite.log>\n\n"


if [[ ! -f "$outputdir/deephhsuite/dhhsu1.pdb" ]];then
	printf "!!!!! Failed to run deephhsuite, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/meta/deephhsuite/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/deephhsuite/dhhsu1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi