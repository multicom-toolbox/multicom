#!/bin/bash

if [ $# != 3 ]; then
        echo "$0 <target id> <fasta> <output-directory>"
        exit
fi

targetid = $1
fastafile = $2
outputdir = $3

mkdir -p $outputdir/unicon3d
cd $outputdir


source /storage/hpc/scratch/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/storage/hpc/scratch/jh7x3/multicom/tools/boost_1_55_0/lib/:/storage/hpc/scratch/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

perl /storage/hpc/scratch/jh7x3/multicom/src/meta/unicon3d/script/tm_unicon3d_main.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/unicon3d/Unicon3D_option $fastafile unicon3d  2>&1 | tee  unicon3d.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/unicon3d.log>\n\n"


if [[ ! -f "$outputdir/unicon3d/Unicon3d-1.pdb" ]];then 
	printf "!!!!! Failed to run unicon3d, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/unicon3d/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/unicon3d/Unicon3d-1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/unicon3d/Unicon3d-1.pdb\n\n"
fi

