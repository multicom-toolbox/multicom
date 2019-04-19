#!/usr/bin/perl -w
################################################################
#Select the pairs according to the queries in pair.list
#Input: rank_full.txt, pair.list, rank_query.txt
#Author: Jianlin Cheng
#Date: 4/29/05
#################################################################

if (@ARGV != 3)
{
	die "need three parameters: rank file, pair list, output file.\n";
}
$rank_file = shift @ARGV;
$pair_file = shift @ARGV;
$out_file = shift @ARGV;

open(PAIR, $pair_file) || die "can't read pair file.\n";
@pairs = <PAIR>;
shift @pairs;

@uniq = ();
foreach $pair (@pairs)
{
	($query, @other) = split(/\s+/, $pair);
	$found = 0;
	foreach $entry (@uniq)
	{
		if ($entry eq $query)
		{
			$found = 1; 
		}
	}
	if ($found == 0)
	{
		push @uniq, $query; 
	}
}
$num = @uniq; 
print "total number of uniq queries: $num\n";


#choose pairs
open(RANK, $rank_file) || die "can't read rank file.\n";
open(OUT, ">$out_file") || die "can't create output file.\n";

while(<RANK>)
{
	$line = $_;
	($query, @other) = split(/\s+/, $line);
	$found = 0;
	foreach $entry (@uniq)
	{
		if ($entry eq $query)
		{
			$found = 1; 
		}
	}
	if ($found == 1)
	{
		print OUT $line; 
	}
}
close RANK;
close OUT;

