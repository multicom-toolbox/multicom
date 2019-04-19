#!/usr/bin/perl -w
#######################################################################
#
#Conver the data set file to fasta file
#Assume the data entry is separated by blank line. For each entry: first three lines are: name, length, sequence
#filter sequence according to the number of Cysteines
#Author: Jianlin Cheng, May 23, 2004
#
######################################################################

if (@ARGV != 2)
{
	die "need two parameters: input data set file, output fasta file.\n";
}

open(DATASET, "$ARGV[0]") || die "can't open the input data set file.\n";
open(OUTPUT, ">$ARGV[1]") || die "can't create the output file.\n";

$num = 0; 
$count = 0; 
while (<DATASET>)
{
	$line = $_;
	if ($line eq "\n")
	{
		$count = 0; 
		next; 
	}
	$count++;
	if ($count == 1)
	{
		$name = $line; 
	}
	
	if ($count == 2)
	{
		chomp $line; 
		$length = $line; 
	}
	if ($count == 3)
	{
		chomp $line; 
		@aas = split(/\s+/, $line); 
		if (@aas != $length)
		{
			print "$name, $length\n"; 
			print "$line\n";
			die "sequence length doesn't match.\n"; 
		}
		$seq = join("", @aas);
		print OUTPUT ">$name";
		print OUTPUT "$seq\n"; 
		$num++; 
	}
	
}
close(DATASET);
close(OUTPUT); 
print "total number of sequence: $num\n"; 
