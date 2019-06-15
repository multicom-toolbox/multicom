#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_rosetta_$dtime/
cd /home/jh7x3/multicom/test_out/T1006_rosetta_$dtime/

mkdir rosetta2
mkdir rosetta_common
sh /home/jh7x3/multicom/src/meta/script/make_rosetta_fragment.sh /home/jh7x3/multicom/examples/T1006.fasta abini  rosetta_common 100 2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_rosetta_$dtime.log
cp -r rosetta_common/abini rosetta2
sh /home/jh7x3/multicom/src/meta/script/run_rosetta_no_fragment.sh /home/jh7x3/multicom/examples/T1006.fasta abini rosetta2 100


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_rosetta_$dtime.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_rosetta_$dtime/rosetta2/abini/abini-1.pdb" ]];then 
	printf "!!!!! Failed to run rosetta, check the installation </home/jh7x3/multicom/src/meta/script/run_rosetta_no_fragment.sh>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_rosetta_$dtime/rosetta2/abini/abini-1.pdb\n\n"
fi

