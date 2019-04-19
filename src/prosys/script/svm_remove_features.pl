#!/usr/bin/perl -w
##########################################################
#Remove features from svm dataset
#Input: input_set, output set, feature id1, ...
#Author: Jianlin Cheng
#Date: 12/25/2005
###########################################################

if (@ARGV <= 2)
{
	die "need at least three parameters: input_set, output_set, id1, ...\n";
}

$input_set = shift @ARGV;
$output_set = shift @ARGV;

@rm_fea = @ARGV;

open(IN, $input_set) || die "can't read input set: $input_set\n";
open(OUT, ">$output_set") || die "can't create output set: $output_set\n";

while (<IN>)
{
	$line = $_;
	if ($line =~ /^#/)
	{
		print OUT $line;
		next; 
	}

	chomp $line;

	@fields = split(/\s+/, $line);
	$label = shift @fields;

	print OUT $label; 

	#check the consistency
	if (@fields != 84)
	{
		die "the total feature should be equal to 84.\n";
	}

	$start = 1; 

	for ($i = 1; $i <= @fields; $i++)
	{
		$fea = $fields[$i-1]; 
		($idx, $value) = split(/:/, $fea);
		$idx == $i || die "index mismatch.\n";

		$is_remove = 0; 
		foreach $togo (@rm_fea)
		{
			if ($idx == $togo)
			{
				$is_remove = 1; 
				last;
			}
		}

		if ($is_remove == 0)
		{
			print OUT " $start:$value";
			$start++; 
		}

	}
	print OUT "\n";
}

close IN;
close OUT;

