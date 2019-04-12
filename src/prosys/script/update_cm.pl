#!/usr/bin/perl -w
###################################################################
#Script to update cm library 
#Input: database option file. 
#Author: Jianlin Cheng
#Date: 10/13/05
###################################################################

if (@ARGV != 1)
{
	die "need 1 parameters: database option file.\n"; 
}

$db_option = shift @ARGV;

#################read option file##################################
open(OPTION, $db_option) || die "can't read option file.\n";

$cm_filter_resolution = 8;
$cm_filter_length = 30;
$cm_filter_ratio = 0.9; 

while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}
	if ($line =~ /^prosys_db_stat_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_db_stat_dir = $value; 
	}
	if ($line =~ /^set_seq_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_seq_dir = $value; 
	}
	if ($line =~ /^set_atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_atom_dir = $value; 
	}
	if ($line =~ /^set_work_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_work_dir = $value; 
	}
	if ($line =~ /^set_adjust_new_file/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_adjust_new_file = $value; 
	}
	if ($line =~ /^cm_library_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_library_dir = $value; 
	}
	if ($line =~ /^cm_database_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_database_name = $value; 
	}
	if ($line =~ /^cm_filter_length/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_filter_length = $value; 
	}
	if ($line =~ /^cm_filter_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_filter_resolution = $value; 
	}
	if ($line =~ /^cm_filter_ratio/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_filter_ratio = $value; 
	}
	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
	}

}
#####################End of reading options######################
-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $prosys_db_stat_dir || die "can't find database stat dir: $prosys_db_stat_dir\n";
-d $set_seq_dir || die "cna't find set seq dir: $set_seq_dir\n";
-d $set_atom_dir || die "can't find set atom dir: $set_atom_dir\n";
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $cm_library_dir || die "can't find cm library dir: $cm_library_dir\n";
-d $set_work_dir || die "can't find work dir: $set_work_dir\n";

$cm_filter_resolution >= 3 && $cm_filter_resolution <= 10 || die "cm filter resolution is out of range [3, 10].\n";
$cm_filter_length >= 1 && $cm_filter_length <= 100  || die "cm filter length is out of range [1,100].\n";
$cm_filter_ratio > 0 && $cm_filter_ratio < 1 || die "cm filter ration is out of range [0, 1].\n"; 

$set_adjust_new_file = "$set_work_dir/$set_adjust_new_file";
#this is the file the updated cm library will be generated on.
$adjust_set_file = "$set_adjust_new_file.work";
-f $adjust_set_file || die "can't find new dataset file to generate cm library.\n";

#select chains
system("$prosys_dir/script/select_chain.pl $adjust_set_file $adjust_set_file.sel $cm_filter_length $cm_filter_resolution $cm_filter_ratio");

#sort the dataset and generate fasta file
system("$prosys_dir/script/set2fasta_sort.pl $adjust_set_file.sel $set_work_dir/$cm_database_name.fasta");

#remove identical sequences
system("$prosys_dir/script/rm_same_fasta.pl $set_work_dir/$cm_database_name.fasta $set_work_dir/$cm_database_name.work");

#`rm $set_work_dir/$cm_database_name.fasta $adjust_set_file.sel`; 
`rm $adjust_set_file.sel`; 

#done.








