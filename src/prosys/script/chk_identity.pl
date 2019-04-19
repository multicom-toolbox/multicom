#!/usr/bin/perl -w

##########################################################################################################
#Compute the sequence identity of two sequnces using global pairwise alignment.
#Inputs: script dir, clustalw, query file, query format,  target file, target format
#Output: alignment, and scores
#identity = number of identical residues / length of query. 
#Author: Jianlin Cheng
#Date: 8/3/2005
###########################################################################################################

if (@ARGV != 6)
{
	die "need 6 parameters: script_dir, clustalw dir, query file, query format(fasta, cmap, bmap, nine, ten), target file, target format.\n";
}


#support sequence alignment tools: clustwal, palign, fasta, blast(how to?)
$script_dir = shift @ARGV;
require "$script_dir/syslib.pl";
$align_dir = shift @ARGV;
$query_file = shift @ARGV;
$qformat = shift @ARGV;
$target_file = shift @ARGV;
$tformat = shift @ARGV;

-d $script_dir || die "can't find script dir.\n";
-d $align_dir || die "can't find alignment tool dir.\n"; 

#create fasta file
$file1 = "$query_file.fasta";
#$file2 = "$target_file.fasta";

open(IN, $query_file) || die "can't read query file.\n";
@content = <IN>;
close IN;
$seq1 = &get_seq(\@content, $qformat);
open(FASTA, ">$file1") || die "can't create $file1\n";
print FASTA ">seq1\n$seq1\n";
#close FASTA;

$query_length = length($seq1); 

open(IN, $target_file) || die "can't read query file.\n";
@content = <IN>;
close IN;
$seq2 = &get_seq(\@content, $tformat);
#open(FASTA, ">$file2") || die "can't create $file2\n";
print FASTA ">seq2\n$seq2\n";
close FASTA;

#`cat $file1 $file2 > $file1.tmp`;	
#`mv $file1.tmp $file1`;

#system("$align_dir/clustalw -TYPE=PROTEIN -PWMATRIX=BLOSUM -INFILE=$file1 -OUTFILE=$query_file.clu > $query_file.out");
system("$align_dir/clustalw -TYPE=PROTEIN -PWMATRIX=BLOSUM -INFILE=$file1 -OUTFILE=$query_file.clu > /dev/null");

open(OUT, "$query_file.clu") || die "can't open alignment file.\n";
@ali = <OUT>;
close OUT; 

$alignment1 = "";
$alignment2 = "";

while (@ali)
{
	$line = shift @ali;
	chomp $line; 
	if ($line =~ /^seq1/)
	{
		@elements = split(/\s+/, $line); 	
		if ($elements[0] eq "seq1")
		{
			$alignment1 .= $elements[1]; 
		}
	}
	if ($line =~ /^seq2/)
	{
		@elements = split(/\s+/, $line); 	

		if ($elements[0] eq "seq2")
		{
			$alignment2 .= $elements[1]; 
		}
	}
}

#computer the identity
$total = 0;
$ind = 0; 
for ($i = 0; $i < length($alignment1); $i++)
{
	if (substr($alignment1, $i, 1) ne "-")
	{
		$total++;
		if ( substr($alignment1, $i, 1) eq substr($alignment2, $i, 1) )
		{
			$ind++; 
		}
	}
}

if ($total != $query_length)
{
	die "the query length doesn't match with the alignment.\n";
}

$ind /= $total;

print "identity with respect the query = $ind\n";

print "$alignment1\n$alignment2\n";

`rm $file1 $query_file.dnd $query_file.clu`; 

