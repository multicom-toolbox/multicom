#!/usr/bin/perl -w
################################################################################
#Convert fasta format MSA to aln (clustalw) format. 
#Input: fasta msa file, output file
#clustal format:
#	title, two new lines, 8 chars per line for each segment, 80(blank,*or :), newline.
#Author: Jianlin Cheng
#Date: 7/31/2005
################################################################################
if (@ARGV != 2)
{
	die "need two parameters: input fasta msa file, output file.\n";
}
$fas_file = shift @ARGV;
$out_file = shift @ARGV;

open(FAS, $fas_file) || die "can't read file $fas_file.\n";
@fas = <FAS>;
close FAS; 

@names = ();
@seqs = ();

while (@fas)
{
	$name = shift @fas;
	chomp $name;
	$name = substr($name, 1); 
	push @names, $name;
	$seq = shift @fas;
	chomp $seq; 
	push @seqs, $seq; 
}

if (@names != @seqs)
{
	die "number of sequences doesn't match with number of names.\n";
}

open(OUT, ">$out_file") || die "can't create output file: $out_file.\n";

print OUT "CLUSTAL W (1.83) multiple sequence alignment\n\n"; 


$length = length($seqs[0]); 
$num = @seqs; 
for ($i = 0; $i < $num; $i++)
{
	$aligns[$i] = sprintf("%20s", $names[$i]); 
}

for ($i = 0; $i < $length; $i++)
{
	if ($i % 60 == 0)
	{
		if (length($aligns[0]) > 20)
		{
			print OUT "\n"; 
			print OUT join("\n", @aligns);
			printf OUT "\n%80s\n", " ";
		}
		for ($j = 0; $j < $num; $j++)
		{
			$aligns[$j] = sprintf("%-20s", $names[$j]); 
		}

	}
	for ($j = 0; $j < $num; $j++)
	{
		#print "$seqs[$j]\n";
		#print "$i\n";
		#<STDIN>;
		$aligns[$j] .= substr($seqs[$j], $i, 1); 
	}
}

if (length($aligns[0]) > 20)
{
	print OUT "\n"; 
	print OUT join("\n", @aligns);
	print OUT "\n"; 
	for ($i = 0; $i < length($aligns[0]); $i++)
	{
		printf OUT " ";
	}
	print OUT "\n"; 
}

close OUT; 




