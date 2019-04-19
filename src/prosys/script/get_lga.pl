#!/usr/bin/perl
#
# run_lga.pl
# script to evaluate molecule pairs (model.target) using LGA program
#
# Adam Zemla, 08/19/2002 
# updated by Lucy Forrest 10/16/2004 (email: lrf2103@columbia.edu)
#
# usage: ./run_lga.pl model target selected_parameters
#
# modified by Arlo Randall to just return GDT_TS
#	12/30/2004
#####################################################################
#Modified by Jianlin Cheng to make it run from anywhere
#Date: 3/28/2006
#####################################################################

#if (@ARGV != 6)
#{
#	die "need 6 parameters: lga exe dir(~/prosys/gdt/LGA_package), pdb file1, pdb file2, -3, -atom:CA, -d:4\n";	
#}

if (@ARGV != 3)
{
	die "need 3 parameters: lga exe dir(~/prosys/gdt/LGA_package), pdb file1, pdb file2";	
}

#append additional parameters
push @ARGV, ("-3", "-atom:CA", "-d:4");

$|=1;

#$exe_dir = "/var/preserve/eval/gdt/gdt_ts";
$exe_dir = shift @ARGV;
-f "$exe_dir/lga" || die "can't find lga program.\n";

# executable
$lga_program = "$exe_dir/lga";
# $lga_program = "lga.linux";

# subdirectory for results
$dirres = "MOL2/";

# --------------------------------------------------------------------- #

# usage 
if (@ARGV < 2) { die "\nUsage:\n\t$0 mol1 mol2 params\n\nSee http://as2ts.llnl.gov/ for help\n\n"; }

$par="@ARGV";
$res='.res';
$pdb='.pdb';
$lga='.lga';
$d='.';

# print "\n";
if (!-d $dirres) 
{ 
	mkdir($dirres); 
	#print "Making $dirres for output (*$res) files\n"; 
}
# print "LGA results (*$res data) are stored in ./$dirres\n";

# read input parameters and filenames
$entrmol1=$ARGV[0];
$entrmol2=$ARGV[1];
$ARGV[0]="";
$ARGV[1]="";
if (!-e $entrmol1) { die "\nError: $entrmol1 doesn't exist\n\n"; }
if (!-e $entrmol2) { die "\nError: $entrmol2 doesn't exist\n\n"; }

@LINE=split(/\//,$entrmol1);
@R=reverse(@LINE);
$mol1=$R[0];
@LINE=split(/\//,$entrmol2);
@R=reverse(@LINE);
$mol2=$R[0];

$par="@ARGV";

# subdirectory for input. LGA takes input from MOL2 directory
$pdbs = 'MOL2/';
if (!-d $pdbs) 
{ 
	mkdir($pdbs); 
	#print "Making $pdbs for input files\n"; 
}
# print "\nPutting PDB input for $lga_program in ./$pdbs\n";
sleep 1;

# create input file for LGA
$model="$mol1$d$mol2";

# print "Processing structures in: $pdbs$model\n";
system "echo 'MOLECULE $mol1' > $pdbs$model ";
system "cat $entrmol1 | grep -v '^MOLECULE ' | grep -v '^END' >> $pdbs$model ";
system "echo 'END' >> $pdbs$model ";
system "echo 'MOLECULE $mol2' >> $pdbs$model ";
system "cat $entrmol2 | grep -v '^MOLECULE ' | grep -v '^END' >> $pdbs$model ";
system "echo 'END' >> $pdbs$model ";

# temp directory with outputs from LGA. LGA puts $pdb and $lga results to TMP directory
$tmp='TMP/';
if (!-d $tmp) 
{ 
	mkdir($tmp); 
	#print "Making $tmp for output (*$pdb and *$lga) files\n"; 
}
# print "Putting *$pdb and *$lga distances in ./$tmp\n";
sleep 1;

# run LGA - it knows to look in MOL2 for the input...
# print "Running: $lga_program $model $par\n";
system "$exe_dir/lga $model $par > $dirres$model$res";
# sleep 5;
if (-z "$dirres$model$res") { die "\nError: Problem running $lga_program\n"; }
sleep 1;

# tidy up
if (!-e "$tmp/$model$pdb") { print "Warning: $lga_program didn\'t rotate structures. No PDB output. Check parameters!\n"; }
system "cat $tmp/$model$pdb >> $dirres$model$res";
sleep 1;

# removing input and output files after the processing is done ...
system "rm -rf $pdbs/$model $tmp/$model$lga $tmp/$model$pdb";

# print "Done! \n";

$line = `grep "SUMMARY" $dirres$model$res`;
@row = split(/\s+/,$line);
$gdt_ts = $row[6];
print $gdt_ts."\n";


system "rm $dirres$model$res";
`rm -r MOL2 TMP`;

exit;
