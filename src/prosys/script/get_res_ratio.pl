#!/usr/bin/perl -w
##########################################################################
#Extract a list of resolution and match ratio for sequences in a directory
#Input: sequence dir, output file (list: seq_name resolution  ratio method)
#Author: Jianlin Cheng
#Date: 10/27/2005
##########################################################################
if (@ARGV != 2)
{
	die "need two parameters: seq dir and output file.\n";
}
$seq_dir = shift @ARGV;
$out_file = shift @ARGV;

opendir(DIR, $seq_dir) || die "can't read dir: $seq_dir\n";
@files = readdir(DIR);
closedir DIR;
open(OUT, ">$out_file") || die "can't create file: $out_file\n";
while (@files)
{
	$file = shift @files;
	if ($file eq "." || $file eq "..")
	{
		next; 
	}
	$full_name = "$seq_dir/$file";
	open(SEQ, $full_name) || die "can't read file: $full_name\n";
	@lines = <SEQ>;
	close SEQ;
	@lines == 12 || die "number of lines in $full_name is not 12. stop.\n";
	$ratio_line = $lines[0];
	if ($ratio_line =~ /found=(\d+), not_found=(\d+)/)
	{
		$ratio = $1 / ($1+$2);
	}
	else
	{
		die "can't find match ratio.\n";
	}
	$name = $lines[1];
	chomp $name;
	$res_line = $lines[2]; 
	chomp $res_line;
	($reso, $method) = split(/\s+/, $res_line); 
	print OUT "$name\t$reso\t$ratio\t$method\n";
}

close OUT; 
