#!/bin/sh

if [ $# -ne 2 ]
then
	echo "need two parameters: input sequence file and output directory.";
	exit 1
fi

##############################################################################
#If the models have not been generated in the output directory, it will generate models, rank them, and combine them.
#If the models have been generated in teh output directory, it will only rank and combine them
##############################################################################

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/multicom_system/script/multicom_va.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/multicom_system/multicom_option_v8_newdb $1 $2


