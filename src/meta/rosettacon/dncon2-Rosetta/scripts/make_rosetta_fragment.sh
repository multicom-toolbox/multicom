#!/bin/bash
###############################################################################
# Name %n  : run_rosetta.sh
# Desc %d  : 
# Input %i : 
# Output %o: 
#
# Author: Jesse Eickholt
# Date: Nov 10 2009
# ID: %#2ff798b730 Tags: %t 
# Revision: Jianlin Cheng, 12/25/2009
###############################################################################

ROSETTA_PATH='/home/jh7x3/multicom_beta1.0/tools/rosetta_bin_linux_2018.09.60072_bundle'
NNMAKE_PATH=$ROSETTA_PATH/tools/fragment_tools/
#OUTPUT_DIR='/data/rosetta3.1'

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <fasta_file> <5-char_id> <output_dir> <num of structures>";
  exit;
fi

id=$2
OUTPUT_DIR=$3
NUM_OF_STRUCTURES=$4

if [[ ! -d $OUTPUT_DIR ]]; then
  mkdir -v $OUTPUT_DIR;
fi

#get abslute path
OUTPUT_DIR=`cd $3; pwd`

# Adjust filename if need be
basename "$1" | grep -q "[^A-Za-z._0-9]"
if [[ $? -eq 0 ]]; then
  echo "Fixing file name..."
  cp -v $1 $OUTPUT_DIR/$$_`basename $1 | sed -e 's/[^A-Za-z0-9.]/_/'`
  fasta=$OUTPUT_DIR/`basename $1 | sed -e 's/[^A-Za-z0-9.]/_/'`
else
  cp -v $1 $OUTPUT_DIR/$$_`basename $1`
  fasta=$OUTPUT_DIR/$$_`basename $1`
fi

# Adjust width of sequence, just in case
head -n 1 $fasta > $OUTPUT_DIR/$$_tmp_fasta
cat $fasta | sed -e '1 d' | tr -d '\n' | fold -w 60 >> $OUTPUT_DIR/$$_tmp_fasta
echo "" >> $OUTPUT_DIR/$$_tmp_fasta
mv $OUTPUT_DIR/$$_tmp_fasta $fasta

if [[ ${#2} -ne 5 ]]; then
  echo "Usage: $0 <fasta_file> <5-char_id> [seed]";
  echo " The id MUST be exactly 5 characters long";
  exit;
fi

if [[ ! -d $OUTPUT_DIR/$id ]]; then
  mkdir -v $OUTPUT_DIR/$id;
fi

pushd "$OUTPUT_DIR/$id" 
echo "current directory `pwd`";

if [[ -f default.out ]]; then
  rm -v default.out
fi

if [[ -f score.fsc ]]; then
  rm -v score.fsc
fi

# Create fragment files
echo "Creating fragment files for $fasta...";

#/home/chengji/cheng_group/rosetta3.1/rosetta_fragments/nnmake/make_fragments.pl
#$NNMAKE_PATH/make_fragments.pl -nojufo -noprof -nosam -xx aa -id "$id" $fasta
$NNMAKE_PATH/make_fragments.pl  -old_name_format -id "$id" $fasta
#mv -v $OUTPUT_DIR/aa$20* $OUTPUT_DIR/ 
echo "done"

popd
