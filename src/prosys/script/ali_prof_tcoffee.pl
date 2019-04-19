#! /usr/bin/perl -w
#####################################################################
#Profile-Prof alignment using tcoffee 
#Input:
#   tcoffee program,  MSA file1(fasta), MSA file2(fasta), Output file
#Output:  alignment score, name1, aligned seq1, name2, aligned seq2
#Note: the first sequence in MSA1 and MSA2 are the sequences to align
#Modified from ali_prof_tcoffee.pl
#Author: Jianlin Cheng, Date: 5/06/2005
######################################################################
#tcoffee usage:
#-INFILE=file.ext: do multiple alignment, file in fasta format
#-PROFLE1=file1 -PROFILE2=file2  : profiles in fasta format
#-TYPE=: PROTEIN or DNA. 
#-OUTPUT=: msa output type: tcoffee
#######################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: tcoffee path, msa1 in fasta format, msa2 in fasta format, output file.\n"; 
}

$tcoffee = shift @ARGV;
if (! -f $tcoffee) { die "can't find $tcoffee.\n"; }; 
$prof1 = shift @ARGV;
$prof2 = shift @ARGV; 
$output = shift @ARGV; 
$idx = index($prof1, ".");

#get prefix name
if ($idx > 0)
{
	$prefix1 = substr($prof1, 0, $idx); 
}
else
{
	$prefix1 = $prof1; 
}
if ($prof1 =~ /(.+)\.fasta/)
{
	$prefix1 = $1;
}

$idx = index($prof2, ".");
if ($idx > 0)
{
	$prefix2 = substr($prof2, 0, $idx); 
}
else
{
	$prefix2 = $prof2; 
}
if ($prof2 =~ /(.+)\.fasta/)
{
	$prefix2 = $1;
}

open(PROF1, "$prof1") || die "can't read $prof1\n"; 
$name1 = <PROF1>;
chomp $name1; 
$name1 = substr($name1, 1); 
$seq1 = <PROF1>;
chomp $seq1; 

$norm_length1 = length($seq1); 

close PROF1;
open(PROF2, "$prof2") || die "can't read $prof2\n"; 
$name2 = <PROF2>;
chomp $name2; 
$name2 = substr($name2, 1); 
$seq2 = <PROF2>;
chomp $seq2; 
close PROF2;
$norm_length2 = length($seq2);

#system("$tcoffee -PROFILE1=$prof1 -PROFILE2=$prof2 -TYPE=PROTEIN -OUTFILE=$output.clu > $output.log");
open(STDERR, ">$output.err");
`$tcoffee -type=PROTEIN -output=clustalw -profile1=$prof1 -profile2=$prof2  > $output.log`;
close STDERR;
`mv $prefix1.aln $output.clu`; 

open(OUT, "$output.clu") || die "can't open alignment file.\n";
@ali = <OUT>;
close OUT; 
$title = shift @ali;
if ($title =~ /SCORE=([\d\.]+),/)
{
	$score = $1;
}
else
{
	die "the format of tcoffee output is wrong.\n";
}

$alignment1 = "";
$alignment2 = "";

while (@ali)
{
	$line = shift @ali;
	chomp $line; 
	if ($line =~ /$name1/)
	{
		@elements = split(/\s+/, $line); 	
		if ($elements[0] eq $name1)
		{
			$alignment1 .= $elements[1]; 
		}
	}
	if ($line =~ /$name2/)
	{
		@elements = split(/\s+/, $line); 	

		if ($elements[0] eq $name2)
		{
			$alignment2 .= $elements[1]; 
		}
	}
}

open(OUTPUT, ">$output") || die "can't create output file.\n";
$score1 = $score / $norm_length1;
$score2 = $score / $norm_length2;
print OUTPUT "$score1 $score2\n$name1\n$alignment1\n$name2\n$alignment2\n"; 
close OUTPUT;

`rm $output.log $output.clu`;
`rm $output.err`; 

#`rm $prefix1.dnd`;
#`rm $prefix2.dnd`;
