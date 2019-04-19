#!/usr/bin/perl -w
########################################################################
#Split a dataset into n-folds sequentially (each line is a record)
#Input: dataset file, number_of_folds, output file prefix
#Author: Jianlin Cheng
#Date: 5/18/05
########################################################################
if (@ARGV != 3)
{
	die "need three parameters: dataset file, number_of_folds, output_prefix\n"; 
}
$dataset = shift @ARGV;
$fold_num = shift @ARGV;
$out_prefix = shift @ARGV;

open(SET, $dataset) || die "can't read dataset file.\n";
@set = <SET>;
close SET; 

if ($fold_num < $fold_num)
{
	die "fold number > number of data points.\n"; 
}

$ave_num = @set / $fold_num;
$ave_num = int($ave_num); 

#create files
for ($i = 0; $i < $fold_num; $i++)
{
	$group[$i] = ""; 
}

for ($i = 0; $i < $fold_num; $i++)
{
	for ($j = 0; $j < $ave_num; $j++)
	{
		$line = shift @set; 
		$group[$i] .= $line; 
	}
}

#add the left to last fold 
$group[$fold_num-1] .= join("", @set); 

#output all files
for ($i = 1; $i <= $fold_num; $i++)
{
	open(OUT, ">$out_prefix$i") || die "can't create output file.\n"; 
	print OUT $group[$i-1]; 
	close OUT; 
}
