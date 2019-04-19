#!/usr/bin/perl -w
########################################################################
#Build Fold Recognition Library
#Inputs: script dir, clustalw dir, old library file(fasta), candidate file(fasta), identity threshold, new library file
#if old library doesn't exist, just input a non-existed file.
#to standard output: total number of selected sequences, ids and identity. 
#Author: Jianlin Cheng
#Date: 8/3/2005.
#########################################################################

if (@ARGV != 6)
{
	die "need 6 parameters: script dir, clustalw dir, old library(fasta or empty), candidate file(fasta), identity threshold(0.95,0.97,0.98), new library(fasta).\n";
}

$script_dir = shift @ARGV;
$clustal_dir = shift @ARGV; 

-d $script_dir || die "script dir doesn't exist.\n";
-d $clustal_dir || die "clustalw dir doesn't exist.\n"; 

$old_lib = shift @ARGV;
$can_file = shift @ARGV;
$threshold = shift @ARGV;
$new_lib = shift @ARGV; 

#read the old library
@cur_lib = (); 
if ( -f $old_lib && $old_lib ne "empty") 
{
	open(OLD, $old_lib) || die "can't read old library file.\n"; 
	@cur_lib = <OLD>;
	close OLD; 
}

open(CAN, $can_file) || die "can't read candidate file.\n";
@can = <CAN>;
close CAN; 

@select = (); 

while (@can)
{
	
	$name = shift @can;
	$size = @cur_lib; 
	chomp $name;
	$name = substr($name, 1); 
	$size /= 2; 
	print "process: $name, lib size = $size\n"; 
	$seq = shift @can; 

	#create a tempary query file.
	open(QUERY, ">$name.query") || die "can't create query file.\n"; 
	print QUERY ">$name\n$seq";
	close QUERY; 

	#write the current library file
	open(CUR, ">$old_lib.lib") || die "can't create current library file.\n"; 
	print CUR join("", @cur_lib);
	close CUR; 

	#check the identity
	system("$script_dir/highest_identity.pl $script_dir $clustal_dir $name.query $old_lib.lib > $name.ide");

	#read the identity
	open(IDE, "$name.ide") || die "can't read identity results: $name.ide\n";
	$ide = <IDE>;
	close IDE; 

	if ($ide =~ /highest identity=([\.\d]+)/ )
	{
		$ide = $1; 
	}
	else
	{
		warn "$name, identity not returned, use -1.\n"; 
		$ide = -1; 
	}

	if ($ide < $threshold)
	{
		push @cur_lib,">$name\n";
		push @cur_lib,"$seq"; 
		push @select,"$name $ide\n"; 
	}
	

	`rm $name.query $name.ide $old_lib.lib`; 
}

#output the new library.
if (@select > 0)
{
	open(NEWLIB, ">$new_lib") || die "can't create new library.\n";
	print NEWLIB join("", @cur_lib); 
	close NEWLIB; 

	$size = @select;
	print "$size sequences are added.\n";
	print join("", @select), "\n"; 
}
else
{
	print "0 new sequence is added. no new library is generated.\n"; 
}

