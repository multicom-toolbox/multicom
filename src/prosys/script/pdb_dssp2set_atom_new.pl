#!/usr/bin/perl -w
############################################################################
#input: script dir, pdb file, dssp file, output dssp set
#ouput: sequence file for each chain, atom file for each chain and dssp set
#Author: Jianlin Cheng
#Date: 03/30/2005 (rewrite, due to accident deletion)
############################################################################
if (@ARGV != 4)
{
	die "need parameters: script dir, pdb file, dssp file, dssp set.\n";
}
$script_dir = shift @ARGV;
$pdb_file = shift @ARGV;
$dssp_file = shift @ARGV;
$dssp_set = shift @ARGV;

if (! -d $script_dir)
{
	die "script dir doesn't exist.\n";
}
-f $pdb_file || die "can't read pdb file.\n";
-f $dssp_file || die "can't read dssp file.\n";

$pos = rindex($dssp_file, "/");
if ($pos >= 0)
{
	$tmp_file = substr($dssp_file, $pos + 1) . ".tmp";
}
else
{
	$tmp_file = $dssp_file . ".tmp";
}

#get resolution 
system("$script_dir/getres.pl $pdb_file $tmp_file");
open(RES, $tmp_file) || die "can't read resolution output file.\n";
<RES>;
$resolution = <RES>;
close RES;
`rm $tmp_file`; 

#dssp to dataset
system("$script_dir/dssp2dataset.pl $dssp_file $tmp_file");
open(RES, $tmp_file) || die "can't read dssp 2 data set output.\n";
@content = <RES>;
close RES;
`rm $tmp_file`; 

open(SET, ">$dssp_set") || die "can't create dssp dataset file.\n";

while (@content)
{
	$name = shift @content;
	$length = shift @content;
	$seq = shift @content;
	$mapping = shift @content;
	$ss = shift @content;
	$bp1 = shift @content;
	$bp2 = shift @content;
	$sa = shift @content;
	$xyz = shift @content;
	$blank = shift @content;

	#check integrity before proceed
	@vec_seq = split(/\s+/, $seq);
	@vec_ss = split(/\s+/, $ss);
	@vec_sa = split(/\s+/, $sa);
	if ($length != @vec_seq || $length != @vec_ss || $length != @vec_sa)
	{
		print "$name, in generated set from dssp file, length is not consistent.\n";
		next;
	}

	print SET "$name$resolution$length$seq$mapping$ss$bp1$bp2$sa$xyz$blank";

	$filename = $name;
	chomp $filename;
	open(TMP, ">$filename.set.tmp") || die "can't create tmp chain file.\n";
	print TMP "$name$length$seq$mapping$ss$bp1$bp2$sa$xyz$blank";
	close TMP;

	if (-f "$filename.seq")
	{
		print "$filename.seq already exists, no thing generated.\n";
		`rm $filename.set.tmp`; 
		next; 
	}

	#get atom for this chain 
	system("$script_dir/get_atom_new.pl $filename.set.tmp $pdb_file $filename.atom $filename.seq");
	`rm $filename.set.tmp`; 

	#open the chain file and add resolution
	if (!open(CHAIN, "$filename.seq"))
	{
		next; 
	}
	@info = <CHAIN>;
	close CHAIN;
	$line1 = shift @info;
	$line2 = shift @info;
	open(CHAIN, ">$filename.seq"); 
	print CHAIN "$line1$line2$resolution";
	#print "line1: $line1";
	#print "line2: $line2";
	#print "resolution: $resolution";
	#print "*******\n";
	#print join("", @info);
	#print "press any key....\n";
	#<STDIN>;
	print CHAIN join("", @info);  
	close CHAIN;
}

close SET;

