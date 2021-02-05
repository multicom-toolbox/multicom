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

mkdir -p $outputdir/disrank

cd $outputdir

sh /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/disrank/run_disrank.sh $targetid $fastafile $outputdir/hhsuite/ $outputdir/disthbond/full_length/ensemble/pred_map_ensem/real_dist/$targetid.txt $outputdir/disrank  2>&1 | tee  disrank.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/disrank.log>\n\n"


if [[ ! -f "$outputdir/disrank/disrank1.pdb" ]];then
	printf "!!!!! Failed to run disrank, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/disrank/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/disrank/disrank1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi