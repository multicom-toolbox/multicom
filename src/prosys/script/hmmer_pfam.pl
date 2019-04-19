#!/usr/bin/perl -w
#########################################################################
#align a sequence to a hmm file using hmmer
#Input: hmmer dir, query sequence file (fasta format), target file, target hmm file, output file
#Output: score, evalue, and alignments (local alignments)
#in the output file and stdout: print out: Feature num, score and logarithm
# of evalue
#Author: Jianlin Cheng
#Date: 5/9/2005
#########################################################################
if (@ARGV != 5)
{
	die "need five parameters: hmmer dir, query fasta file, target hmm file, target sequence file(fasta), ouptut file.\n";
}

$hmmer_dir = shift @ARGV;
-d $hmmer_dir || die "can't find hmmer dir.\n";
if (!-f "$hmmer_dir/binaries/hmmsearch")
{
	die "can't find hmmsearch executable file.\n";
}

$query_file = shift @ARGV;
-f $query_file || die "can't find query fasta sequence file.\n";
open(QUERY, $query_file);
$code2 = <QUERY>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <QUERY>;
chomp $seq2; 
close FASTA;
$query_length = length($seq2);

$hmm_file = shift @ARGV;
-f $hmm_file || die "can't find hmm file.\n";

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find fasta sequence file.\n";
open(FASTA, $fasta_file);
$code1 = <FASTA>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <FASTA>;
chomp $seq1; 
close FASTA;

$out_file = shift @ARGV;

#do hmm profile -> sequence alignment
system("$hmmer_dir/binaries/hmmpfam $hmm_file $query_file > $out_file.tmp"); 

#parse the output file
open(RES, "$out_file.tmp") || die "can't read hmm searching results.\n"; 
@res = <RES>;
close RES;

#set default value in case of nothing is generated.
$score = 0;
$evalue = 1;

while (@res)
{
	$line = shift @res; 
	if ($line =~ /^Model\s+Description\s+Score\s+E-value\s+N/)
	{
		shift @res;
		$value = shift @res; 
		$num = 0;
		$id = "";
		($id, $score, $evalue, $num) = split(/\s+/, $value);
		#if ($id ne $code1)
		#{
		#	print "$id, $code1\n";
		#	die "return sequence id doesn't match with id in the fasta file.\n";
		#}
		last; 
	
	}
}
`rm $out_file.tmp`; 

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 2\n";
print OUT $score/$query_length, " ", log($evalue), "\n\n";
close OUT; 
print "feature num: 2\n";
print $score/$query_length, " ", log($evalue), "\n\n";
