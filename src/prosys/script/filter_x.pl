#!/usr/bin/perl -w
#####################################################
#Check the percentage of x in a fasta dataset and 
#filter out sequence with a lot of x.
#Author: Jianlin Cheng
#Date: 1/1/2006
######################################################

if (@ARGV != 2)
{
	die "need two parameters: fasta set file, percentage of X to report (0.3)\n";
}

$fasta_file = shift @ARGV;
$threshold = shift @ARGV;

open(FASTA, $fasta_file) || die "can't read fasta file: $fasta_file\n";
@fasta = <FASTA>;
close FASTA;

$modified = 0;

@select = ();
while (@fasta)
{
	$name = shift @fasta;
	$seq = shift @fasta;
	chomp $seq;

	$len = length($seq);
	$num = 0; 
	for ($i = 0; $i < $len; $i++)
	{
		if (substr($seq, $i, 1) eq "X")
		{
			$num++; 
		}
	}
	$percentage = $num / $len;
	if ($percentage < $threshold)
	{
		push @select,  "$name$seq\n";
	}
	else
	{
		print "delete $name with a lot of X (percentage = $percentage)\n";
		$modified = 1; 
	}
}

if ($modified == 1)
{
	open(FASTA, ">$fasta_file") || die "can't overwrite fasta file: $fasta_file\n";
	print FASTA join("", @select);
	close FASTA;
}

