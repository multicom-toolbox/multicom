#!/usr/bin/perl -w
##############################################################################
#Generate all required files for a template fasta file(or dataset)
#for fold recognition.
#Input: option file, fasta file(fasta), and output dir 
#query sequence name is used to generate output file name
#query sequence name must not contain "." and white space. 
#	(better just alphanumeric, "_" or "-")
#option file: include path to prosys, pspro, and other alignment tools.
#Author: Jianlin Cheng
#Date: 08/19/2005
#
###############################################################################
#Modification: to use more sensitive options to generate profiles
#Date: 10/24/2007
#Author: Jianlin Cheng
###############################################################################
if (@ARGV != 3)
{
	die "need three parameters: option file(option_prep), fasta file(fasta), output dir\n"; 
}
$option_file = shift @ARGV; 
$fasta_file = shift @ARGV; 
$out_dir = shift @ARGV;

-f $option_file || die "can't read option file.\n"; 
-d $out_dir || die "can't open output dir.\n"; 

#read options
$blast_dir = "";
$clustalw_dir = ""; 
$palign_dir = "";
$tcoffee_dir = "";
$hmmer_dir = "";
$prosys_dir = "";
$prc_dir = ""; 
$hhsearch_dir = "";
$lobster_dir = ""; 
$compass_dir = ""; 
$pspro_dir = ""; 
$betapro_dir = ""; 
$cm_seq_dir = ""; 
$nr_dir = "";
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	if ($_ =~ /^blast_dir\s*=\s*(\S+)/)
	{
		$blast_dir = $1; 
	}
	if ($_ =~ /^nr_dir\s*=\s*(\S+)/)
	{
		$nr_dir = $1; 
	}
	if ($_ =~ /^clustalw_dir\s*=\s*(\S+)/)
	{
		$clustalw_dir = $1; 
	}
	if ($_ =~ /^palign_dir\s*=\s*(\S+)/)
	{
		$palign_dir = $1; 
	}
	if ($_ =~ /^tcoffee_dir\s*=\s*(\S+)/)
	{
		$tcoffee_dir = $1; 
	}
	if ($_ =~ /^hmmer_dir\s*=\s*(\S+)/)
	{
		$hmmer_dir = $1; 
	}
	if ($_ =~ /^prc_dir\s*=\s*(\S+)/)
	{
		$prc_dir = $1; 
	}
	if ($_ =~ /^hhsearch_dir\s*=\s*(\S+)/)
	{
		$hhsearch_dir = $1; 
	}
	if ($_ =~ /^lobster_dir\s*=\s*(\S+)/)
	{
		$lobster_dir = $1; 
	}
	if ($_ =~ /^compass_dir\s*=\s*(\S+)/)
	{
		$compass_dir = $1; 
	}
	if ($_ =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($_ =~ /^pspro_dir\s*=\s*(\S+)/)
	{
		$pspro_dir = $1; 
	}
	if ($_ =~ /^betapro_dir\s*=\s*(\S+)/)
	{
		$betapro_dir = $1; 
	}
	if ($_ =~ /^cm_seq_dir\s*=\s*(\S+)/)
	{
		$cm_seq_dir = $1; 
	}
}
close OPTION;

#check the existence of these directories 
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $nr_dir || die "can't find nr dir:$nr_dir.\n";
-d $clustalw_dir || die "can't find clustalw dir.\n";
-d $palign_dir || die "can't find palign dir.\n";
-d $tcoffee_dir || die "can't find tcoffee dir.\n";
-d $hmmer_dir || die "can't find hmmer dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n";
-d $lobster_dir || die "can't find lobster dir.\n";
-d $prosys_dir || die "can't find prosys dir.\n";
-d $pspro_dir || die "can't find pspro dir.\n";
-d $betapro_dir || die "can't find betapro dir.\n";
-d $cm_seq_dir || die "can't find cm_seq_dir dir.\n";

#generate template profile files using multiple threads
#system("$prosys_dir/script/gen_temp_files_proc.pl $option_file $fasta_file $out_dir 7"); 
system("$prosys_dir/script/gen_temp_files_proc.pl $option_file $fasta_file $out_dir 14"); 

