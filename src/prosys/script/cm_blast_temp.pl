#! /usr/bin/perl -w
##############################################################################
#use blastall to search template database to find homology templates
#inputs: blast path, database path, input file(in fasta), output file.
#output format: blastp output 
#Author: Jianlin Cheng
#Date: 3/21/2005
##############################################################################

##########################################################################################
#NOTICE: the evalue might to increase according to the size of pdb database for the same 
#sequence to be found.
##########################################################################################

if (@ARGV != 7)
{
	die "need six parameters: blast path, temp database, seq file(fasta), output file, gapped(1:gapped(used most), 0:non-gapped), filter(0:non-filter(used most), 1:filter), e-value(1.0 for pdb)\n";
}

$blast_path = shift @ARGV;
$temp_db = shift @ARGV;
$seq_file = shift @ARGV;
$out_file = shift @ARGV;
$gapped = shift @ARGV;
$filter = shift @ARGV;
$evalue = shift @ARGV;

if (! -d $blast_path)
{
	die "can't find blast path: $blast_path\n";
}

if (! -f "$temp_db.phr" || !-f "$temp_db.pin" || !-f "$temp_db.psq")
{
	die "template database doesn't exist.\n";
}

if (! -f $seq_file)
{
	die "sequence file does not exist.\n";
}

#blast the database using blastall
#-F: filter query (false), -g: perform gapped alignment (false)
#here question: why we choose false for gapped alignment?
#-e: expectation value: currently set 0.05, need to tune later

#$command = "$blast_path/blastall -e 0.05 -i $seq_file -d $temp_db -p blastp ";
#$command = "$blast_path/blastall -e 0.1 -i $seq_file -d $temp_db -p blastp ";
$command = "$blast_path/blastall -e $evalue -i $seq_file -d $temp_db -p blastp ";
if ($gapped == 1)
{
	$command .= "-g T ";
}
else
{
	$command .= "-g F ";
}
if ($filter == 1)
{
	$command .= "-F T ";
}
else
{
	$command .= "-F F ";
}
#system("$blast_path/blastall -i $seq_file -d $temp_db -p blastp -F F -g F -o $out_file");
#gapped
#system("$blast_path/blastall -i $seq_file -d $temp_db -p blastp -F F -o $out_file");
#filtered
#system("$blast_path/blastall -i $seq_file -d $temp_db -p blastp -o $out_file");

$command .= "-o $out_file";
system("$command");



