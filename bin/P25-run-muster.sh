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

mkdir -p $outputdir/muster

cd $outputdir
perl /home/jhou4/tools/multicom/src/meta/muster/script/tm_muster_main.pl /home/jhou4/tools/multicom/src/meta/muster/muster_option_version4 $fastafile muster  2>&1 | tee  muster.log
perl /home/jhou4/tools/multicom/src/meta/muster/script/filter_identical_muster.pl muster

printf "\nFinished.."
printf "\nCheck log file <$outputdir/muster.log>\n\n"


if [[ ! -f "$outputdir/muster/muster1.pdb" ]];then 
	printf "!!!!! Failed to run muster, check the installation </home/jhou4/tools/multicom/src/meta/muster/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/muster/muster1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
