#!/usr/bin/perl -w
##################################################################
#Find missing pairs in pair.list, but not in stx-stx(rank.txt)
#Inputs: pair.list, rank.txt, and output file
#Author: Jianlin Cheng
#Date: 4/22/05
##################################################################

if (@ARGV != 3)
{
	die "need three parameters: pair list, rank list, output file.\n";
}
$pair_file = shift @ARGV;
$rank_file = shift @ARGV;
$out_file = shift @ARGV;

open(PAIR, $pair_file) || die "can't open pair file.\n";
@pair = <PAIR>;
shift @pair; 
close PAIR;

open(RANK, $rank_file) || die "can't open ranking file.\n";
@rank = <RANK>;
close RANK; 

open(OUT, ">$out_file") || die "can't write output file.\n";

foreach $entry (@pair)
{
	($prot1, $prot2, @other) = split(/\s+/, $entry);
	$found = 0; 
	foreach $record (@rank)
	{
		($name1, $name2, @other) = split(/\s+/, $record);
		if ( ($prot1 eq $name1 && $prot2 eq $name2))
		{
			$found = 1; 
		}
	}
	if ($found == 0)
	{
		print OUT "$prot1 $prot2\n";
	}
}
close OUT;


