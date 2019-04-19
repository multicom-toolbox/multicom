#!/usr/bin/perl -w
############################################################
#Given a sequence, predict the ss, sa, cmap, bmap and also 
#generate msa file and pssm file
#Inputs: pspro dir, betapro dir, fasta file, output dir
#Notice: fasta file can contains more than one sequence
#fasta file format: >name,seq...(seq must be single line)
#Date: 4/30/2005
#Author: Jianlin Cheng
############################################################

if (@ARGV != 4)
{
	die "need four parameters: pspro dir, betapro dir, fasta file, output dir.\n";
}

$pspro_dir = shift @ARGV;
-d $pspro_dir || die "can't find pspro dir.\n";
$betapro_dir = shift @ARGV;
-d $betapro_dir || die "can't find betapro dir.\n";
$fasta_file = shift @ARGV;
$out_dir = shift @ARGV;
-d $out_dir || die "can't find output dir.\n";

open(FASTA, $fasta_file) || die "can't read fasta file.\n";
@fasta = <FASTA>;

while (@fasta)
{
	$name = shift @fasta;
	if ($name !~ /^>/)
	{
		die "fasta format error: $name";
	}
	chomp $name;
	$name = substr($name,1);
	#replace white space, . to _ in the name if there are some
	$name =~ s/[\s\.]/_/g;
	
	$seq = shift @fasta;
	
	#create a temporary file
	$tmp_file = "$out_dir/$name";
	open(TMP, ">$tmp_file") || die "can't create fasta file.\n";
	print TMP ">$name\n";
	print TMP $seq;
	close TMP;

	#predict ss, sa, cm
	print "predict ss, sa, cm using non-homoloy script.\n";
	system("$pspro_dir/bin/predict_ss_sa_cm.sh $tmp_file $out_dir"); 

	#predict beta residue pairs
	#create a input file first
	open(TMP, ">$tmp_file") || die "can't create input file for beta map.\n";
	print TMP "$name\n";
	if ($seq !~ /\n/)
	{
		$seq .= "\n";
	}
	print TMP $seq;

	#read ss sa from cm8a
	open(CM, "$out_dir/$name.cm8a") || die "can't read cm8a file:$name.\n";
	<CM>;
	$seq2 = <CM>;
	$ss = <CM>;
	$sa = <CM>;
	close CM;
	print TMP "$ss$sa";
	close TMP;

	#consistency checking
	if ($seq ne $seq2 || length($ss) != length($seq2) || length($sa) != length($seq2))
	{
		die "sequence, ss, sa don't match:\n$seq$seq2$ss$sa\n";
	}
	
	$align_file = "$out_dir/${name}balign";
	`cp $out_dir/${name}.align $align_file`;
	$bmap_file = "$out_dir/${name}.bmap";
	system("$betapro_dir/bin/predict_beta_simple.sh $tmp_file $align_file $bmap_file");

	#clean up
	`rm $align_file`; 
	`rm $out_dir/*.rr?`;
	`rm $out_dir/*.pxml`;
	`rm $out_dir/*.map`; 
	`rm $tmp_file`;
}
close FASTA;
