#!/usr/bin/perl -w
#####################################################################
#convert sequene file, its msa file into a msa in other format 
#inputs: 
#1. seq file in fasta format 
#2. msa file 
#3. format(gde, fasta, clustal...., right now only gde and fasta are implemented). 
#Here: we need to support PIR format, which is preferred by 
# Modeller. 
#4. output msa file
#Author: Jianlin Cheng, 1/18/2005
####################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: input seq file(fasta), msa file, format(gde, fasta) output msa file.\n";
}
$input_file = shift @ARGV;
$msa_file = shift @ARGV;
$format = shift @ARGV; 
$output_file = shift @ARGV; 

open(INPUT_FILE, $input_file) || die "can't open input file.\n";
$name = <INPUT_FILE>;
chomp $name; 
$name = substr($name,1); 
$seq = <INPUT_FILE>;
chomp $seq; 
$length = length($seq); 
close INPUT_FILE; 


if (! -f $msa_file)
{
	print "alignment file: $msa_file doesn't exist.\n"; 
	$num = 0; 
}
else
{
	open(MSA, "$msa_file"); 
	@ali = <MSA>; 
	$num = shift @ali; 
	close MSA; 
}

open(OUTPUT_FILE, ">$output_file") || die "can't create output file.\n";

#remove the exact same sequence from msa
@uniq = (); 
#the first sequence is the query sequence
push @uniq, $seq; 
foreach $entry (@ali)
{
	$found = 0;
	chomp $entry; 
	foreach $record (@uniq)
	{
		if ($entry eq $record)
		{
			$found = 1; 
			last;
		}
	}
	if ($found == 0)
	{
		push @uniq, $entry; 
	}
}

if ($format eq "gde" || $format eq "fasta")
{
	#print OUTPUT_FILE "\%$name\n$seq\n"; 
	#for ($i = 1; $i <= $num; $i++)
	$i = 0;
	foreach $line (@uniq)
	{
		#$line = shift @ali; 
		$line =~ s/\./-/g; 
		#chomp $line; 
		if (length($line) != $length)
		{
			die "length doesn't match: $seq\n$line\n"; 
		}
		if ($i == 0)
		{
			if ($format eq "gde")
			{
				print OUTPUT_FILE "\%$name", "\n$line\n"; 
			}
			elsif ($format eq "fasta")
			{
				print OUTPUT_FILE ">$name", "\n$line\n"; 
			}
		}
		else
		{
			if ($format eq "gde")
			{
				print OUTPUT_FILE "\%$name", $i, "\n$line\n"; 
			}
			else
			{
				print OUTPUT_FILE ">$name", $i, "\n$line\n"; 
			}
		}
		$i++;
	}
}
else
{
	die "format: $format is not supported. \n"; 
}

close OUTPUT_FILE; 

