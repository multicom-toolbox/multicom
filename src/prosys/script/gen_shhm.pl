#!/usr/bin/perl -w
###############################################################
#Generate shhm file from HHSearch hhm file by adding true SS
#Inputs: prosys dir, libary dir, seq dir.
#Output: shhm files in library dir
#Author: Jianlin Cheng
#Date: 10/10/2007
###############################################################

if (@ARGV != 3)
{
	die "need three parameters: prosys dir, prosys db library dir, prosys db seq dir.\n";
}

$prosys_dir = shift @ARGV;
-d $prosys_dir || die "can't find $prosys_dir.\n";
$lib_dir = shift @ARGV;
-d $lib_dir || die "can't find $lib_dir.\n";
$seq_dir = shift @ARGV;
-d $seq_dir || die "can't find $seq_dir.\n";


opendir(LIB, $lib_dir) || die "can't open $lib_dir.\n";
@files = readdir(LIB);
close LIB;

while (@files)
{
	$file = shift @files;
	if ($file !~ /(.+)\.hhm$/)
	{
		next;
	}
	$pfile = "$lib_dir/$file"; 	
	
	$sfile = "$seq_dir/$1.seq"; 

	if (! -f $sfile)
	{
	 	warn "cannot find $sfile.\n";
		next;
	}

	#add ss into hhm
	$hfile = "$lib_dir/$1.shhm";
	system("$prosys_dir/script/addtss2hhm.pl $sfile $pfile > $hfile");
}

