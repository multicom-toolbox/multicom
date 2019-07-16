#!/usr/bin/perl -w
################################################################################
#remove same sequence from fasta dataset
#Also remove all X sequence
#input: fasta dataset 
#output: filtered fasta dataset 
#Modified from rm_same_x.pl
#Author: Jianlin Cheng
#Date: 10/13/2005
################################################################################

if (@ARGV != 2)
{
	die "need two parameters: input fasta file, output fasta file.\n";
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
	$name =~ /^>/ || die "fasta file format error.\n";

	$seq = <INPUT>;
	chomp $seq;

	#filter out all x sequence.
	if ($seq =~ /^X+$/)
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
		print OUTPUT "$name$seq\n";
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
