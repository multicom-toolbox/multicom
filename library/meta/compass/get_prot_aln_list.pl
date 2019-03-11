#!/usr/bin/perl -w

if (@ARGV != 1)
{
	die "need input directory of aln files.\n";
}

$aln_dir = shift @ARGV;
opendir(IN, $aln_dir) || die "can't read input dir.\n";
@files = readdir IN;
closedir IN;

while (@files)
{
	$file = shift @files;
	if ($file =~ /\.aln$/)
	{
		$aln_file = "$aln_dir/$file";
		print "$aln_file\n";
	}
}

