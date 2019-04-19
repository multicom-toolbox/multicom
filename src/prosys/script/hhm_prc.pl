#!/usr/bin/perl -w
#########################################################################
#Do prof-prof alignment using hhm_prc.
#Input: hhmprc dir, hhm file1, hhm file2, output file
#Output: score, evalue, and alignments (local alignments)
#in the output file and stdout: print out: Feature num, score and logarithm
# of evalue
#Modified from hhm_search.pl
#Author: Jianlin Cheng
#Date: 7/25/2005
#########################################################################
if (@ARGV != 5)
{
	die "need five parameters: hhmprc dir, query fasta file, query hhm file(.hmm(hmmer format), or .prof(chk format)), target hhm file, ouptut file.\n";
}

$hhmprc_dir = shift @ARGV;
-d $hhmprc_dir || die "can't find hhmprc dir.\n";
if (!-f "$hhmprc_dir/prc-1.5.2-linux-i386")
{
	die "can't find hhmprc executable file.\n";
}

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find fasta sequence file.\n";
open(FASTA, $fasta_file);
$code1 = <FASTA>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <FASTA>;
chomp $seq1; 
close FASTA;
$query_length = length($seq1); 

$hhm_file1 = shift @ARGV;
-f $hhm_file1 || die "can't find hhm file 1: $hhm_file1.\n";

if ($hhm_file1 !~ /(.+)\.hmm$/ && $hhm_file1 !~ /(.+)\.prof$/)
{
	die "the suffix of the hhm file must be .hmm or .prof\n"; 
}

$hhm_file2 = shift @ARGV;
-f $hhm_file2 || die "can't find hhm file 2: $hhm_file2.\n";
if ($hhm_file2 !~ /(.+)\.hmm$/ && $hhm_file2 !~ /(.+)\.prof$/)
{
	die "the suffix of the hhm file must be .hmm or .prof\n"; 
}

$out_file = shift @ARGV; 

#do hmm profile - profile alignment
system("$hhmprc_dir/prc-1.5.2-linux-i386 -hits 5 $hhm_file1 $hhm_file2 > $out_file.tmp"); 

#parse the output file
open(RES, "$out_file.tmp") || die "can't read hhm prc results.\n"; 
@res = <RES>;
close RES;

$reverse = $simple = $coemis = 0; 

while (@res)
{
	$line = shift @res; 
	if ($line =~ /#\s+hmm1\s+start1\s+end1\s+length1\s+hit_no\s+hmm2.+reverse/)
	{
		$value = shift @res; 
		@info = split(/\s+/, $value);
		$reverse = pop @info;
		$simple = pop @info;
		$coemis = pop @info; 
		last; 
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 3\n";
print OUT $coemis/$query_length, " ", $simple/$query_length, " ", $reverse/$query_length,  "\n\n";
close OUT; 

print "feature num: 3\n";
print $coemis/$query_length, " ", $simple/$query_length, " ", $reverse/$query_length,  "\n\n";

`rm $out_file.tmp`; 
