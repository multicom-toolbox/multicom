#!/usr/bin/perl -w
#####################################################################
#Generate hhm profiles from qeuries and blast alignments for hhsearch
#Inputs: script_dir, fasta file(1 or more sequence), alignment dir, output dir.
#hhm file name = sequence_name.hhm
#Modified from generate_hmm.pl (for hmmer)
#Author: Jianlin Cheng
#Date: 7/25/2005
#####################################################################
if (@ARGV != 5)
{
	die "need five parameters: script_dir,hmmer dir(hmm2.3.2), input fasta file, alignment dir, output dir.\n";
}
$script_dir = shift @ARGV;
$hhsearch_dir = shift @ARGV;
$fasta_file = shift @ARGV;
$align_dir = shift @ARGV;
$out_dir = shift @ARGV;

-d $script_dir || die "can't find script dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n"; 
-d $align_dir || die "can't find alignment dir.\n";
-d $out_dir || die "can't find output dir.\n";

open(FASTA, $fasta_file) || die "can't read fasta file.\n";
@fasta = <FASTA>;
close FASTA;
while (@fasta)
{
	$name = shift @fasta;
	chomp $name;
	if ($name =~ /^>(.+)/)
	{
		$name = $1;
	}
	else
	{
		print "$name\n";
		die "fasta format error.\n"; 
	}
	$seq = shift @fasta;

	#check if alignment file exists
	$align_file = "$align_dir/$name.align";
	-f $align_file || die "can't find alignment file: $align_file.\n"; 

	#create a temporary file
	open(TMP, ">$name.fasta.tmp") || die "can't create temporary file.\n";
	print TMP ">$name\n";
	print TMP $seq;
	close TMP;

	$out_file = "$out_dir/$name.hhm";

	#create hmm files
	system("$script_dir/msa2hhm.pl $script_dir $hhsearch_dir $name.fasta.tmp $align_file $out_file");
	`rm $name.fasta.tmp`; 
}

