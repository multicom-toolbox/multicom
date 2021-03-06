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

mkdir -p $outputdir/csblast

cd $outputdir
perl /home/jhou4/tools/multicom/src/meta/csblast/script/multicom_csblast_v2.pl /home/jhou4/tools/multicom/src/meta/csblast/csblast_option $fastafile csblast  2>&1 | tee  csblast.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/csblast.log>\n\n"


if [[ ! -f "$outputdir/csblast/csblast1.pdb" ]];then 
	printf "!!!!! Failed to run csblast, check the installation </home/jhou4/tools/multicom/src/meta/csblast/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/csblast/csblast1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

