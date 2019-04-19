#!/usr/bin/perl -w
#generate profile for one sequence using frequence  
#inputs: 
#1. seq file in fasta format 
#2. msa file 
#4. output profile file (format: name, length, seq, profile for each position )
#Author: Jianlin Cheng, 1/17/2005

#non-standard aa are treated as a gap
$stdaa = "ACDEFGHIKLMNPQRSTVWY";

if (@ARGV != 3)
{
	die "need parameters: input seq file(fasta), msa file, output file.\n";
}
$input_file = shift @ARGV;
$msa_file = shift @ARGV;
$output_file = shift @ARGV; 

open(INPUT_FILE, $input_file) || die "can't open input file.\n";
open(OUTPUT_FILE, ">$output_file") || die "can't create output file.\n";

$name = <INPUT_FILE>;
chomp $name; 
$name = substr($name,1); 
$seq = <INPUT_FILE>;
chomp $seq; 
$length = length($seq); 
close INPUT_FILE; 

print OUTPUT_FILE "$name\n$length\n$seq\n"; 

$bmsa = 1; 
if (! -f $msa_file)
{
	print "alignment file: $msa_file doesn't exist.\n"; 
	$bmsa = 0; 
	$num = 0; 
}
else
{
	open(MSA, "$msa_file"); 
	@ali = <MSA>; 
	$num = shift @ali; 
	close MSA; 
}

for ($t = 0; $t < $length; $t++)
{
	@pssm = (); 
	for ($i = 0; $i < 20; $i++)
	{
		$pssm[$i] = 0; 
	}
	#count postion t for sequence
	$amino = substr($seq,$t,1); 
	$idx = index($stdaa,$amino); 
	if ($idx >= 0)
	{
		$pssm[$idx]++; 
	}

	$freq = 0; 

	#process msa
	if ($bmsa == 1)
	{
		for ($m = 0; $m < $num; $m++)
		{
			$homo_seq = $ali[$m]; 
			$homo_seq = uc($homo_seq); 
			if ( $t < length($homo_seq) )
			{
				$amino = substr($homo_seq,$t,1); 
			}
			else
			{
				die "amino acid doesn't exist\n"; 
				$amino = "not found"; 
			}
			$idx = index($stdaa,$amino); 
			if ($idx >= 0)
			{
				$pssm[$idx]++; 
				$freq++; 
			}
		}
	}
	#normalize msa
	for ($i = 0; $i < 20; $i++)
	{
		$pssm[$i] /= ($freq+1); 
	}
	$prof = join(" ", @pssm); 
	print OUTPUT_FILE "$prof\n"; 

}
close OUTPUT_FILE; 
