#!/usr/bin/perl -w
###################################################################
#Evaluate all casp7 models
#Author: Jianlin Cheng
#Date: 10/12/2007
###################################################################

open(RES, "cluster_results2.txt") || die "can't read cluster_results.txt.\n";
@res = <RES>;
close RES;

$close_num = 0;
$close_score = 0;
$combo_num = 0;
$combo_score = 0;

$close_num2 = 0;
$close_score2 = 0;
$combo_num2 = 0;
$combo_score2 = 0;

@names = ();
while (@res)
{
	$line = shift @res;

	if ($line =~ /closc1\.pdb/)
	{
		$line = shift @res;
		chomp $line;
		$close_num++;
		$close_score += $line;
	}	

	if ($line =~ /combo1\.pdb/)
	{
		push @names, $line;
		$line = shift @res;
		chomp $line;
		$combo_num++;
		$combo_score += $line;
	}

	if ($line =~ /closc2\.pdb/)
	{
		$line = shift @res;
		chomp $line;
		$close_num2++;
		$close_score2 += $line;
	}	

	if ($line =~ /combo2\.pdb/)
	{
		push @names, $line;
		$line = shift @res;
		chomp $line;
		$combo_num2++;
		$combo_score2 += $line;
	}
	
}

print "number of closest 1 targets = $close_num, score = $close_score\n";
print "number of combo 1 targets = $combo_num, score = $combo_score\n";
print "number of closest 2 targets = $close_num2, score = $close_score2\n";
print "number of combo 2 targets = $combo_num2, score = $combo_score2\n";





