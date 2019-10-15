#!/bin/sh


if [ $# -lt 3 ]
then
	echo "need at least three parameters : target id, path of fasta sequence, directory of output"
	exit 1
fi

workdir=$1 #
targetid=$2 #
outputdir=$3 #




source /home/test/jie_test/multicom/tools/python_virtualenv/bin/activate
#export PATH=/home/test/jie_test/multicom/tools/R-3.2.0/bin/:$PATH
perl /home/test/jie_test/multicom/src/visualize_multicom_construct/P1_organize_prediction.pl  $workdir $targetid  $outputdir


