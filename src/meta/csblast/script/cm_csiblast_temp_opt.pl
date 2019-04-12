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
#-e option of blasting on PDB
$cm_blast_evalue = 1;
#-j option: iteration on PDb
$cm_blast_iteration = 5; 
#-h option: profile including evalue on PDB (old one is default:probably 0.001)
$cm_including_evalue = 0.001;

#-j option: iteration on NR
$nr_iteration_num = 3;
#-e option on NR
$nr_return_evalue = 0.001;
#-h option on NR (old one is set to : 0.0000000001. maybe too small)
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
	if ($line =~ /^csblast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$csblast_dir = $value; 
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
-d $csblast_dir || die "can't find csblast dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
if ($nr_dir ne "none")
{
	-d $nr_dir || die "can't find nr dir.\n";
}
if ($cm_blast_evalue <= 0 || $cm_blast_evalue > 10 || $cm_including_evalue <= 0 || $cm_including_evalue > 1)
{
	die "pdb blast evalue is out of range.\n"; 
}
if ($nr_return_evalue <= 0 || $nr_return_evalue > 1 || $nr_including_evalue <= 0 || $nr_including_evalue > 0.1)
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

#first search nr database to construct profile if necessary
if ($nr_db ne "none")
{
	#system("$blast_path/blastpgp -i $seq_file -o $seq_file.tmp -C $seq_file.chk -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue -d $nr_db");

	system("$csblast_dir/csblast_static -i $seq_file -d $nr_db -D $csblast_dir/K4000.lib  -o $seq_file.tmp -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue --blast-path $blast_path");

	system("$script_dir/process-blast.pl $seq_file.tmp $seq_file.talign $seq_file");
	system("$script_dir/msa2gde.pl $seq_file $seq_file.talign fasta $seq_file.prf");
	system("$csblast_dir/csbuild_static -i $seq_file.prf -O chk -D $csblast_dir/K4000.lib -I fas -o $seq_file.ck");

	system("$blast_path/blastpgp -i $seq_file -R $seq_file.ck -o $out_file -j $cm_blast_iteration -e $cm_blast_evalue -h $cm_including_evalue -d $temp_db"); 

	`rm $seq_file.tmp $seq_file.prf`; 
}
else  #don't use NR for profile building. Should never be used anymore.
{
	die "Should use NR database in blasting. Check cm options.\n";
}



