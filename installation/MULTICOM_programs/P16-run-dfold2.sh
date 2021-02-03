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

mkdir -p $outputdir/dfold2_r

cd $outputdir

python /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/tools/dfold2//src/DFOLD_v3.py -f $fastafile -d $outputdir/disthbond/real_dist/$targetid.dist.rr -b $outputdir/disthbond/$targetid.hbond.tbl -n $outputdir/disthbond/$targetid.ssnoe.tbl -p $outputdir/disthbond/full_length/msa/psipred/$targetid.ss2  -mout 10 -out $outputdir/dfold2_r/  2>&1 | tee  dfold2_r.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/dfold2_r.log>\n\n"


if [[ ! -f "$outputdir/dfold2_r/dfold2_r1.pdb" ]];then
        printf "!!!!! Failed to run dfold2, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/tools/dfold2/>\n\n"
else
        printf "\nJob successfully completed!"
        cp $outputdir/dfold2_r/dfold2_r1.pdb $outputdir/$targetid.pdb
        printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

mkdir -p $outputdir/dfold2_m

cd $outputdir

python /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/tools/dfold2//src/DFOLD_v3.py -f $fastafile -d $outputdir/disthbond/mul_class/$targetid.dist.rr -b $outputdir/disthbond/$targetid.hbond.tbl -n $outputdir/disthbond/$targetid.ssnoe.tbl -p $outputdir/disthbond/full_length/msa/psipred/$targetid.ss2  -mout 10 -out $outputdir/dfold2_m/  2>&1 | tee  dfold2_m.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/dfold2_m.log>\n\n"


if [[ ! -f "$outputdir/dfold2_m/dfold2_m1.pdb" ]];then
        printf "!!!!! Failed to run dfold2, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/tools/dfold2/>\n\n"
else
        printf "\nJob successfully completed!"
        cp $outputdir/dfold2_m/dfold2_m1.pdb $outputdir/$targetid.pdb
        printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
