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

#read fasta file
open(FASTA, $fasta_file) || die "can't read query file.\n";
@fasta = <FASTA>;
while (@fasta)
{
	$name = shift @fasta;
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
	$seq = shift @fasta;
	print "process $name...\n";

	#create a temporary file
	open(TEMP, ">$name.fasta") || die "can't create $name.fasta\n";
	print TEMP ">$name\n$seq"; 
	close TEMP; 

	#predict ss, sa, map, bmap, align, pssm for the sequence
	print "Generate alignment...\n";
	#generate alignment file
	$align_file = "$out_dir/$name.align"; 

	`$pspro_dir/script/generate_flatblast.pl $blast_dir $pspro_dir/script/ $pspro_dir/data/big/big_98_X $nr_dir/nr $name.fasta $align_file >/dev/null`;

	#use more sensitive blast options on NR database
	#`$prosys_dir/script/generate_flatblast.pl $blast_dir $pspro_dir/script/ $pspro_dir/data/big/big_98_X $pspro_dir/data/nr/nr $name.fasta $align_file >/dev/null`;
	`mv $align_file.pssm $out_dir/$name.pssm`; 


	#generate chk file
	system("$prosys_dir/script/psiblast_chk.pl $blast_dir $nr_dir/nr $name.fasta $out_dir"); 

	#generate hmm file (hmmer)
	system("$prosys_dir/script/generate_hmm.pl $prosys_dir/script $hmmer_dir $name.fasta $out_dir $out_dir");

	#generate hhm file (hhsearch)
	system("$prosys_dir/script/generate_hhm.pl $prosys_dir/script  $hhsearch_dir $name.fasta $out_dir $out_dir"); 

	#generate aln file (clustalw format)
	#system("$prosys_dir/script/generate_aln.pl $prosys_dir/script $clustalw_dir $name.fasta $out_dir $out_dir");
	system("$prosys_dir/script/generate_aln_new.pl $prosys_dir/script $clustalw_dir $name.fasta $out_dir $out_dir");

	#generate coach (lobster) file
	system("$prosys_dir/script/generate_coach.pl $prosys_dir/script $lobster_dir $name.fasta $out_dir $out_dir ");

	#covert 12-line seq file to 9-line set file
	$seq_file = $cm_seq_dir . "/$name.seq"; 
	if (open(SEQ, $seq_file))
	{
		@info = <SEQ>;
		close SEQ; 
		if (@info != 12)
		{
			die "$seq_file doesn't have 12-lines.\n"; 
		}
		open(SET, ">$out_dir/$name.set") || die "can't create set file:$out_dir/$name.set\n";
		#consistency checking
		$temp = $info[4];
		$temp =~ s/\s//g; 
		if ( length($temp) != $info[3])
		{
			print "seq=$temp, length=$info[3]";
			die "$name: sequence length doesn't match.\n"; 
		}
		print SET "$info[1]$info[3]$info[4]$info[6]$info[7]$info[8]$info[9]$info[10]$info[11]";
		close SET; 
	}
	else
	{
		warn "12-line seq file: $seq_file is not found.\n"; 
	}

	########################################################################
	#convert hhm file to shhm file (10/11/2007)
	if (-f $seq_file)
	{
		system("$prosys_dir/script/addtss2hhm.pl $seq_file $out_dir/$name.hhm > $out_dir/$name.shhm");
	}
	########################################################################
	

	#done (9 files associted with each sequence)
	#verify if all files are generated
	$prefix = "$out_dir/$name";
	@suffix = ("align", "aln", "chk", "fas", "hhm", "hmm", "lob", "pssm", "set", "shhm"); 
	while (@suffix)
	{
		$suf = shift @suffix; 
		if (!-f "$prefix.$suf")
		{
			print "error: $prefix.$suf is not created.\n"; 
		}
	}
	print "\n"; 

	`rm $name.fasta`; 

}
close FASTA; 
