#!/usr/bin/perl -w
###########################################################################
#Create the hmm database for PRC 
#Inputs: prosys_database dir, PRC dir, output dir, output db name
#Output: sam hmm files for sor90 proteins, a joined db
#Author: Jianlin Cheng
#Start date: 12/31/2009
###########################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: prosys_db dir, sam dir, output dir, output db name.\n";
}

$prosysdb_dir = shift @ARGV;
$sam_dir = shift @ARGV;
$output_dir = shift @ARGV;
$prcdb = shift @ARGV;

-d $prosysdb_dir || die "can't find prosys db dir: $prosysdb_dir.\n";  
-d $sam_dir || die "can't find sam dir: $sam_dir.\n";
-d $output_dir || die "can't find output dir: $output_dir.\n";
$prcdb = $output_dir . "/$prcdb"; 
-f $prcdb || `>$prcdb`; 

$src_db = $prosysdb_dir . "/fr_lib/sort90"; 
-f $src_db || die "can't find sort90: $src_db.\n";
$align_dir = $prosysdb_dir . "/library/"; 
-d $align_dir || die "can't find $align_dir.\n";

use Cwd 'abs_path'; 
$output_dir = abs_path($output_dir); 

open(FASTA, $src_db) || die "can't read fasta file.\n";
@fasta = <FASTA>;
close FASTA;
$count = 0; 

open(ADD, ">$prcdb.add"); 

while (@fasta)
{
	$name = shift @fasta;
	chomp $name;
	if ($name =~ /^>(.+)/)
	{
		$name = $1;
	}
	else
	{
		print "$name\n";
		die "fasta format error.\n"; 
	}
	shift @fasta;

	#check if alignment file exists
	$align_file = "$align_dir/$name.fas";
	-f $align_file || die "can't find alignment file: $align_file.\n"; 

	#check if hmm15 file exists  
	$hmm_file = "$output_dir/$name.mod";
	if (-f $hmm_file) 
	{ 
		print "$name exists in the database. Skipped.\n";
		next; 
	}

	`cp $align_file $name.tmp.fas`;

	print "make hmm for $name...\n";
	#create hmm from msa
	system("$sam_dir/bin/w0.5 $name.tmp.fas $name.mod >/dev/null 2>&1"); 
	
	if (-f "$name.mod")
	{
		`mv $name.mod $output_dir`; 		
	}	
	else
	{
		print "failed to generate a PRC (i.e. SAM) model for $name. Skipped.\n";
		next; 
	}

	#add the file into the database
	print "add $name.mod into the database.\n";
	print ADD "$output_dir/$name.mod\n";

	$count++; 

	`rm $name.tmp.fas`; 
}

close ADD; 

if ($count > 0)
{
	`cat $prcdb.add >> $prcdb`; 
}
print "The database $prcdb has been updated. $count templates are added.\n";

