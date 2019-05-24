#!/bin/bash

dtime=$(date +%Y-%b-%d)


mkdir -p /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosetta-$dtime/
cd /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosetta-$dtime/

mkdir rosetta2
mkdir rosetta_common
sh /home/casp14/MULTICOM_TS/multicom/src/meta/script/make_rosetta_fragment.sh /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta abini  rosetta_common 100 2>&1 | tee  /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosetta-$dtime.log

sh /home/casp14/MULTICOM_TS/multicom/src/meta/script/run_rosetta_no_fragment.sh /home/casp14/MULTICOM_TS/multicom/examples/T0967.fasta abini rosetta2 100


printf "\nFinished.."
printf "\nCheck log file </home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosetta-$dtime.log>..\n\n"


if [[ ! -f "/home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosetta-$dtime/rosetta2/denovo0.pdb" ]];then 
	printf "!!!!! Failed to run rosetta, check the installation </home/casp14/MULTICOM_TS/multicom/src/meta/script/run_rosetta_no_fragment.sh>."
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/casp14/MULTICOM_TS/multicom/installation/test_out/T0967-rosetta-$dtime/rosetta2/denovo0.pdb\n\n"
fi

