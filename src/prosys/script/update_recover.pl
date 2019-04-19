#!/usr/bin/perl -w
###################################################################
#Script o recover database from catalog file. 
#Input: database option file, catalog file. 
#Author: Jianlin Cheng
#Date: 10/16/05
###################################################################

if (@ARGV != 2)
{
	die "need 2 parameters: database option file, catalog file.\n"; 
}

$db_option = shift @ARGV;
$catalog_file = shift @ARGV;

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
	if ($line =~ /^cm_database_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_database_name = $value; 
	}
	if ($line =~ /^cm_library_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_library_dir = $value; 
	}

	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
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

	if ($line =~ /^fr_template_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$fr_template_dir = $value; 
	}
	if ($line =~ /^set_dssp_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_dssp_dir = $value; 
	}
	if ($line =~ /^main_pdb_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$main_pdb_dir = $value; 
	}
	if ($line =~ /^set_pdb_source_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_pdb_source_dir = $value; 
	}
}
#####################End of reading options######################
-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $set_seq_dir || die "cna't find set seq dir: $set_seq_dir\n";
-d $set_atom_dir || die "can't find set atom dir: $set_atom_dir\n";
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $set_work_dir || die "can't find work dir: $set_work_dir\n";
-d $fr_template_library_dir || die "can't find fr template library dir:$fr_template_library_dir.\n";
-d $cm_library_dir || die "can't find cm library dir: $cm_library_dir\n";
-d $fr_template_dir || die "can't find fr template dir.\n";
-d $set_dssp_dir || die "can't find set dssp dir.\n";
-d $main_pdb_dir || die "can't find main pdb dir.\n";
-d $set_pdb_source_dir || die "can't find pdb source dir.\n";

#get update name
if ($catalog_file =~ /sync_catalog\.(.+)$/)
{
	$update_time = $1;
}
else
{
	die "$catalog_file doesn't has a valid file name.\n";
}

print "start to recover from catalog file: $catalog_file...\n";

open(CATALOG, "$catalog_file") || die "can't read catalog file: $catalog_file\n";
@catalog = <CATALOG>;
close CATALOG;

$current_cm_lib = "$cm_library_dir/$cm_database_name";
$current_fr_lib = "$fr_template_library_dir/$fr_template_library_file";
$current_fr30_lib = "$fr_template_library_dir/sort30";
$current_stx_info = "$cm_library_dir/chain_stx_info";
$current_pdb_all = "$cm_library_dir/pdb_cm_all_sel.fasta";

$old_cm_lib = "$current_cm_lib.$update_time";
$old_fr_lib = "$current_fr_lib.$update_time";
$old_fr30_lib = "$current_fr30_lib.$update_time";
$old_stx_info = "$current_stx_info.$update_time";
$old_pdb_all = "$current_pdb_all.$update_time";
if (! -f $old_cm_lib)
{
	die "backup $old_cm_lib doesn't exist. stop recover.\n";
}
if (! -f $old_fr_lib)
{
	die "backup $old_fr_lib doesn't exist. stop recover.\n";
}

#revert to old library file
`cp $old_cm_lib $current_cm_lib`;
`cp $old_fr_lib $current_fr_lib`;
`cp $old_fr30_lib $current_fr30_lib`;
if (-f $old_stx_info)
{
	#this is not essentially information, so update is not very strict.
	`cp $old_stx_info $current_stx_info`; 
}
if (-f $old_pdb_all)
{
	#this is not essentially information, so update is not very strict.
	`cp $old_pdb_all $current_pdb_all`; 
}

#format cm database
use Cwd;
$curr_dir = getcwd;
chdir $cm_library_dir;
system("$blast_dir/formatdb -i  $cm_database_name");
chdir $curr_dir;

#######################################Build Catalog file###############################################
#remove files
@pdb_files = ();
@dssp_files = ();
@seq_files = ();
@atom_files = ();
@fr_files = ();

while (@catalog)
{
	$line = shift @catalog;
	chomp $line;
	if ($line =~ /^new pdb files: (.+)/)
	{
		@pdb_files = split(/\s+/, $1);
	}
	if ($line =~ /^new dssp files: (.+)/)
	{
		@dssp_files = split(/\s+/, $1);
	}
	if ($line =~ /^new seq files: (.+)/)
	{
		@seq_files = split(/\s+/, $1);
	}
	if ($line =~ /^new atom files: (.+)/)
	{
		@atom_files = split(/\s+/, $1);
	}
	if ($line =~ /^new fr files: (.+)/)
	{
		@fr_files = split(/\s+/, $1);
	}
}

foreach $file (@pdb_files)
{
	`rm $main_pdb_dir/$file`; 
}

foreach $file (@dssp_files)
{
	`rm $set_dssp_dir/$file`;
}

foreach $file (@fr_files)
{
	`rm $fr_template_dir/$file`;
}

foreach $file (@seq_files)
{
	`rm $set_seq_dir/$file`;
}

foreach $file (@atom_files)
{
	`rm $set_atom_dir/$file`;
}


print "verify database after recovery...\n";
$current_cm_lib = "$cm_library_dir/$cm_database_name";
if (!-f $current_cm_lib)
{
	print "COMPLETE WITH ERROR: can't find cm library file. stop.\n";	
	goto END;
}

$current_fr_lib = "$fr_template_library_dir/$fr_template_library_file";
if (!-f $current_fr_lib)
{
	print "COMPLETE WITH ERROR: can't find fr library file. stop.\n";	
	goto END;
}
if (!-f $current_fr30_lib)
{
	print "COMPLETE WITH ERROR: can't find fr30 library file. stop.\n";	
	goto END;
}


$cm_miss_file = "$set_work_dir/cm_miss.chk";
$fr_miss_file = "$set_work_dir/fr_miss.chk";
system("$prosys_dir/script/verify_db_correctness.pl $db_option $cm_miss_file $fr_miss_file");

open(CM_MISS, $cm_miss_file) || die "can't read cm miss file.\n";
@cm_miss = <CM_MISS>;
close CM_MISS;
if (@cm_miss > 0)
{
	print "COMPLETE WITH ERROR: some templates cm library doesn't have seq or atom files. stop.\n";	
	goto END;
}

open(FR_MISS, $fr_miss_file) || die "can't read fr miss file.\n";
@fr_miss = <FR_MISS>;
close FR_MISS;
if (@fr_miss > 0)
{
	print "COMPLETE WITH ERROR: some templates fr library doesn't have required files. stop.\n";	
	goto END;
}
print "COMPLETE WITH SUCCESS.\n";
#######################################End of Verify Correctness#######################################


END:

