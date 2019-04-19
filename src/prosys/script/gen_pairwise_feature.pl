#!/usr/bin/perl -w
##############################################################################
#Generate pairwise features for a query against a library (fasta set) 
#for fold recognition.
#Input: option file, fasta file(fasta), library fasta file, out file
#query sequence name must not contain "." and white space. 
#	(better just alphanumeric, "_" or "-")
#option file: include path to prosys, pspro, and other alignment tools.
#output file format: each pair has two lines. line 1: pair name line 2: features in svm format
#Author: Jianlin Cheng
#Date: 08/20/2005
###############################################################################
if (@ARGV != 4)
{
	die "need four parameters: option file(option_pairwise), query fasta file(fasta), template library fasta file, output feature file\n"; 
}
$option_file = shift @ARGV; 
$query_file = shift @ARGV; 
$lib_file = shift @ARGV;
$out_file = shift @ARGV;

-f $option_file || die "can't read option file.\n"; 

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
$template_dir = ""; 
open(OPTION, $option_file) || die "can't read option file.\n";
@options = <OPTION>;
close OPTION; 
foreach $line (@options)
{
	if ($line =~ /^blast_dir\s*=\s*(\S+)/)
	{
		$blast_dir = $1; 
	}
	if ($line =~ /^clustalw_dir\s*=\s*(\S+)/)
	{
		$clustalw_dir = $1; 
	}
	if ($line =~ /^palign_dir\s*=\s*(\S+)/)
	{
		$palign_dir = $1; 
	}
	if ($line =~ /^tcoffee_dir\s*=\s*(\S+)/)
	{
		$tcoffee_dir = $1; 
	}
	if ($line =~ /^hmmer_dir\s*=\s*(\S+)/)
	{
		$hmmer_dir = $1; 
	}
	if ($line =~ /^prc_dir\s*=\s*(\S+)/)
	{
		$prc_dir = $1; 
	}
	if ($line =~ /^hhsearch_dir\s*=\s*(\S+)/)
	{
		$hhsearch_dir = $1; 
	}
	if ($line =~ /^lobster_dir\s*=\s*(\S+)/)
	{
		$lobster_dir = $1; 
	}
	if ($line =~ /^compass_dir\s*=\s*(\S+)/)
	{
		$compass_dir = $1; 
	}
	if ($line =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($line =~ /^pspro_dir\s*=\s*(\S+)/)
	{
		$pspro_dir = $1; 
	}
	if ($line =~ /^betapro_dir\s*=\s*(\S+)/)
	{
		$betapro_dir = $1; 
	}
	if ($line =~ /^cm_seq_dir\s*=\s*(\S+)/)
	{
		$cm_seq_dir = $1; 
	}
	if ($line =~ /^template_dir\s*=\s*(\S+)/)
	{
		$template_dir = $1; 
	}
}

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
-d $cm_seq_dir || die "can't find cm_seq_dir dir.\n";
-d $template_dir || die "can't find template_dir.\n"; 

#read query file
open(QUERY, $query_file) || die "can't read query file.\n";
$name = <QUERY>;
close QUERY;
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
	die "query file is not in fasta format.\n"; 
}
	
#create a temporary option file
$query_dir = "$name-query";
`mkdir $query_dir`; 
$query_opt = "$name.opt";
open(QOPT, ">$query_opt") || die "can't create query option file.\n";
print QOPT join("", @options);
#set a new query dir
print QOPT "query_dir=$query_dir\n";
close QOPT; 

#generate query related files
system("$prosys_dir/script/gen_query_files.pl $query_opt $query_file $query_dir");
#might want to check if all files are generated.

#generate features
open(OUT, ">$out_file") || die "can't create output feature file.\n"; 
open(LIB, $lib_file) || die "can't read query file.\n";
@fasta = <LIB>;
while (@fasta)
{
	$temp = shift @fasta;
	if ($temp =~ /^>(\S+)/)
	{
		$temp = $1; 

		#check  if name is valid
		if ($temp =~ /\./)
		{
			die "sequence name can't include .\n"; 
		}
	}
	else
	{
		die "fasta file is not in fasta format.\n"; 
	}
	$seq = shift @fasta;
	print "process $temp: ";

	if ($temp eq $name)
	{
		print "query name is the same as template name. Skip!\n";
		next;
	}

	#create a temporary template file
	open(TEMP, ">$temp.fasta") || die "can't create $temp.fasta\n";
	print TEMP ">$temp\n$seq"; 
	close TEMP; 

	#generate pairwise features
	system("$prosys_dir/script/feature_complete.pl $query_file $temp.fasta $query_opt $temp.out >/dev/null"); 
	if (!open(RES, "$temp.out"))
	{
		`rm $temp.fasta`; 
		 print "can't read feature output file for $name vs $temp.\n";
		 next; 
	}
	$pair_name = <RES>;

	#check the consistency
	($pa, $pb) = split(/\s+/, $pair_name);
	<RES>;
	$feature = <RES>; #numbers separated by space
	close RES;

	if ($pa ne $name || $pb ne $temp)
	{
		print "pair ids ($name, $temp) don't match.\n"; 
		`rm $temp.fasta $temp.out`; 
		next; 
	}

	@attrs = split(/\s+/, $feature); 
	$size = @attrs;
	print "feature size = $size\n"; 
	print OUT "#$pair_name";
	#print OUT "#$feature\n";
	#set label to unknown
	print OUT "0";
	for ($i = 1; $i <= $size; $i++)
	{
		print OUT " $i:$attrs[$i-1]"; 
	}
	print OUT "\n"; 

	`rm $temp.fasta $temp.out`; 
	
	#remove the temporary file left by feature_complete.pl
	if (-f "gmon.out")
	{
		`rm gmon.out`; 
	}

}
close LIB; 
close OUT; 
`rm -r $query_dir`; 
`rm $query_opt`; 
