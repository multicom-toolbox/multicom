#!/usr/bin/perl -w
##############################################################################
#Generate all required files for a query fasta file for fold recognition.
#Input: option file, query file(fasta), and output dir 
#query sequence name is used to generate output file name
#query sequence name must not contain "." and white space. 
#	(better just alphanumeric, "_" or "-")
#option file: include path to prosys, pspro, and other alignment tools.
#Author: Jianlin Cheng
#Date: 08/19/2005
#
#Modify to regenerate multiple alignment file using more sensitive options
#on NR database
#Date: 10/24/2005
#Author: Jianlin Cheng
###############################################################################
if (@ARGV != 3)
{
	die "need three parameters: option file(option_prep), query file(fasta), output dir\n"; 
}
$option_file = shift @ARGV; 
$fasta_file = shift @ARGV; 
$out_dir = shift @ARGV;

-f $option_file || die "can't read option file.\n"; 
-d $out_dir || die "can't open output dir.\n"; 

#read fasta file
open(FASTA, $fasta_file) || die "can't read query file.\n";
$name = <FASTA>;
if ($name =~ /^>(\S+)/)
{
	$name = $1; 

	#check  if name is valid
	if ($name =~ /\./)
	{
		die "sequence name can't include .\n"; 
	}
}
else
{
	die "fasta file is not in fasta format.\n"; 
}
$seq = ""; 
$seq = <FASTA>;
close FASTA; 

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
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	if ($_ =~ /^blast_dir\s*=\s*(\S+)/)
	{
		$blast_dir = $1; 
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
}
close OPTION; 

#check the existence of these directories 
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $clustalw_dir || die "can't find clustalw dir.\n";
-d $palign_dir || die "can't find palign dir.\n";
-d $tcoffee_dir || die "can't find tcoffee dir.\n";
-d $hmmer_dir || die "can't find hmmer dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n";
-d $lobster_dir || die "can't find lobster dir.\n";
-d $prosys_dir || die "can't find prosys dir.\n";
-d $pspro_dir || die "can't find pspro dir.\n";
-d $betapro_dir || die "can't find betapro dir.\n";

#predict ss, sa, map, bmap, align, pssm for the sequence
system("$prosys_dir/script/predict_ssa_map.pl $pspro_dir $betapro_dir $fasta_file $out_dir"); 

#regenerate align file
`$prosys_dir/script/generate_flatblast_sens.pl $blast_dir $pspro_dir/script/ $pspro_dir/data/big/big_98_X $pspro_dir/data/nr/nr $fasta_file $out_dir/$name.align >/dev/null`; 

#generate chk file
system("$prosys_dir/script/psiblast_chk.pl $blast_dir $pspro_dir/data/nr/nr $fasta_file $out_dir"); 

#generate hmm file (hmmer)
system("$prosys_dir/script/generate_hmm.pl $prosys_dir/script $hmmer_dir $fasta_file $out_dir $out_dir");

#generate hhm file (hhsearch)
system("$prosys_dir/script/generate_hhm.pl $prosys_dir/script  $hhsearch_dir $fasta_file $out_dir $out_dir"); 

#generate aln file (clustalw format)
#system("$prosys_dir/script/generate_aln.pl $prosys_dir/script $clustalw_dir $fasta_file $out_dir $out_dir");
system("$prosys_dir/script/generate_aln_new.pl $prosys_dir/script $clustalw_dir $fasta_file $out_dir $out_dir");

#generate coach (lobster) file
system("$prosys_dir/script/generate_coach.pl $prosys_dir/script $lobster_dir $fasta_file $out_dir $out_dir");

#done (13 files associted with each sequence)
#verify if all files are generated
$prefix = "$out_dir/$name";
@suffix = ("bcm12a", "bcm8a", "bmap", "cm12a", "cm8a", "align", "aln", "chk", "fas", "hhm", "hmm", "lob", "pssm"); 
while (@suffix)
{
	$suf = shift @suffix;
	if (!-f "$prefix.$suf")
	{
		print "error: $prefix.$suf is not created.\n"; 
	}
}
print "\n";
