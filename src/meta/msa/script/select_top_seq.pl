#!/usr/bin/perl -w
#####################################################################
#Select top number of sequences in query family
#Author: Jianlin Cheng
#####################################################################

if (@ARGV != 3)
{
	die "need two parameters: input file, num of sequences to select, output file.\n";
}

$input_msa = shift @ARGV;
$num = shift @ARGV;
$output_msa = shift @ARGV;

open(INPUT, $input_msa) || die "can't open $input_msa.\n";
@msa = <INPUT>;
close INPUT; 

@select_id = ();
@select_seq = ();

while (@msa)
{
	$id = shift @msa;
	$seq = shift @msa;

	$found = 0;
	foreach $protein (@select_seq)
	{
		if ($seq eq $protein)
		{
			$found = 1; 
		}
	}
	
	if ($found == 0)
	{
		push @select_id, $id;
		push @select_seq, $seq; 
		if (@select_seq >= $num)
		{
			last;
		}
	}

}

open(OUTPUT, ">$output_msa") || die "can't create $output_msa.\n";
for ($i = 0; $i < @select_id; $i++)
{
	print OUTPUT "$select_id[$i]$select_seq[$i]";
}
close OUTPUT; 










