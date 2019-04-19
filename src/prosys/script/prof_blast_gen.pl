#!/usr/bin/perl -w
#########################################################################
# Generate profile and pssm using PSI-BLAST for a single sequence
# Input:psi-blast, big db, nr db, fasta file, profile file, pssm file 
# Output: one is profile generated from frequency of psi-blast output
# Another output file is pssm file, which can be used by palignp (prof-prof
# alignment tool). 
# Author: Jianlin Cheng, Date: 1/18/2005
#Notice: the aa order of profile is the same as sspro.
#Notice: the aa order of pssm is the same as psi-blast
#########################################################################

if (@ARGV != 6)
{
	die "need: blastpgp , big db, nr db, input fasta file, output profile file, output pssm file\n"; 
}
$blastpgp = shift @ARGV;
$big_db = shift @ARGV;
$nr_db = shift @ARGV; 
$fasta = shift @ARGV;
$output = shift @ARGV; 
$output_pssm = shift @ARGV; 

$stdaa = "ACDEFGHIKLMNPQRSTVWY";

system("$blastpgp -i $fasta -o $fasta.tmp -C $fasta.chk -j 3 -e 0.001 -h 1e-10 -d $big_db");
system("$blastpgp -i $fasta -R $fasta.chk -o $output -j 5 -e 0.001 -h 1e-10 -d $nr_db -Q $output.pssm");

`rm $fasta.tmp $fasta.chk`; 

open(FASTA, "$fasta") || die "can't read input sequence file.\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1); 
$seq = <FASTA>;
chomp $seq; 
$length = length($seq);
close FASTA; 

open(OUTPUT, ">$output") || die "can't create output file.\n"; 
open(OUTPSSM, ">$output_pssm") || die "can't create output pssm file.\n";  

print OUTPUT "$name\n$length\n$seq\n"; 

open(PSSM, "$output.pssm") || die "can't read pssm output file.\n";
@pssm = <PSSM>;
close PSSM; 
$tmp = shift @pssm; 
print OUTPSSM $tmp;
print OUTPSSM "Last position-specific scoring matrix computed\n"; 
shift @pssm; 

$title = shift @pssm; 
$line_pssm = $title; 
$line_pssm = substr($title, 0, 69); 
print OUTPSSM "$line_pssm\n"; 
chomp $title; 
$title =~ s/\s+//g;
if (length($title) != 40)
{
	die "aa number is wrong:$title.\n"; 
}
$title = substr($title, 20); 
if (length($title) != 20)
{
	die "aa number is wrong:$title.\n"; 
}

for ($i = 0; $i < $length; $i++)
{
	$line = shift @pssm;
	$line_pssm = $line; 
	$line_pssm = substr($line, 0, 69); 
	print OUTPSSM "$line_pssm\n"; 
	chomp $line; 
	@prof = split(/\s+/, $line); 

	shift @prof; 
	$pos = shift @prof;

	if ($pos != $i+1)
	{
		print "$line\n"; 
		print join(",", @prof), "\n"; 
		die "postion doesn't match.\n"; 
	}
	$aa = shift @prof; 
	if ($aa ne substr($seq, $i, 1))
	{
		die "aa doesn't match.\n"; 
	}
	for ($j = 0; $j < 20; $j++)
	{
		shift @prof; 
	}
	if (@prof != 22)
	{
		die "profile length doesn't match.\n"; 
	}
	for ($j = 0; $j < 20; $j++)
	{
		$amino = substr($title, $j, 1); 
		$idx = index($stdaa,$amino); 
		if ($idx >= 0)
		{
			$profile[$idx] = $prof[$j] / 100; 
		}
	}

	$prof = join(" ", @profile); 
	print OUTPUT "$prof\n"; 
}
print OUTPSSM @pssm; 
close OUTPSSM; 
close OUTPUT; 
#`rm $output.pssm`; 

