#!/usr/bin/perl -w
########################################################################
#Build Fold Recognition Library
#Inputs: script dir, blast dir, old library file(fasta), candidate file(fasta), identity threshold, new library file (only include new added chains)
#if old library doesn't exist, just input a non-existed file.
#to standard output: total number of selected sequences, ids and identity. 
#Author: Jianlin Cheng
#Modified from build_library_blast.pl
#Date: 10/13/2005.
#########################################################################

if (@ARGV != 6)
{
	die "need 6 parameters: script dir, blast dir, old library(fasta or empty), candidate file(fasta), identity threshold(0.95,0.97,0.98), new library(fasta).\n";
}

$script_dir = shift @ARGV;
$blast_dir = shift @ARGV; 

-d $script_dir || die "script dir doesn't exist.\n";
-d $blast_dir || die "blast dir doesn't exist.\n"; 

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

@update_lib = (); 

while (@can)
{
	
	$name = shift @can;
	$size = @cur_lib; 
	chomp $name;
	$name = substr($name, 1); 
	$size /= 2; 
	print "process: $name, lib size = $size, "; 
	$seq = shift @can; 

	#Need to filter out invaid sequences
	#1. remove all X sequences
	#2. remove sequences short than 20 residues (not very strict). 
	$filter_seq = $seq;
	chomp $filter_seq;
	if (length($filter_seq) <= 20)
	{
		print "skip: less than 20 residues.\n";
		next; 
	}
	if ($filter_seq =~ /^X+$/)
	{
		print "skip: all residues are X.\n"; 
		next; 
	}

	if ($size <= 0)
	{
		push @cur_lib,">$name\n";
		push @cur_lib,"$seq"; 
		push @update_lib, ">$name\n";
		push @update_lib, "$seq";
		push @select,"$name 0\n"; 
		print "included.\n";
		next; 
	}

	#create a tempary query file.
	open(QUERY, ">$name.query") || die "can't create query file.\n"; 
	print QUERY ">$name\n$seq";
	close QUERY; 

	#write the current library file
	#clean up the tempoaray files
	`rm $old_lib.lib* 2>/dev/null`; 
	open(CUR, ">$old_lib.lib") || die "can't create current library file.\n"; 
	print CUR join("", @cur_lib);
	close CUR; 

	#check the identity
	system("$script_dir/highest_identity_blast.pl $script_dir $blast_dir $name.query $old_lib.lib > $name.ide");

	#read the identity
	if ( open(IDE, "$name.ide"))
	{
		$ide = <IDE>;
		$temp_name = <IDE>;
		close IDE; 
	}
	else
	{
	   warn "can't read identity results for $name.ide\n";
	   $ide = -1; 
	}

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
		#print "identity = $ide, included.\n";
		push @cur_lib,">$name\n";
		push @cur_lib,"$seq"; 
		push @update_lib, ">$name\n";
		push @update_lib, "$seq";
		push @select,"$name $ide\n"; 
	}
	else
	{
		chomp $temp_name;
		@temps = split(/\s+/, $temp_name);
		$temp_name = $temps[1];
		#print "identity = $ide, $temp_name, discarded.\n";
	}
	

	`rm $name.query $name.ide $old_lib.lib`; 
}

#output the new library.
if (@select > 0)
{
	open(NEWLIB, ">$new_lib") || die "can't create new library.\n";
	print NEWLIB join("", @update_lib); 
	close NEWLIB; 

	$size = @select;
	print "$size sequences are added.\n";
	#print join("", @select), "\n"; 
}
else
{
	print "0 new sequence is added. no new library is generated.\n"; 
}

