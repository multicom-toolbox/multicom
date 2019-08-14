#!/bin/sh


if [ $# -lt 3 ]
then
	echo "need at least three parameters : target id, path of fasta sequence, directory of output, contact file (optional)"
	exit 1
fi

workdir=$1 #
targetid=$2 #
outputdir=$3 #




source /storage/htc/bdm/jh7x3/multicom/tools/python_virtualenv/bin/activate
perl /storage/htc/bdm/jh7x3/multicom/src/visualize_multicom_cluster/P1_organize_prediction.pl  $workdir $targetid  $outputdir


