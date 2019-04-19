#!/usr/bin/perl -w
##################################################################
#Rank templates according to classification results
#Input: feature file,  result file, output file
#Author: Jianlin Cheng
#Date: 8/21/2005
#Changes: rank positive templates by compass e-value
##################################################################
if (@ARGV != 3)
{
	die "need 3 files: feature file, results file, output file.\n";
}

$fea_file = shift @ARGV;
$res_file = shift @ARGV;
$out_file = shift @ARGV;
open(FEA, $fea_file) || die "can't read feature file.\n";
@fea = <FEA>;
close FEA;

$prev = ""; 
@temps = (); 
#@temp2com = ();
@com = ();
while (@fea)
{
	$pair = shift @fea;
	$pair = substr($pair, 1);
	($query, $temp) = split(/\s+/, $pair);
	if ($prev ne "" && $query ne $prev)
	{
		print "$prev, $query\n";
		die "query doesn't match.\n"; 
	}
	$prev = $query; 
	push @temps, $temp; 
	$line = shift @fea;
	chomp $line;
	@fields = split(/\s+/, $line);
	@fields == 85 || die "number of features is wrong.\n";
	$hold = "";
	($hold, $value) = split(/:/, $fields[84]);
	#$temp2com{$temp} = $value;
	push @com, $value;
}

open(RES, $res_file) || die "can't read results file.\n";
@res = <RES>;
close RES;

if (@res != @temps)
{
	die "number of templates doesn't match with number of results.\n";
}

@positives = ();
@group = ();
for ($i = 0; $i < @res; $i++)
{
	$score = $res[$i]; 
	chomp $score;
	if ($score <= 0)
	{
		push @group, {
			temp => $temps[$i],
			com => $com[$i],
			score => $score
		};
	}
	else
	{
		push @positives, {
			temp => $temps[$i],
			com => $com[$i],
			score => $score
		};
	}
}

@sorted = sort {$a->{"com"} <=> $b->{"com"}} @positives;
@negatives = sort {$b->{"score"} <=> $a->{"score"}} @group;
push @sorted, @negatives;

open(OUT, ">$out_file") || die "can't create output file.\n";
$total = @sorted;
print OUT "Ranked templates for $query, total = $total\n"; 
for($i = 0; $i < $total; $i++)
{
	$id = $i + 1; 
	$score = $sorted[$i]{"score"};
	#round it
	$score *= 100;
	if ($score > 0)
	{
		$score += 0.5;
	}
	else
	{
		$score -= 0.5;
	}
	$score = int($score);
	$score /= 100;
	print OUT $id, "\t", $sorted[$i]{"temp"}, "\t", $score , "\n";
}
close OUT; 



