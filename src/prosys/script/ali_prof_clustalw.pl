#! /usr/bin/perl -w
#####################################################################
#Profile-Prof alignment using clustalw
#Input:
#   clustalw,  MSA file1, MSA file2, Output file
#Output:  alignment score, name1, aligned seq1, name2, aligned seq2
#Note: the first sequence in MSA1 and MSA2 are the sequences to align
#Author: Jianlin Cheng, Date: 1/18/2004
######################################################################
#clustalw usage:
#-INFILE=file.ext: do multiple alignment, file in fasta format
#-PROFLE1=file1 -PROFILE2=file2  : profiles in msa format
#-OPTIONS: list the command options
#-TYPE=: PROTEIN or DNA. 
#-OUTFILE=: sequence alignment file
#-OUTPUT=: msa input type: GCG, GDE, PHYLIP, PIR or NEXUS
#######################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: clustalw path, msa1 in gde format, msa2 in gde format, output file.\n"; 
}

$clustalw = shift @ARGV;
if (! -f $clustalw) { die "can't find $clustalw.\n"; }; 
$prof1 = shift @ARGV;
$prof2 = shift @ARGV; 
$output = shift @ARGV; 
$idx = index($prof1, ".");

if ($idx > 0)
{
	$prefix1 = substr($prof1, 0, $idx); 
}
else
{
	$prefix1 = $prof1; 
}
if ($prof1 =~ /(.+)\.gde/)
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
if ($prof2 =~ /(.+)\.gde/)
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

#system("$clustalw -PROFILE1=$prof1 -PROFILE2=$prof2 -TYPE=PROTEIN -OUTFILE=$output.clu > $output.log");
system("$clustalw -PWMATRIX=BLOSUM -PROFILE1=$prof1 -PROFILE2=$prof2 -TYPE=PROTEIN -OUTFILE=$output.clu > $output.log");

open(OUT, "$output.clu") || die "can't open alignment file.\n";
@ali = <OUT>;
close OUT; 

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

open(LOG, "$output.log") || die "can't open alignment log file.\n"; 
@log = <LOG>;
close LOG;
$score = $log[$#log-1]; 
chomp $score;
@elements = split(/:/, $score);
$score = pop @elements;

open(OUTPUT, ">$output") || die "can't create output file.\n";
$score1 = $score / $norm_length1;
$score2 = $score / $norm_length2;
print OUTPUT "$score1 $score2\n$name1\n$alignment1\n$name2\n$alignment2\n"; 
close OUTPUT;

`rm $output.log $output.clu`;

`rm $prefix1.dnd`;
`rm $prefix2.dnd`;
