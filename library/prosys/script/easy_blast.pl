#! /usr/bin/perl -w
##############################################################################
#use psiblast to search template database to find homology templates
#inputs: option file, input file(in fasta), output file.
#output format: blastp output 
#Author: Jianlin Cheng
#modified from cm_psiblast_temp.pl
#Date: 10/07/2005
##############################################################################

if (@ARGV != 3)
{
	die "need three parameters: option file, seq file(fasta), output file\n";
}

#$blast_path = shift @ARGV;
#$nr_db = shift @ARGV;
#$temp_db = shift @ARGV;
$option_file = shift @ARGV;
$seq_file = shift @ARGV;
$out_file = shift @ARGV;
#$evalue = shift @ARGV;

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
$blast_dir = "";
$pdb_db_dir = "";
$nr_dir = "";

#initialized with default values
$cm_blast_evalue = 1;
$cm_blast_iteration = 5; 
$cm_including_evalue = 0.001;

$nr_iteration_num = 3;
$nr_return_evalue = 0.001;
$nr_including_evalue = 0.001;

while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^script_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$script_dir = $value; 
	#	print "$script_dir\n";
	}
	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}
	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}
	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}
	if ($line =~ /^cm_blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_evalue = $value; 
	}
	if ($line =~ /^cm_blast_iteration/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_iteration = $value; 
	}
	if ($line =~ /^cm_including_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_including_evalue = $value; 
	}
	if ($line =~ /^nr_iteration_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_iteration_num = $value; 
	}
	if ($line =~ /^nr_return_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_return_evalue = $value; 
	}
	if ($line =~ /^nr_including_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_including_evalue = $value; 
	}
}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
if ($nr_dir ne "none")
{
	-d $nr_dir || die "can't find nr dir.\n";
}
if ($cm_blast_evalue <= 0 || $cm_blast_evalue >= 10 || $cm_including_evalue <= 0 || $cm_including_evalue >= 1)
{
	die "pdb blast evalue is out of range.\n"; 
}
if ($nr_return_evalue <= 0 || $nr_return_evalue >= 10 || $nr_including_evalue <= 0 || $nr_including_evalue >= 10)
{
	die "nr blast evalue is out of range.\n"; 
}
if ($cm_blast_iteration < 1 || $cm_blast_iteration > 10 || $nr_iteration_num < 1 || $nr_iteration_num > 10)
{
	die "pdb/nr blasting iteration number  is out of range [1, 10].\n"; 
}


$blast_path = $blast_dir; 

$temp_db = "$pdb_db_dir/pdb_cm";

if (! -d $blast_path)
{
	die "can't find blast path: $blast_path\n";
}

$nr_db = "$nr_dir/nr";
if (! -f "$nr_db.pal")
{
if (! -f "$nr_db.phr" || !-f "$nr_db.pin" || !-f "$nr_db.psq")
{
	die "nr database doesn't exist.\n";
}
}

if (! -f "$temp_db.phr" || !-f "$temp_db.pin" || !-f "$temp_db.psq")
{
	die "template database doesn't exist.\n";
}

if (! -f $seq_file)
{
	die "sequence file does not exist.\n";
}

system("$blast_path/blastpgp -i $seq_file -o $out_file -j $cm_blast_iteration -e $cm_blast_evalue -d $temp_db"); 



