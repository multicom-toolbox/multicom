#!/usr/bin/perl -w
#####################################################################
#Convert dataset(fold recognition) to svm ranking dataset.
#Inputs: input dataset, pair-list, output file name
#each query protein is assinged a query id
#all the targets are assigned an order: ..., 4, 3, 2, 1. to reflect the rank
#(bigger number means rank is higher (a little conter-intuitive) )
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

$query_id = 1; 
@group = (); 
@pairs = (); 
$pre_prot = ""; 
while(@set)
{
	$pair = shift @set;
	($prot1, $prot2) = split(/\s+/, $pair); 
	shift @set;
	$feature = shift @set;
	shift @set; 

	if ( ($prot1 ne $pre_prot && $pre_prot ne "") || @set == 0 )
	{

		#output all the targets for the query
		if (@set == 0 && $prot1 eq $pre_prot)
		{ 
		#WARNING: this code still has one bug when the last group only has one entry.
			push @group, $feature; 
			push @pairs, $pair; 
		}

		$ord = @group; 
		for ($i = 0; $i < $ord; $i++)
		{
			@attrs = split(/\s+/, $group[$i]); 
			#if (@attrs != 72)
			if (@attrs != 69)
			{
				die "the number of feature doesn't match.\n";
			}
			print OUT "#$pairs[$i]";
			print OUT $ord - $i;
			print OUT " qid:$query_id";
			#for ($j = 1; $j <= 72; $j++)
			for ($j = 1; $j <= 69; $j++)
			{
				print OUT " $j:$attrs[$j-1]"; 
			}
			print OUT "\n"; 
		}

		$query_id++; 

		@group = ();
		@pairs = (); 

		if (@set > 0)
		{
			push @group, $feature; 
			push @pairs, $pair; 
		}
	}
	else
	{
		push @group, $feature; 
		push @pairs, $pair; 
	}
	$pre_prot = $prot1; 
}
close OUT; 
