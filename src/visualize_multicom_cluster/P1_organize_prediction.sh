#!/bin/sh


if [ $# -lt 3 ]
then
	echo "need at least three parameters : target id, path of fasta sequence, directory of output, contact file (optional)"
	exit 1
fi

workdir=$1 #
targetid=$2 #
outputdir=$3 #




source /home/jh7x3/multicom_beta1.0/tools/python_virtualenv/bin/activate
perl /home/jh7x3/multicom_beta1.0/src/visualize_multicom_cluster/P1_organize_prediction.pl  $workdir $targetid  $outputdir


