#!/usr/bin/perl -w
#####################################################################
#Convert linda dataset(fold recognition) to svm binary classification set.
#Inputs: input dataset, id list file, output file name
#set all the pairs in the same fold as "+", otherwise "-"
#scop idx: ##(arch)-##(fold)-##(super)-##(fami)
#Date: 8/03/2005
#Author: Jianlin Cheng
#####################################################################

if (@ARGV != 3)
{
	die "need three parameters: input dataset file, pair list,  output file name.\n";
}
$set_file = shift @ARGV;
$pair_file = shift @ARGV;
$out_file = shift @ARGV;


#%pairs = (); 
open(PAIR, $pair_file) || die "can't read pair file.\n";
@ents = <PAIR>;
close PAIR; 
while (@ents)
{
	$record = shift @ents;
	($id, $fullname) = split(/\s+/, $record);
	($prot,$class, $pdb) = split(/\.+/, $fullname);

	@codes = split(/_/, $class);
	#the first 3-fields to identify the fold
	$fold = "$codes[0]-$codes[1]";

	print "fold = $fold\n";
	print "prot = $prot\n";
	#<STDIN>;


	if (!exists($ents{$prot}))
	{
		$ents{$prot} = $fold; 
	}
	else
	{
		if ($ents{$prot} ne $fold)
		{
			die "fold id is not consistent.\n";
		}
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";

$pos = 0;
$neg = 0; 

open(SET, $set_file) || die "can't read dataset file.\n";
@set = <SET>;
close SET; 

while(@set)
{
	$pair = shift @set;
	($prot1, $prot2) = split(/\s+/, $pair); 
	shift @set;
	$feature = shift @set;
	shift @set; 

	$label = "-1";
	

	if ($ents{$prot1} eq $ents{$prot2})
	{
		$label = "+1";	
		$pos++;
	}
	else
	{
		$neg++; 
	}


	@attrs = split(/\s+/, $feature); 
	if (@attrs != 69)
	{
		die "the number of feature doesn't match.\n";
	}
	print OUT "#$pair";
	print OUT $label;
	for ($i = 1; $i <= 69; $i++)
	{
		print OUT " $i:$attrs[$i-1]"; 
	}
	print OUT "\n"; 
}
close OUT; 
print "number of positive: $pos, number of negative: $neg\n"; 
