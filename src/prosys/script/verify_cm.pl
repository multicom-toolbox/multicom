#!/usr/bin/perl -w
############################################
#verify if all files are generated for each 
#template in CM library.
#Input: cm library fasta file, cm seq dir, 
#cm atom dir
#file containing missing files (seq or atom) 
############################################
if (@ARGV != 4)
{
	die "need 4 parameters: cm template fasta file, seq dir, atom dir, missing files (either seq or atom)\n";
}
$temp_file = shift @ARGV;
$seq_dir = shift @ARGV;
$atom_dir = shift @ARGV;
$miss_file = shift @ARGV;
-d $seq_dir || die "can't find template seq dir: $seq_dir\n";
-d $atom_dir || die "can't find template atom dir: $atom_dir\n";
open(TEMP, $temp_file) || die "can't read temp file.\n";
open(OUT, ">$miss_file") || die "can't create file $miss_file\n";

while (<TEMP>)
{
	$name = $_;
	chomp $name;
	$name = substr($name, 1);
	$seq=<TEMP>;
		
	$wrong = 0; 
	if (! -f "$seq_dir/$name.seq")
	{
		$wrong = 1; 
	}

	if (! -f "$atom_dir/$name.atom.gz")
	{

		if ( -f "$atom_dir/$name.atom")
		{
#			warn "$name.atom is not zipped, compress it\n"; 
			`gzip $atom_dir/$name.atom`; 
		}
		if (! -f "$atom_dir/$name.atom.gz")
		{
			$wrong = 1; 
		}
	}
	if ($wrong == 1)
	{
		print OUT ">$name\n$seq";
	}
}
close OUT; 
