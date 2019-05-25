#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosetta-$dtime/
cd /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosetta-$dtime/

mkdir rosetta2
mkdir rosetta_common
sh /data/jh7x3/multicom_github/jie_test/multicom/src/meta/script/make_rosetta_fragment.sh /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta abini  rosetta_common 100 2>&1 | tee  /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosetta-$dtime.log

sh /data/jh7x3/multicom_github/jie_test/multicom/src/meta/script/run_rosetta_no_fragment.sh /data/jh7x3/multicom_github/jie_test/multicom/examples/T0993s2.fasta abini rosetta2 100


printf "\nFinished.."
printf "\nCheck log file </data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosetta-$dtime.log>\n\n"


if [[ ! -f "/data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosetta-$dtime/rosetta2/denovo0.pdb" ]];then 
	printf "!!!!! Failed to run rosetta, check the installation </data/jh7x3/multicom_github/jie_test/multicom/src/meta/script/run_rosetta_no_fragment.sh>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /data/jh7x3/multicom_github/jie_test/multicom/test_out/T0993s2-rosetta-$dtime/rosetta2/denovo0.pdb\n\n"
fi

