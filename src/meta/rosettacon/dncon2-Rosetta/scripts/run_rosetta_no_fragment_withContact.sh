#!/bin/bash
###############################################################################
# Name %n  : run_rosetta.sh with contact constraints
# Desc %d  : 
# Input %i : 
# Output %o: 
#
# Author: Jesse Eickholt,Jie Hou
# Date: Nov 10 2009
# ID: %#2ff798b730 Tags: %t 
# Revision: Jianlin Cheng, 12/25/2009
# Revision: Jie Hou, 03/21/2018
###############################################################################

export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/multicom/tools/rosetta_bin_linux_2018.09.60072_bundle/main/source/build/src/release/linux/3.10/64/x86/gcc/4.8/static/:$LD_LIBRARY_PATH

ROSETTA_PATH='/data/jh7x3/multicom_github/multicom/tools/rosetta_bin_linux_2018.09.60072_bundle'
NNMAKE_PATH=$ROSETTA_PATH/rosetta_fragments/nnmake
#OUTPUT_DIR='/data/rosetta3.1'

if [[ $# -lt 6 ]]; then
  echo "Usage: $0 <fasta_file> <5-char_id> <output_dir> <num of structures> <constraints> <weight>";
  exit;
fi

id=$2
OUTPUT_DIR=$3
NUM_OF_STRUCTURES=$4
CONSTRAINTS=$5
WEIGHT=$6

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
#echo "Creating fragment files for $fasta...";
#$NNMAKE_PATH/make_fragments.pl -nojufo -noprof -nosam -xx aa -id "$id" $fasta
#mv -v $OUTPUT_DIR/aa$20* $OUTPUT_DIR/ 
#echo "done"

#cst_file
#cst_fa_file
#cst_weight
#cst_fa_weight

# Run Rosetta
echo "Running Rosetta...";
echo "$ROSETTA_PATH/main/source/bin/AbinitioRelax.static.linuxgccrelease -in:file:fasta $fasta -database $ROSETTA_PATH/main/database/ -in:file:frag9 aa"$id"09_05.200_v1_3 -in:file:frag3 aa"$id"03_05.200_v1_3 -cst_file $CONSTRAINTS -cst_weight $WEIGHT -out:pdb -out:nstruct $NUM_OF_STRUCTURES\n\n";
$ROSETTA_PATH/main/source/bin/AbinitioRelax.static.linuxgccrelease -in:file:fasta $fasta\
 -database $ROSETTA_PATH/main/database/ -in:file:frag9 aa"$id"09_05.200_v1_3\
 -in:file:frag3 aa"$id"03_05.200_v1_3 -cst_file $CONSTRAINTS -cst_weight $WEIGHT -out:pdb -out:nstruct $NUM_OF_STRUCTURES

echo "done"

echo "Moving pdb files";
for i in `ls S_*.pdb`; do
  mv -v $i $id-`echo $i | sed -e 's/S_0*//'` 
done 

echo "done"

mv -v default.out "$id"_default.out
mv -v score.fsc "$id"_score.fsc

popd

echo "Cleaning up...";
rm $fasta
echo "done";
