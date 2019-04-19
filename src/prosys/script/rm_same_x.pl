#!/usr/bin/perl -w
################################################################################
#remove same sequence from dataset
#Also remove all X sequence
#input: 10-line dataset (pdb_select.set)
#output: 10-line non-same dataset (pdb_cm.set): comparative modeling dataset
#Modified from rm_same.pl
#Author: Jianlin Cheng
#Date: 8/5/2005
################################################################################

if (@ARGV != 2)
{
	die "need two parameters: input data set, output dataset.\n";
}

$input = shift @ARGV;
$output = shift @ARGV;

@seqs = ();

open(INPUT, "$input") || die "can't read input file: $input\n";
open(OUTPUT, ">$output") || die "can't create output file.\n"; 

$keep = 0;
$delete = 0; 
$all_x = 0; 
while (<INPUT>)
{
	$name = $_;
	$res = <INPUT>;
	$length = <INPUT>;
	$seq = <INPUT>;
	$ss = <INPUT>;
	$bp1 = <INPUT>;
	$bp2 = <INPUT>;
	$sa = <INPUT>;
	$xyz = <INPUT>;
	$blank = <INPUT>;
	@vec_seq = split(/\s+/, $seq);
	@vec_ss = split(/\s+/, $ss);
	@vec_sa = split(/\s+/, $sa);
	if ($length != @vec_seq || $length != @vec_ss || $length != @vec_sa)
	{
		die "$name, length is not consistent.\n";
	}

	$join_seq = $seq;
	$join_seq =~ s/\s//g; 
	if ($join_seq =~ /^X+$/)
	{
		$all_x++; 
		next; 
	}

	#check if uniq
	$uniq = 1; 
	foreach $entry (@seqs)
	{
		if ($entry eq $seq)
		{
			$uniq = 0;
			last; 
		}
	}
	if ($uniq == 1)
	{
		push @seqs, $seq; 
		print OUTPUT "$name$res$length$seq$ss$bp1$bp2$sa$xyz$blank";
		$keep++; 
	}
	else
	{
		$delete++; 
	}
}
close INPUT;
close OUTPUT;
print "num of selected chains: $keep, num of removed chains by same: $delete\n";
print "num of revmoed all-X sequence: $all_x\n"; 
