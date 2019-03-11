#!/usr/bin/perl -w

if (@ARGV != 2)
{
	die "need two parameters: input directory of aln files (aln directory and sort90 library file.\n";
}

$aln_dir = shift @ARGV;
-d $aln_dir || die "can't find $aln_dir.\n";

$sort90 = shift @ARGV;

open(SORT, $sort90) || die "can't read $sort90.\n";
@data = <SORT>;
close SORT;

while (@data)
{
	$name = shift @data;
	$name =~ /^>/ || die "sort file format error.\n";
	chomp $name;
	$name = substr($name, 1);
	$aln_file = "$aln_dir/$name.aln";
	if (-f $aln_file)
	{
		print "$aln_file\n";
	}
	shift @data;
}

