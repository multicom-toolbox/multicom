#!/usr/bin/perl -w
####################################################################
#Convert dataset (9-line, no title) into sequences (9-line too)
#Inputs: dataset file, output dir.
#Author: Jianlin Cheng
#Date: 05/16/2005
#####################################################################
if (@ARGV != 2)
{
	die "need two parameters: input dataset file, output dir.\n"; 
}
$dataset = shift @ARGV;
$out_dir = shift @ARGV; 

-d $out_dir || die "can't read output dir.\n"; 

open(DATASET, $dataset) || die "can't read dataset file.\n"; 

@records = (); 
while (<DATASET>)
{
	if ($_ ne "\n")
	{
		push @records, $_; 
	}
	else
	{
		$name = $records[0]; 
		chomp $name; 
		$seq_file = "$out_dir/$name.set"; 
		open(SEQ, ">$seq_file") || die "can't create sequence file.\n"; 
		print SEQ join("", @records), "\n"; 
		close SEQ; 
		@records = (); 
	}
}
close DATASET; 
