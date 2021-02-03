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

mkdir -p $outputdir/shh

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhsuite/script/tm_simple_hhsuite_main.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhsuite/simple_hhsuite_option $fastafile shh  2>&1 | tee  shh.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/shh.log>\n\n"


if [[ ! -f "$outputdir/shh/shh1.pdb" ]];then
	printf "!!!!! Failed to run shh, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/shh/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/shh/shh1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
