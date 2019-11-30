#!/bin/sh


if [ $# -lt 3 ]
then
	echo "need at least three parameters : target id, path of fasta sequence, directory of output"
	exit 1
fi

workdir=$1 #
targetid=$2 #
outputdir=$3 #




source /home/jhou4/tools/multicom/tools/python_virtualenv/bin/activate
#export PATH=/home/jhou4/tools/multicom/tools/R-3.2.0/bin/:$PATH
perl /home/jhou4/tools/multicom/src/visualize_multicom_cluster/P1_organize_prediction.pl  $workdir $targetid  $outputdir


