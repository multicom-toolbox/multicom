#!/usr/bin/perl -w
#######################################################################
#Convert CM contact map file or dataset file to psipred format (only use ss)
#No positions information that often is included in psipred format.
#each line contains at most 60 residues.
#Author: Jianlin Cheng
#Date: 7/29/2005.
########################################################################

if (@ARGV != 2)
{
	die "need 2 parameters: input file, format(map:contact map, set:dataset).\n"; 
}
$in_file = shift @ARGV;
$format = shift @ARGV;

open(INFILE, $in_file) || die "can't read input file.\n";
if ($format eq "map")
{
	<INFILE>;
	$seq = <INFILE>;
	chomp $seq;
	$ss = <INFILE>;
	chomp $ss; 
	$score = "5";
}
else #dataset format
{
	<INFILE>;
	<INFILE>;
	$seq = <INFILE>;
	$seq =~ s/\s//g;

	$ss = <INFILE>;
	chomp $ss;
	$ss =~ s/\s//g; 

	$ss =~ s/[GI]/H/g; 
	$ss =~ s/B/E/g;
	$ss =~ s/[TS\.]/C/g; 
	$score = "9";
}
close INFILE; 

if (length($seq) != length($ss))
{
	die "sequence length doesn't match with secondary structure length.\n"; 
}

$length = length($seq); 

@group = (); 

$conf = "";
$pred = "";
$aa = ""; 

for ($i = 0; $i < $length; $i++)
{
	if ($i % 60 == 0)
	{
		if ($pred ne "")
		{
			push @group, "$conf\n", "$pred\n", "$aa\n", "\n"; 
		}
		$conf = "Conf: ";
		$pred = "Pred: ";
		$aa   = "  AA: ";

	}
	$conf .= $score;
        $pred .= substr($ss, $i, 1); 
	$aa   .= substr($seq, $i, 1); 
}
if ($pred ne "" && $pred ne "Conf: ")
{
	push @group, "$conf\n", "$pred\n", "$aa\n", "\n"; 
}

#output the secondary structure.
foreach $line (@group)
{
	print $line; 
}

