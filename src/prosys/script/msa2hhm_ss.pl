#!/usr/bin/perl -w
##########################################################################
#Use hhmake32 to create hhm profiles from msa and query using SS info.
#input: script dir, hmmer dir, query file(fasta), query(msa), output file
#the file including SS info can be 9-line set file or cm8a file.
#Author: Jianlin Cheng
#Modified from msa2hhm.pl
#Date: 7/25/2005
##########################################################################
if (@ARGV != 7)
{
	die "need 7 parameters: script dir, hhsearch dir(hhsearch), query file(fasta), query msa(from blast), ss file(*.set, *.cm8a), ss format(set or map) output file.\n";
}
$script_dir = shift @ARGV;
$hhsearch_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n";

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


#read set file or contact map file.
$ss_file = shift @ARGV;
-f $ss_file || die "can't find set or contact map file:$ss_file.\n";

$ss_format = shift @ARGV;

$out_file = shift @ARGV;
if ($ss_format eq "set")
{
	$title = ">ss_dssp";
	$title0 = ">aa_dssp";
	open(SS, $ss_file) || die "can't read $ss_file.\n"; 
	<SS>;<SS>;<SS>;
	$ss = <SS>;
	chomp $ss; 
	#replace all the dots with C
	$ss =~ s/\./C/g; 
	#replace all the spaces with empty
	$ss =~ s/\s//g; 
	if (length($ss) != length($seq1))
	{
		die "length of true SS is not equal to the sequence length.\n"; 
	}
}
elsif ($ss_format eq "map")
{
	$title = ">ss_pred"; 
	$title0 = ">aa_pred"; 
	open(SS, $ss_file) || die "can't read $ss_file.\n"; 
	<SS>;<SS>;
	$ss = <SS>;
	chomp $ss; 
	if (length($ss) != length($seq1))
	{
		die "length of true SS is not equal to the sequence length.\n"; 
	}
}
else
{
	die "msa2hhm_ss.pl: ss format error.\n"; 
}

#convert fasta and msa to gde format multiple alignments
system("$script_dir/msa2gde.pl $query_fasta $query_msa fasta $query_msa.fas");

#insert secondary stx information into the fasta file.
open(FAS, "$query_msa.fas") || die "can't read query fasta file.\n";
@fas = <FAS>;
close FAS; 
open(FAS, ">$query_msa.fas") || die "can't overwrite fasta file:$query_msa.fas.\n";
print FAS "$title0\n$seq1\n"; 
print FAS "$title\n$ss\n"; 
print FAS join("",@fas);
close FAS;

#create hmm from msa
system("$hhsearch_dir/hhmake32 -i  $query_msa.fas -o $out_file >/dev/null"); 

`rm $query_msa.fas`; 

