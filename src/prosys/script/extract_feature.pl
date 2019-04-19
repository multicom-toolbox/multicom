#!/usr/bin/perl -w
##############################################################################
#Extract fold recognition features for a pair of proteins.
#Input: script dir, option file, fasta dataset, pair list(rank_oneway.txt), output file.
#option file includes: the input dir contains chk, pssm, align, set, cm, bcm, hmm... files.
#Output file format: pair (id1,id2), pairing infor from sarf, features
#Author: Jianlin Cheng
#Date: 05/16/2005
###############################################################################
if (@ARGV != 5)
{
	die "need five parameters: script dir, feature option file, fasta dataset(rych_full.fasta), pair list file(rank_oneway.txt), output file.\n"; 
}
$script_dir = shift @ARGV;
$option_file = shift @ARGV; 
$fasta_set = shift @ARGV; 
$rank_file = shift @ARGV;
$out_file = shift @ARGV;

-d $script_dir || die "can't open script dir.\n";
-f $option_file || die "can't read option file.\n"; 

#read fasta dataset.
%name2seq = (); 
open(FASTA, $fasta_set) || die "can't read fasta file.\n"; 
@fasta = <FASTA>;
close FASTA; 
while (@fasta)
{
	$name = shift @fasta; 
	chomp $name;
	$name = substr($name, 1); 
	$seq = shift @fasta;
	chomp $seq; 
	$name2seq{$name} = $seq; 
}
close FASTA; 

open(OUT, ">$out_file") || die "can't create output file.\n"; 


open(RANK, $rank_file) || die "can't read ranked pair list file.\n"; 
@rank = <RANK>;
close RANK; 
while (@rank)
{
	$pair = shift @rank;
	chomp $pair;
	($query, $target, @other) = split(/\s+/, $pair); 
	#need to add "d" to each name
	$query = "d$query";
	$target = "d$target"; 
	print "process $query $target\n"; 
	#create query file
	if (!defined $name2seq{$query})
	{
		print "can't find sequence for $query.\n\n";
		next; 
	}
	if (!defined $name2seq{$target})
	{
		print "can't find sequence for $target.\n\n";
		next; 
	}
	open(QUERY, ">$query.fasta") || die "can't create query file.\n"; 
	print QUERY ">$query\n$name2seq{$query}\n"; 
	close QUERY; 
	open(TARGET, ">$target.fasta") || die "can't create target file.\n"; 
	print TARGET ">$target\n$name2seq{$target}\n"; 
	close TARGET; 

	#generate features
	system("$script_dir/feature_all.pl $query.fasta $target.fasta $option_file $query.out"); 
	if (!open(RES, "$query.out"))
	{
		`rm $query*.fasta $target*.fasta`; 
		 print "can't read output file.\n\n";
		 next; 
	}
	$pair_name = <RES>;

	#check the consistency
	($pa, $pb) = split(/\s+/, $pair_name);
	<RES>;
	$feature = <RES>;
	close RES;

	if ($pa ne $query || $pb ne $target)
	{
		print "pair ids don't match.\n"; 
		`rm $query*.fasta $target*.fasta $query*.out`; 
		next; 
	}

	print OUT "$pair_name", join(" ", @other), "\n$feature\n"; 
	print "\n";

	#clean up
	`rm $query*.fasta $target*.fasta $query*.out`; 
}
close OUT; 
