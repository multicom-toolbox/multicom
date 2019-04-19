#!/usr/bin/perl 
#########################################################################
#Do prof-prof alignment using hhsearch.
#Input: COMPASS dir, aln file1, aln file2, output file
#Output: score, evalue, and alignments (local alignments)
#in the output file and stdout: print out: Feature num, score and logarithm
# of evalue
#Modified from hhm_search.pl
#Author: Jianlin Cheng
#Date: 12/28/2008
#########################################################################
if (@ARGV != 6)
{
	die "need six parameters: COMPASS dir(must include new compass), query fasta file, query aln file, target fasta file (.fas or .fasta), target aln file, ouptut file.\n";
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


#read tareget file
$fasta_file2 = shift @ARGV;
open(FASTA, $fasta_file2) || die "can't read $fasta_file2";
$code2 = <FASTA>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <FASTA>;
chomp $seq2; 
close FASTA;
$target_length = length($seq2); 


$aln_file2 = shift @ARGV;
-f $aln_file2 || die "can't find hhm file 2: $aln_file2.\n";

$out_file = shift @ARGV;

#do log_exp profile - profile alignment using SMITH-WATERMAN algorithm
system("$compass_dir/new_compass/compass -i $aln_file1 -j $aln_file2 > $out_file.tmp 2>/dev/null"); 

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

$query = "";
$template = "";
while (@res)
{
	$line = shift @res; 

	if ($line =~ /^$code1/)
	{
		chomp $line;
		@fields = split(/\s+/, $line);
		$segment = $fields[$#fields];
		$segment = uc($segment);
		$segment =~ s/=/-/g;
		$segment =~ s/~/-/g;
		$query .= $segment;
	}

	if ($line =~ /^$code2/)
	{
		chomp $line;
		@fields = split(/\s+/, $line);
		$segment = $fields[$#fields];
		$segment = uc($segment);
		$segment =~ s/=/-/g;
		$segment =~ s/~/-/g;
		$template .= $segment;
	}
}

if ($query ne "")
{
	length($query) == length($template) || die "query alignment <=> template alignment.\n";
	#get the start and end positions of query	
	$query_tr = $query;
	$query_tr =~ s/-//g;

	$idx = index($seq1, $query_tr);

	if ($idx >= 0)
	{
		$qstart = $idx + 1;
		$qend = $qstart + length($query_tr) - 1; 
		$qend <= $query_length || die "query end > query length.\n";
	}
	else
	{
		die "$query_tr is not found in $code1.\n";
	}
}

if ($template ne "")
{
	#get the start and end positions of query	
	$template_tr = $template;
	$template_tr =~ s/-//g;

	$idx = index($seq2, $template_tr);

	if ($idx >= 0)
	{
		$tstart = $idx + 1;
		$tend = $tstart + length($template_tr) - 1; 

		$tend <= $target_length || die "template end > template length.\n";
	}
	else
	{
		die "$template_tr is not found in $code2.\n";
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 2\n";
print OUT $score/$query_length, " ", $evalue, "\n";
if($query ne "")
{
	print OUT "$qstart $qend $tstart $tend\n";
	print OUT "$code1\n";
	print OUT "$query\n";
	print OUT "$code2\n";
	print OUT "$template\n";
}
close OUT; 
print "feature num: 2\n";
print $score/$query_length, " ", $evalue,  "\n";
if($query ne "")
{
	print "$qstart $qend $tstart $tend\n";
	print "$code1\n";
	print "$query\n";
	print "$code2\n";
	print "$template\n";
}
#`rm $out_file.tmp`; 
