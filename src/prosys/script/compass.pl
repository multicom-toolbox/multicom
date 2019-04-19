#!/usr/bin/perl 
#########################################################################
#Do prof-prof alignment using hhsearch.
#Input: COMPASS dir, aln file1, aln file2, output file
#Output: score, evalue, and alignments (local alignments)
#in the output file and stdout: print out: Feature num, score and logarithm
# of evalue
#Modified from hhm_search.pl
#Author: Jianlin Cheng
#Date: 7/26/2005
#########################################################################
if (@ARGV != 5)
{
	die "need five parameters: COMPASS dir(compass1.24), query fasta file, query aln file, target aln file, ouptut file.\n";
}

$compass_dir = shift @ARGV;
-d $compass_dir || die "can't find compass dir.\n";
if (!-f "$compass_dir/compass")
{
	die "can't find compass executable file.\n";
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

$aln_file1 = shift @ARGV;
-f $aln_file1 || die "can't find aln file 1: $aln_file1.\n";

$aln_file2 = shift @ARGV;
-f $aln_file2 || die "can't find hhm file 2: $aln_file2.\n";

$out_file = shift @ARGV;

#do log_exp profile - profile alignment using SMITH-WATERMAN algorithm
system("$compass_dir/compass -i $aln_file1 -j $aln_file2 > $out_file.tmp 2>/dev/null"); 

#parse the output file
open(RES, "$out_file.tmp") || die "can't read COMPASS searching results.\n"; 
@res = <RES>;
close RES;
$score = 0; 
$evalue = 0; 
while (@res)
{
	$line = shift @res; 
	#Smith-Waterman score = 956       Evalue = 9.06e-125
	if ($line =~ /Smith-Waterman\s+score\s+=\s+(\S+)\s+Evalue\s+=\s+([\d\.]+)e([-\+\d]+)/)
	{
		$score = $1; 
		if ($2 <= 0)
		{
			$evalue = -200; 
		}
		else
		{
			$evalue = log($2) + $3; 
		}
		last; 
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 2\n";
print OUT $score/$query_length, " ", $evalue, "\n\n";
close OUT; 
print "feature num: 2\n";
print $score/$query_length, " ", $evalue,  "\n\n";
`rm $out_file.tmp`; 
