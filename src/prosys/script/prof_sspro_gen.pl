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

open(FASTA, "$fasta") || die "can't read input fasta file.\n"; 
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$seq = <FASTA>; 
chomp $seq;
$length = length($seq); 
close FASTA;

open(INPUT, ">$fasta.in") || die "can't create input file.\n"; 
print INPUT "1 20 3\n"; 
print INPUT "$name\n";
print INPUT $length, "\n"; 
for ($i = 0; $i < $length; $i++)
{
	print INPUT substr($seq, $i, 1), " "; 
}
print INPUT "\n"; 
for ($i = 0; $i < $length; $i++)
{
	print INPUT "H "; 
}
print INPUT "\n"; 
for ($i = 0; $i < $length; $i++)
{
	print INPUT "1 "; 
}
print INPUT "\n"; 
for ($i = 0; $i < $length; $i++)
{
	print INPUT "1 "; 
}
print INPUT "\n"; 
for ($i = 0; $i < $length; $i++)
{
	print INPUT "1 "; 
}
print INPUT "\n"; 
for ($i = 0; $i < $length; $i++)
{
	print INPUT "1 1 1 "; 
}
print INPUT "\n"; 
print INPUT "\n"; 


#generate alignment file
system("$pspro/bin/generate_flatblast.sh $fasta $name");

#generate profile
system("$prosys/bin/prof $fasta.in $prof ./"); 
`mv $name $msa`; 
`rm $fasta.in`; 
