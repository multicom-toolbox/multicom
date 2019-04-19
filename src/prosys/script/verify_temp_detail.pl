#!/usr/bin/perl -w
############################################
#verify if all files are generated for each 
#template.
#Input: fr library fasta file, library dir, 
#file containing missing templates
############################################
if (@ARGV != 3)
{
	die "need 3 parameters: template fasta file, library dir, file containing missing templates.\n";
}
$temp_file = shift @ARGV;
$temp_dir = shift @ARGV;
$miss_file = shift @ARGV;
-d $temp_dir || die "can't find template dir: $temp_dir\n";
open(TEMP, $temp_file) || die "can't read temp file.\n";
open(OUT, ">$miss_file") || die "can't create file $miss_file\n";

while (<TEMP>)
{
	$name = $_;
	chomp $name;
	$name = substr($name, 1);
	$seq=<TEMP>;
		
	@suffix = ("align", "aln", "chk", "fas", "hhm", "hmm", "lob", "pssm", "set");

	$wrong = 0; 
	foreach $suf (@suffix)
	{
		if (! -f "$temp_dir/$name.$suf")
		{
			$wrong = 1; 
			last;
		}
	}
	if ($wrong == 1)
	{
		print OUT ">$name\n";
		print OUT "$seq";
	}
	else
	{
		#check if two files match
		open(FAS, "$temp_dir/$name.fas") || die "can't open $name.fas\n";
		<FAS>;
		$tseq = <FAS>;
		close FAS;
		if ($seq ne $tseq)
		{
			die "$name match, but sequence doesn't match.\n$seq$tseq";
		}
	}
}
close OUT; 
