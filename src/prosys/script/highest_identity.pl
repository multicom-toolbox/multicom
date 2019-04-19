#!/usr/bin/perl -w

##########################################################################################################
#Compute the hightest sequence identity of one sequence against  a fasta dataset.
#Inputs: script dir, clustalw, query file (fasta), target dataset(fasta) 
#Output: highest identity score, and qeury id and target id.
#identity = number of identical residues / length of query. 
#Author: Jianlin Cheng
#Date: 8/3/2005
###########################################################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: script_dir, clustalw dir, query file (fasta), target dataset file (fasta)\n";
}

$script_dir = shift @ARGV;
$align_dir = shift @ARGV;
$query_file = shift @ARGV;
$target_file = shift @ARGV;

-d $script_dir || die "can't find script dir.\n";
-d $align_dir || die "can't find alignment tool dir.\n"; 

open(IN, $query_file) || die "can't read query file.\n";
@content = <IN>;
close IN;
$query_name = shift @content;
$query_name = substr($query_name, 1); 
chomp $query_name; 

open(IN, $target_file) || die "can't read query file.\n";
@content = <IN>;
close IN;


$max_ind = -1;
$max_name = ""; 
while (@content)
{
	$target_name = shift @content;
	chomp $target_name; 
	$target_name = substr($target_name, 1); 


	$target_seq = shift @content;

	open(FASTA, ">$target_name.fas") || die "can't create $target_name.fas\n";
	print FASTA ">$target_name\n$target_seq\n";
	close FASTA;

	#compute pairwise identity
	#print("$script_dir/chk_identity.pl $script_dir $align_dir $query_file fasta $target_name.fas fasta > $query_file.ind");
	system("$script_dir/chk_identity.pl $script_dir $align_dir $query_file fasta $target_name.fas fasta > $query_file.ind");


	open(OUT, "$query_file.ind") || die "can't open alignment file.\n";
	$ind = <OUT>;
	close OUT; 
	if ($ind =~ /^identity.+= ([\.\d]+)/)
	{
		$ind = $1; 
		if ($ind > $max_ind)
		{
			$max_ind = $ind;
			$max_name = $target_name; 
		}
	}
	else
	{
		die "no identity score returns: query = $query_name, target = $target_name\n";
	}

	`rm $target_name.fas`; 
	`rm $query_file.ind`; 
}

print "highest identity=$max_ind\n";
print "query=$query_name target=$max_name\n"; 
