#!/usr/bin/perl -w
###############################################################
#Author: Jianlin Cheng
############################################################### 
#2018 version

#$pdb_dir = "/home/chengji/casp8/hhpred/pdb";
$pdb_dir = "/home/jh7x3/multicom_beta1.0/src/meta/hhpred/pdb";

if (@ARGV == 1)
{
	$list = shift @ARGV;
}
else
{
	die "please provide an output file name\n";
}

opendir(PDB, $pdb_dir) || die "can't open $pdb_dir\n";
@files = readdir PDB;
closedir PDB;
open(LIST, ">$list") || die "can't create $list\n";

$count = 0;
while (@files)
{

	
	$file = shift @files;
	if ($file ne "." && $file ne "..")
	{
		$name = substr($file, 0, 6);	
		print LIST "$name\n";	
		$count++;
	}
	
}

print "total number of hmms: $count\n";

close LIST; 



