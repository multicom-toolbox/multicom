#!/usr/bin/perl -w

##########################################################################################################
#Sequence alignment features
#Alignment tools: palign, clustwal, or other?
#Inputs: script dir, alignment tool dir, tool name, query file, query format,  target file, target format
#Output: alignment, and scores
#Author: Jianlin Cheng
#Date: 5/1/2005
###########################################################################################################

if (@ARGV != 7)
{
	die "need seven parameters: script_dir, alignment tool dir, tool name, query file, query format, target file, target format.\n";
}


#support sequence alignment tools: clustwal, palign, fasta, blast(how to?)
$script_dir = shift @ARGV;
require "$script_dir/syslib.pl";
$align_dir = shift @ARGV;
$tool_name = shift @ARGV;
$query_file = shift @ARGV;
$qformat = shift @ARGV;
$target_file = shift @ARGV;
$tformat = shift @ARGV;

-d $script_dir || die "can't find script dir.\n";
-d $align_dir || die "can't find alignment tool dir.\n"; 

#create fasta file
$file1 = "$query_file.fasta";
$file2 = "$target_file.fasta";

open(IN, $query_file) || die "can't read query file.\n";
@content = <IN>;
close IN;
$seq1 = &get_seq(\@content, $qformat);
open(FASTA, ">$file1") || die "can't create $file1\n";
print FASTA ">seq1\n$seq1\n";
close FASTA;

$query_length = length($seq1); 

open(IN, $target_file) || die "can't read query file.\n";
@content = <IN>;
close IN;
$seq2 = &get_seq(\@content, $tformat);
open(FASTA, ">$file2") || die "can't create $file2\n";
print FASTA ">seq2\n$seq2\n";
close FASTA;

if ($tool_name eq "palign")
{
	system("$align_dir/$tool_name -ali $file1 $file2 > $query_file.out");
	open(RES, "$query_file.out") || die "can't read palign results.\n";
	$lena = <RES>;
	if ($lena =~ /len:\s*(\d+)/)
	{
		$lena = $1;
		$lena eq length($seq1) || die "sequence length doesn't match: $lena\n$seq1\n";
	}
	else
	{
		die "alignment output error.\n";
	}
	$lenb = <RES>;
	if ($lenb =~ /len:\s*(\d+)/)
	{
		$lenb = $1;
		$lenb eq length($seq2) || die "sequence length doesn't match: $lena\n$seq1\n";
	}
	else
	{
		die "alignment output error.\n";
	}
	<RES>;
	$score = <RES>;
	close RES;
	if ( $score =~ /SCORE>\s+([\d\.]+)E([\+-]+)(\d+)\s+([-\d\.]+)E([\+-]+)(\d+)/)
	{
		$qa = $1;
		$qsign = $2;
		$qb = $3;

		#print "$qa $qsign $qb\n";
		if ($qsign eq "+")
		{
			$score1 = log($qa) + $qb;
		}
		elsif ($qsign eq "-")
		{
			$score1 = log($qa) - $qb;
		}
		else
		{
			die "score format error\n";
		}

		$ta = $4;
		$tsign = $5;
		$tb = $6;

		if ($ta > 0)
		{
			#print "$ta $tsign $tb\n";
			if ($tsign eq "+")
			{
				$score2 = log($ta) + $tb;
			}
			elsif ($tsign eq "-")
			{
				$score2 = log($ta) - $tb;
			}
			else
			{
				die "score format error\n";
			}
		}
		else
		{
			$score2 = -10;
		}

		#change to use original value
		#warn "score:$score\n"; 
		if ($tsign eq "-")
		{
			$score2 = $ta * exp(-$tb);
		}
		else
		{
			$score2 = $ta * exp($tb);
		}
		if ($score2 > 10)
		{
			$score2 = 10; 
		}
		elsif ($score2 < -10)
		{
			$score2 = -10; 
		}
	}
	else
	{
		#die "alignment score error.\n";
		#in case palign return "-INF", it will crash here. we simply set both scores to 0. so it doesn't have impact.
		#print  "alignment score error.\n";

		$score1 = 0; 
		$score2 = 0; 
	}

	print "feature num: 2\n";
	print "$score1 $score2\n";
}
elsif ($tool_name eq "clustalw")
{
	`cat $file1 $file2 > $file1.tmp`;	
	`rm $file1`;
	`mv $file1.tmp $file1`;
	#print("$align_dir/$tool_name -TYPE=PROTEIN -PWMATRIX=BLOSUM -INFILE=$file1 > $query_file.out\n");
	#die "stop";
	system("$align_dir/$tool_name -TYPE=PROTEIN -PWMATRIX=BLOSUM -INFILE=$file1 > $query_file.out");

	open(RES, "$query_file.out") || die "can't read cluswal seq alignment output.\n";
	@res = <RES>;
	close RES;
	$align_score = 0;
	while (@res)
	{
		$line = shift @res;
		#print $line;	
		if ($line =~ /^Sequences\s+\(1:2\)\s+Aligned\.\s+Score:\s+(\d+)/)
		{
			#print "score: $1\n";
			$align_score = $1 / $query_length; 	
		}
	}
	print "feature num: 1\n";
	print "$align_score\n";
	`rm $query_file.aln $query_file.dnd`; 
}

`rm $file1 $file2 $query_file.out`; 

