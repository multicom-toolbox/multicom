#!/usr/bin/perl 
#########################################################################
#Do prof-prof alignment using hhsearch.
#Input: hhsearch dir, hhm file1, hhm file2, output file
#Output: score, evalue, and alignments (local alignments)
#in the output file and stdout: print out: Feature num, score and logarithm
# of evalue
#Modified from hmmer_search.pl
#Author: Jianlin Cheng
#Date: 7/25/2005
#########################################################################
if (@ARGV != 5)
{
	die "need five parameters: hhsearch dir, query fasta file, query hhm file, target hhm file, ouptut file.\n";
}

$hhsearch_dir = shift @ARGV;
-d $hhsearch_dir || die "can't find hhsearch dir.\n";
if (!-f "$hhsearch_dir/hhsearch32")
{
	die "can't find hhsearch executable file.\n";
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

#$idx = rindex($hhm_file1, "/");
#if ($idx >= 0)
#{
#	$out_name = substr($hhm_file1, $idx+1);
#}
#else
#{
	$out_name = $hhm_file1; 
#}

if ($out_name =~ /(.+)\.hhm/)
{
	$out_name = $1; 
}
else
{
	die "the suffix of the hhm file must be .hhm\n"; 
}

$hhm_file2 = shift @ARGV;
-f $hhm_file2 || die "can't find hhm file 2: $hhm_file2.\n";

$out_file = shift @ARGV;

$out_name = $out_file . ".hhr";

#do hmm profile - profile alignment
system("$hhsearch_dir/hhsearch32 -i $hhm_file1 -d $hhm_file2 -o $out_name 2>/dev/null"); 


#parse the output file
open(RES, "$out_name") || die "can't read hhm searching results.\n"; 
@res = <RES>;
close RES;
$score = 0; 
while (@res)
{
	$line = shift @res; 
	if ($line =~ /\s+No\s+Hit\s+Prob\s+E-value\s+P-value\s+Score/)
	{
		$value = shift @res; 
		$value =~ /^\s+(.+)/;
		$value = $1; 
		($id, $temp_name, $prob, $evalue, $pvalue, $score, @other) = split(/\s+/, $value);
		last; 
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 1\n";
print OUT $score/$query_length, "\n\n";
close OUT; 
print "feature num: 1\n";
print $score/$query_length,  "\n\n";
`rm $out_name`; 
