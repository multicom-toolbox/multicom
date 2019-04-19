#!/usr/bin/perl -w
##########################################################################
#Use clustalw to create aln format file from msa and query 
#input: script dir, clustalw dir, query file(fasta), query(msa), output file
#Author: Jianlin Cheng
#Modified from msa2hhm.pl
#Date: 7/25/2005
##########################################################################
if (@ARGV != 5)
{
	die "need five parameters: script dir, clustalw dir(clustalw), query file(fasta), query msa(from blast), output file.\n";
}
$script_dir = shift @ARGV;
$clustalw_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";
-d $clustalw_dir || die "can't find clustalw dir.\n";

$query_fasta = shift @ARGV;
-f $query_fasta || die "can't find query fasta file.\n";
open(QUERY, $query_fasta);
$code1 = <QUERY>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY;

$query_msa = shift @ARGV;
-f $query_msa || die "can't find query msa file.\n";

$out_file = shift @ARGV;

#convert fasta and msa to gde format multiple alignments
system("$script_dir/msa2gde.pl $query_fasta $query_msa gde $query_msa.gde");

#create aln from msa
system("$clustalw_dir/clustalw -INFILE=$query_msa.gde -OUTFILE=$out_file >/dev/null"); 

#check if aln file is generated.
if (! -f $out_file)
{
	#use fas2msa
	system("$script_dir/msa2gde.pl $query_fasta $query_msa fasta $query_msa.mfasta");
	system("$script_dir/fas2aln.pl $query_msa.mfasta $out_file"); 
	`rm $query_msa.mfasta`; 
}

`rm $query_msa.dnd $query_msa.gde`; 




