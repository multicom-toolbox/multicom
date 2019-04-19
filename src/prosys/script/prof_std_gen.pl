#!/usr/bin/perl -w
########################################################
# Create msa and profile for a fasta sequence
# Input: 
#   1. pspro path
#   2. prosys path
#   3. fasta file
#   4. msa output file
#   5. profile output file
# Author: Jianlin Cheng, 1/17/05
########################################################

if (@ARGV != 5)
{
	die "need five params: pspro path, prosys path, fasta seqeunce, msa output, profile output.\n";
}

$pspro = shift @ARGV;
$prosys = shift @ARGV;
$fasta = shift @ARGV;
$msa = shift @ARGV; 
$prof = shift @ARGV; 

#generate alignment file
system("$pspro/bin/generate_flatblast.sh $fasta $msa");

#generate profile
system("$prosys/script/msa2prof.pl $fasta $msa $prof"); 
