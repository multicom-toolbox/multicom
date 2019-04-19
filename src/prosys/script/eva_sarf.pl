#!/usr/bin/perl -w

#########################################################
#Given a list, generate pairwise stx alignment use sarf2
#Input: script dir, sarf dir, prot1, prot2 (pdb file)
#Output: pairwise stx alignment scores
#Jianlin Cheng, Date: 4/19/05
##########################################################

if (@ARGV != 4)
{
	die "need 4 params: script_dir, sarf dir, pdb 1, pdb2.\n"; 
}

$script_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n"; 
$sarf_dir = shift @ARGV;
$sarf = "$sarf_dir/sarf";
-f $sarf || die "can't find sarf.\n"; 

$pdb1 = shift @ARGV; 
$pdb2 = shift @ARGV;
-f $pdb1 || die "can't read pdb file1: $pdb1\n";
-f $pdb2 || die "can't read pdb file2: $pdb2\n";

#$output = shift @ARGV;

#open(OUT, ">$output") || die "can't create output file.\n";
#copy the ALPHA AND BETA FILE to here
#if (-f "ALPHA" || -f "BETA" || -f "PARAM")
#{
#	die "there are ALPHA, BETA, or PARAM file in current dir. please remove them first or save them to a safe places.\n";
#}
`cp $script_dir/sarfALPHA ALPHA`; 
`cp $script_dir/sarfBETA BETA`; 
#copy the PARAM file to here
`cp $script_dir/sarfPARAM ./PARAM`; 

#copy the pdb files to current dir
`cp $pdb1 1.pdb 2>/dev/null`;
`cp $pdb2 2.pdb 2>/dev/null`; 

#strip the path of pdb files
$pos = rindex($pdb1, "/");
if ($pos >= 0)
{
	$pdb1 = substr($pdb1, $pos + 1); 
}
$pos = rindex($pdb2, "/");
if ($pos >= 0)
{
	$pdb2 = substr($pdb2, $pos + 1); 
}

print "compare $pdb1 with $pdb2\n"; 

#create x list
open(XL, ">xl");
print XL "1.pdb\n";
close XL; 

#create y list
open(YL, ">yl");
print YL "2.pdb\n";
close YL;
#run sarf
system("$sarf > sarf_tmp.txt"); 
#take results
open(RES, "sarf_results") || die "can't read results.\n"; 
$line = <RES>;
print $line;
close RES;
`rm sarf_results`; 
#print OUT $line; 
#read results from log file
open(TMP, "sarf_tmp.txt");
while (<TMP>)
{
	$line = $_; 
	if ($line =~ /Ca-atoms/)
	{
		print $line; 
		last; 
	}
}
close TMP; 
print "\n"; 
#`rm sarf_tmp.txt`; 
#`rm ALPHA BETA PARAM`; 
#`rm core.* 2> /dev/null`; 
#close OUT; 
