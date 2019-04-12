#!/usr/bin/perl -w
######################################################################
#Parse the output of ffas search
#Input: name, ffas output file, file name for template rank list, file
#name for local alignments
#Output: ranked template list and local alignments
#Author: Jianlin Cheng
#Date: 11/24/2011
######################################################################

if (@ARGV != 4)
{
	die "need four parameters: query name, ffas search result file, output file name for ranked templates, output file name for local alignments.\n";
}

$query_name = shift @ARGV; 
$ffas_file = shift @ARGV;
$rank_file = shift @ARGV;
$local_align_file = shift @ARGV; 

#generate rank list and local alignment file
open(FFAS, "$ffas_file") || die "can't read ffas output file: $ffas_file\n";
@ffas = <FFAS>;
close FFAS; 
open(RANK, ">$rank_file") || die "can't create rank file: $rank_file\n";
print RANK "Rank templates for $ffas_file\n";

open(LOCAL, ">$local_align_file") || die "can't create local alignment file: $local_align_file.\n";
#generate a title file without meaning
print LOCAL "$query_name 1 1 1 1\n"; 

#remove title
shift @ffas;
shift @ffas; 

$index = 0; 
while (@ffas)
{
	$value = shift @ffas;	
	chomp $value; 
	if ($value eq ">*")
	{
		last;
	}

	@fields = split(/\s+/, $value);	
	$zscore = $fields[1];
	$tid = $fields[2];
	$tname = substr($tid, 2); 
	$tlen = $fields[5]; 
	$index++; 
	print RANK "$index\t$tname\t$zscore\n"; 
	
	$qalign = shift @ffas;
	chomp $qalign;
	$talign = shift @ffas; 
	chomp $talign; 

	if ($qalign =~ /\s+(\d+)\s+(.+)/)
	{
		$qstart = $1; 
		$qseq = $2; 	
		$qend = $1; 
		for ($i = 1; $i < length($qseq); $i++)
		{
			if (substr($qseq, $i, 1) ne "-")
			{
				$qend++; 
			} 
		}
	}
	if ($talign =~ /\s+(\d+)\s+(.+)/)
	{
		$tstart = $1; 
		$tseq = $2; 	
		$tend = $1; 
		for ($i = 1; $i < length($tseq); $i++)
		{
			if (substr($tseq, $i, 1) ne "-")
			{
				$tend++; 
			} 
		}
	}

	print LOCAL "\n";
	print LOCAL "$tname\t$tlen\t$index\t$index\t$index\t$index\t$index\n";
	print LOCAL "$qstart\t$qend\t$tstart\t$tend\n";
	print LOCAL "$qseq\n";
	print LOCAL "$tseq\n";

}
close RANK; 
close LOCAL; 


