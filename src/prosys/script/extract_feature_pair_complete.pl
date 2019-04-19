#!/usr/bin/perl -w
##############################################################################
#Extract fold recognition features for a pair of proteins.
#Input: script dir, option file, fasta dataset, file mapping file, output file, foldnumber.
#option file includes: the input dir contains chk, pssm, align, set, cm, bcm, hmm... files.
#Output file format: pair (id1,id2), pairing infor from sarf, features
#Author: Jianlin Cheng
#Date: 07/29/2005
#Modification: change from extract_feature_pair.pl to handle the file name mapping.
#support fold. right now: 10-fold splitting.
###############################################################################
if (@ARGV != 6)
{
	die "need six parameters: script dir, feature option file, fasta dataset(linda.fasta), filename mapping file,  output file, fold number(1-10).\n"; 
}
$script_dir = shift @ARGV;
$option_file = shift @ARGV; 
$fasta_set = shift @ARGV; 
$map_file = shift @ARGV;
$out_file = shift @ARGV;
$fold_num = shift @ARGV;

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

open(MAP, $map_file) || die "can't read map file.\n";
@id_list = (); 
while (<MAP>)
{
	chomp $_;
	($id, $name) = split(/\s+/, $_);
	$idx = index($name, ".");
	$name = substr($name, 0, $idx); 
	$id2name{$id} = $name; 
	push @id_list, $id; 
}
close MAP; 

open(OUT, ">$out_file") || die "can't create output file.\n"; 


$size = @id_list; 

#create folds (total number of proteins: 976)
@fold_start = (1, 101, 201, 301, 401, 501, 601, 701, 801, 901);
@fold_end   = (100, 200, 300, 400, 500, 600, 700, 800, 900, $size);  

#using indices.
$row_start = $fold_start[$fold_num-1] - 1; 
$row_end = $fold_end[$fold_num-1] - 1; 

for ($i = 0; $i < $size; $i++)
{
	if ($i < $row_start || $i > $row_end)
	{
		next; 
	}
	for ($j = 0; $j < $size; $j++)
	{
		if ($i == $j)
		{
			next; 
		}
		$query = $id_list[$i]; 
		$target = $id_list[$j]; 

		#convert query id and target id to name
		print "process $query $target: "; 
		if (exists $id2name{$query})
		{
			$query = $id2name{$query};
		}
		else
		{
			print "query id is not mapped to any file: $query\n";
			next;
		}
		if (exists $id2name{$target})
		{
			$target = $id2name{$target};
		}
		else
		{
			print "target id is not mapped to any file: $target\n";
			next;
		}
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
		system("$script_dir/feature_complete.pl $query.fasta $target.fasta $option_file $query.out"); 
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

		print OUT "$pair_name", "$feature\n"; 
		print "\n";

		#clean up
		`rm $query*.fasta $target*.fasta $query*.out`; 
	}
}
close OUT; 
