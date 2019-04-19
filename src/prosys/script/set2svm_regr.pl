#!/usr/bin/perl -w
#####################################################################
#Convert dataset(fold recognition) to svm regression set.
#Inputs: input dataset, output file name
#Date: 5/19/2005
#Author: Jianlin Cheng
#####################################################################

if (@ARGV != 2)
{
	die "need two parameters: input dataset file, output file name.\n";
}
$set_file = shift @ARGV;
$out_file = shift @ARGV;

open(SET, $set_file) || die "can't read dataset file.\n";
@set = <SET>;
close SET; 

open(OUT, ">$out_file") || die "can't create output file.\n";

while(@set)
{
	$pair = shift @set;
	$target = shift @set;
	$feature = shift @set;
	shift @set; 

	@values = split(/\s+/, $target);
	$regr = $values[1];
	@attrs = split(/\s+/, $feature); 
	if (@attrs != 69)
	{
		die "the number of feature doesn't match.\n";
	}
	print OUT "#$pair";
	print OUT $regr;
	for ($i = 1; $i <= 69; $i++)
	{
		print OUT " $i:$attrs[$i-1]"; 
	}
	print OUT "\n"; 
}
close OUT; 
