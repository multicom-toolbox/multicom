#!/usr/bin/perl -w
################################################################
#Join all shhm files in one directory into one big file
#Author: Jianlin cheng
################################################################

if (@ARGV != 2)
{
	die "need two parameters: input dir, output file.\n";
}

$shhm_dir = shift @ARGV;
$db_file = shift @ARGV;

opendir(DIR, $shhm_dir) || die "can't open $shhm_dir.\n";
@files = readdir(DIR);
closedir DIR;

`>$db_file`;

$count = 0; 
while (@files)
{
	$file = shift @files;
	if ($file =~ /\.shhm$/)
	{
		$count++;
		$pfile = "$shhm_dir/$file";
		`cat $pfile >>$db_file`; 
	}
}
#print "The total number of shhm files is $count.\n";
