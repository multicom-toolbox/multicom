#!/usr/bin/perl -w
#####################################################################
#Generate hmm profiles from qeuries and blast alignments
#Inputs: script_dir, fasta file(1 or more sequence), alignment dir, output dir.
#hmm file name = sequence_name.hmm
#Author: Jianlin Cheng
#Date: 5/7/2005
#####################################################################
if (@ARGV != 5)
{
	die "need five parameters: script_dir,hmmer dir(hmm2.3.2), input fasta file, alignment dir, output dir.\n";
}
$script_dir = shift @ARGV;
$hmmer_dir = shift @ARGV;
$fasta_file = shift @ARGV;
$align_dir = shift @ARGV;
$out_dir = shift @ARGV;

-d $script_dir || die "can't find script dir.\n";
-d $hmmer_dir || die "can't find hmmer dir.\n"; 
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

	$out_file = "$out_dir/$name.hmm";

	#create hmm files
	system("$script_dir/msa2hmm.pl $script_dir $hmmer_dir $name.fasta.tmp $align_file $out_file");
	`rm $name.fasta.tmp`; 
}

