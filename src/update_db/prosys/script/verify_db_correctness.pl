#!/usr/bin/perl -w
###################################################################
#verify the correctness of the database
#Input: database option file, missing cm, missing fr template 
#Author: Jianlin Cheng
#Date: 10/14/05
###################################################################

if (@ARGV != 3)
{
	die "need 4 parameters: database option file, cm missing file, fr missing file.\n"; 
}

$db_option = shift @ARGV;
$cm_missing_file = shift @ARGV;
$fr_missing_file = shift @ARGV; 

#################read option file##################################
open(OPTION, $db_option) || die "can't read option file.\n";

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

	if ($line =~ /^fr_template_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_template_dir = $value; 
	}

	if ($line =~ /^fr_template_library_file/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_template_library_file = $value; 
	}

	if ($line =~ /^fr_template_library_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_template_library_dir = $value; 
	}

}
#####################End of reading options######################
-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $set_seq_dir || die "cna't find set seq dir: $set_seq_dir\n";
-d $set_atom_dir || die "can't find set atom dir: $set_atom_dir\n";
-d $set_work_dir || die "can't find work dir: $set_work_dir\n";
-d $cm_library_dir || die "can't find cm library dir: $cm_library_dir\n";
-d $fr_template_dir || die "can't find fr template dir: $fr_template_dir\n";
-d $fr_template_library_dir || die "can't find fr template library dir:$fr_template_library_dir.\n";

#check cm correctness
print "verify cm database...\n";
$cm_file = "$cm_library_dir/$cm_database_name";
-f $cm_file || die "can't find cm library file: $cm_file\n";
system("$prosys_dir/script/verify_cm.pl $cm_file $set_seq_dir $set_atom_dir $cm_missing_file");

#check fr correctness
print "verify fr database...\n";
$fr_file = "$fr_template_library_dir/$fr_template_library_file";
-f $fr_file || die "can't find fr library file: $fr_file\n";
system("$prosys_dir/script/verify_temp.pl $fr_file $fr_template_dir $fr_missing_file"); 

