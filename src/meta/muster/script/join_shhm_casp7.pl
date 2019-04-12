#!/usr/bin/perl -w
################################################################
#Join all shhm files (in T0283, before CASP7)
# in one directory into one big file
#Author: Jianlin cheng
################################################################

if (@ARGV != 3)
{
	die "need three parameters: rank file, input dir, output file.\n";
}

$rank_file = shift @ARGV;
$shhm_dir = shift @ARGV;
$db_file = shift @ARGV;

open(RANK, $rank_file) || die "can't open $rank_file.\n";
@rank = <RANK>;
close RANK; 

shift @rank;

`>$db_file`;

$count = 0; 
while (@rank)
{
	$line = shift @rank;
	@fields = split(/\s+/, $line);
	$template = $fields[1]; 
	$file = "$shhm_dir/$template.shhm"; 
	if (-f $file)
	{
		$count++;
		`cat $file >>$db_file`; 
	}
}
print "The total number of shhm files is $count.\n";
