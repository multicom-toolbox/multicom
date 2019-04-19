#!/usr/bin/perl -w
#####################################################################
#Convert dataset(fold recognition) to svm binary classification set.
#Inputs: input dataset, pair-list, output file name
#set all the pairs in the same fold as "+", otherwise "-"
#The number of true pairs might be more than that in pair list because
#the pair list might not include all pairs in the same fold
#scop idx: ##.##(arch).##(fold).##(super).##(fami).##
#Date: 5/19/2005
#Modified: 8/8/2005
#add one more parameter: feature number
#Author: Jianlin Cheng
#####################################################################

if (@ARGV != 4)
{
	die "need four parameters: input dataset file, pair list,  output file name, feature number.\n";
}
$set_file = shift @ARGV;
$pair_file = shift @ARGV;
$out_file = shift @ARGV;
$feature_num = shift @ARGV;

open(SET, $set_file) || die "can't read dataset file.\n";
@set = <SET>;
close SET; 

#%pairs = (); 
open(PAIR, $pair_file) || die "can't read pair file.\n";
@ents = <PAIR>;
shift @ents; 
while (@ents)
{
	$record = shift @ents;
	($prot1, $prot2, $code1, $code2) = split(/\s+/, $record);
	@codes = split(/\./, $code1);
	#the first 3-fields to identify the fold
	$fold1 = "$codes[0]-$codes[1]-$codes[2]";
	@codes = split(/\./, $code2);
	$fold2 = "$codes[0]-$codes[1]-$codes[2]";
	if (!exists($ents{$prot1}))
	{
		$ents{$prot1} = $fold1; 
	}
	else
	{
		if ($ents{$prot1} ne $fold1)
		{
			die "fold id is not consistent.\n";
		}
	}
	if (!exists($ents{$prot2}))
	{
		$ents{$prot2} = $fold2; 
	}
	else
	{
		if ($ents{$prot2} ne $fold2)
		{
			die "fold id is not consistent.\n";
		}
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";

$pos = 0;
$neg = 0; 
while(@set)
{
	$pair = shift @set;
	($prot1, $prot2) = split(/\s+/, $pair); 
	shift @set;
	$feature = shift @set;
	shift @set; 

	$label = "-1";
	if ($ents{substr($prot1,1)} eq $ents{substr($prot2,1)})
	{
		$label = "+1";	
		$pos++;
	}
	else
	{
		$neg++; 
	}


	@attrs = split(/\s+/, $feature); 
	if (@attrs != $feature_num)
	{
		die "the number of feature doesn't match.\n";
	}
	print OUT "#$pair";
	print OUT $label;
	for ($i = 1; $i <= $feature_num; $i++)
	{
		print OUT " $i:$attrs[$i-1]"; 
	}
	print OUT "\n"; 
}
close OUT; 
print "number of positive: $pos, number of negative: $neg\n"; 
