#!/usr/bin/perl 
#########################################################################
#Do prof-prof alignment using LOBSTER(COACH).
#Input: LOBSTER dir, query fasta file, query msa file (fas format)
#, template fasta file,
# template msa file (fas format), template hmm file,  output file
#Output: score, evalue, and alignments (global alignments)
#in the output file and stdout: print out: Feature num, score and logarithm
# of evalue
#Modified from compass.pl
#Author: Jianlin Cheng
#Date: 7/26/2005
#########################################################################
if (@ARGV != 7)
{
	die "need 7 parameters: LOBSTER dir(lobster), query fasta file, query msa file(.fas format), template fasta file, template msa file (.fas format), template hmm file(.lob), ouptut file.\n";
}

$lobster_dir = shift @ARGV;
-d $lobster_dir || die "can't find lobster dir.\n";
if (!-f "$lobster_dir/lobster")
{
	die "can't find lobster executable file.\n";
}

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find query fasta sequence file.\n";
open(FASTA, $fasta_file);
$code1 = <FASTA>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <FASTA>;
chomp $seq1; 
close FASTA;
$query_length = length($seq1); 

$msa_file1 = shift @ARGV;
-f $msa_file1 || die "can't find msa file 1: $msa_file1.\n";

$temp_fasta = shift @ARGV;
-f $temp_fasta || die "can't find template fasta file.\n";
open(FASTA, $temp_fasta);
$code2 = <FASTA>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <FASTA>;
chomp $seq2; 
close FASTA; 

$msa_file2 = shift @ARGV;
-f $msa_file2 || die "can't find msa file 2: $msa_file2.\n";

$temp_hmm = shift @ARGV; 
-f $temp_hmm || die "can't find template lobster hmm file: $temp_hmm.\n";  

$out_file = shift @ARGV;

system("$lobster_dir/lobster -align $msa_file1 -hmm $temp_hmm -tpl $msa_file2 -out $out_file.res > $out_file.tmp"); 

#parse the output file
open(RES, "$out_file.tmp") || die "can't read LOBSTER ALIGNMENT results.\n"; 
@res = <RES>;
close RES;
$score = 0; 
while (@res)
{
	$line = shift @res; 
	#Model=d1hce__.lob;Target=d1jkw_1.fas;Viterbi=-57.9
	chomp $line; 
	if ($line =~ /Model=.+;Target=.+;Viterbi=(.+)/)
	{
		$score = $1; 
		last; 
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 1\n";
print OUT $score/$query_length, "\n";
print "feature num: 1\n";
print $score/$query_length,  "\n";

#parse the alignment file.
open(RES, "$out_file.res") || die "can't read alignment output file.\n"; 
@res = <RES>;
close RES; 

while (@res)
{
	$name = shift @res; 
	chomp $name;
	$name = substr($name, 1); 

	#read  multiple lines
	$ali = "";
	while (@res)
	{
		$temp = shift @res;
		if ($temp =~ /^>/)
		{
			unshift @res, $temp;
			last;
		}
		else
		{
			chomp $temp;
			$ali .= $temp; 
		}
	}

	$ali = uc($ali); 
	$ali =~ s/\./-/g; 

	if ($name eq $code1)
	{
		$ali_org = $ali;
		$ali_org =~ s/-//g; 
		if ($ali_org ne $seq1)
		{
			print "$ali_org\n$seq1\n";
			die "in lobster alignment, query sequence doesn't match.\n"; 
		}
		#print "$name\n$ali\n"; 
		#print OUT "$name\n$ali\n"; 
		$query_alignment = "$name\n$ali\n";
	}

	if ($name eq $code2)
	{
		$ali_org = $ali;
		$ali_org =~ s/-//g; 
		if ($ali_org ne $seq2)
		{
			print "$ali_org\n$seq2\n";
			die "in lobster alignment, template sequence doesn't match.\n"; 
		}
		#print "$name\n$ali\n"; 
		#print OUT "$name\n$ali\n"; 
		$template_alignment = "$name\n$ali\n"; 
	}
}
print "$query_alignment$template_alignment";
print OUT "$query_alignment$template_alignment";

close OUT; 

`rm $out_file.tmp`; 
`rm $out_file.res`; 
