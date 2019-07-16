#!/usr/bin/perl -w
###################################################################
#Script o synchronize database. Add new pdb files, dssp files,
#seq files, atom files, pdb_cm library, sort90 fr library
#Input: database option file. 
#Author: Jianlin Cheng
#Date: 10/14/05
###################################################################

if (@ARGV != 1)
{
	die "need 1 parameters: database option file.\n"; 
}

$db_option = shift @ARGV;

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
-d $prosys_db_stat_dir || die "can't find database stat dir: $prosys_db_stat_dir\n";
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


#this file is the basis for the new fr library file
if (!-f  "$set_work_dir/$cm_database_name.work")
{
	die "can't find the updated cm fasta library file.\n";
}

$old_fr_lib = $fr_template_library_dir . "/" . $fr_template_library_file;
if (!-f $old_fr_lib)
{
	print "no old fr library fasta file exists. set to empty.\n";
	$old_fr_lib = "empty";
}


$log_file = "$set_work_dir/sync_db.log";
-f $log_file || `> $log_file`; 
open(LOG, ">>$log_file") || die "can't create database synchronization log file.\n";


$update_time = `date`;
chomp $update_time;
$update_time =~ s/\s/_/g; 
print LOG "\n-----------------------------------------------------\n";
print LOG "Update start time: $update_time\n"; 

#check if the last update finished correctly
$state_file = "$set_work_dir/critical";
#record the last update state:
if ( -f $state_file)
{
	print "the last update crashed in critical region or not finished correctly. please recover from previous update. stop.\n";
	print LOG "the last update crashed in critical region or not finished correctly. please recover from previous update. stop.\n";
	goto END;
}

#log dir is used to store all kinds of updating log files.
$log_dir = "$set_work_dir/log";
-d $log_dir || `mkdir $log_dir`; 

$catalog_file = "$set_work_dir/sync_catalog.$update_time";
open(CATALOG, ">$catalog_file") || die "can't create catalog file: $catalog_file\n";

print LOG "catelog file: $catalog_file\n";

print "Synchronize the database using new templates...\n";

###########verify the corretness of the current database: call verify_db_correctness.pl#########
print "step 1: check the correctness of the current database.\n";
print LOG "step 1: check the correctness of the current database.\n";

$current_cm_lib = "$cm_library_dir/$cm_database_name";
if (!-f $current_cm_lib)
{
	print "can't find cm library file. please fix it. stop.\n";	
	print LOG "can't find cm library file. please fix it. stop.\n";	
	goto END;
}

$current_fr_lib = "$fr_template_library_dir/$fr_template_library_file";
if (!-f $current_fr_lib)
{
	print "can't find fr library file. please fix it. stop.\n";	
	print LOG "can't find fr library file. please fix it. stop.\n";	
	goto END;
}

##############################################################################
#add hhserach db files (shhm) (added 10/11/2007)
$current_hhsearch_lib = "$fr_template_library_dir/hhsearchdb";
if (!-f $current_hhsearch_lib)
{
	print "can't find hhsearch library file. please fix it. stop.\n";	
	print LOG "can't find hhsearch library file. please fix it. stop.\n";	
	goto END;
}
##############################################################################

$cm_miss_file = "$set_work_dir/cm_miss.chk";
$fr_miss_file = "$set_work_dir/fr_miss.chk";
system("$prosys_dir/script/verify_db_correctness.pl $db_option $cm_miss_file $fr_miss_file");

open(CM_MISS, $cm_miss_file) || die "can't read cm miss file.\n";
@cm_miss = <CM_MISS>;
close CM_MISS;
if (@cm_miss > 0)
{
	print "some templates cm library doesn't have seq or atom files. please fix it. stop.\n";	
	print LOG "some templates cm library doesn't have seq or atom files. please fix it. stop.\n";	
	goto END;
}

open(FR_MISS, $fr_miss_file) || die "can't read fr miss file.\n";
@fr_miss = <FR_MISS>;
close FR_MISS;
if (@fr_miss > 0)
{
	print "some templates fr library doesn't have required files. please fix it. stop.\n";	
	print LOG "some templates fr library doesn't have required files. please fix it. stop.\n";	
	goto END;
}
print "the current database is correct.\n";
print LOG "the current database is correct.\n";
#######################################End of Verify Correctness#######################################

#######################################Cross verification##############################################
print "step 2: cross verification.\n";
print LOG "step 2: cross verification.\n";

#all new files (dssp, pdb, seq, atom should not appear in the current database)
sub compare_dir
{
	my ($src_dir, $dest_dir) = @_;
	-d $src_dir || die "can't find source dir: $src_dir\n";
	-d $dest_dir || die "can't find dest dir: $dest_dir\n";
	opendir(SRC, $src_dir) || die "can't read $src_dir\n";
	my @files = readdir SRC;
	closedir SRC;
	while (@files)
	{
		my $file = shift @files;
		if ($file eq "." || $file eq "..")
		{
			next; 
		}
		if (-f "$dest_dir/$file")
		{
			#found
			return 1; 
		}
		else
		{
			return 0; 
		}
	}
}
if (&compare_dir("$set_work_dir/pdb", $main_pdb_dir) == 1)
{
	print "some new pdb files appear in main pdb dir. stop.\n";	
	print LOG "some new pdb files appear in main pdb dir. stop.\n";	
	goto END;
}
if (&compare_dir("$set_work_dir/dssp", $set_dssp_dir) == 1)
{
	print "some new dssp files appear in main dssp dir. stop.\n";	
	print LOG "some new dssp files appear in main dssp dir. stop.\n";	
	goto END;
}
if (&compare_dir("$set_work_dir/fr", $fr_template_dir) == 1)
{
	print "some new fr files appear in main fr dir. stop.\n";	
	print LOG "some new fr files appear in main fr dir. stop.\n";	
	goto END;
}
if (&compare_dir("$set_work_dir/seq", $set_seq_dir) == 1)
{
	print "some new seq files appear in main seq dir. stop.\n";	
	print LOG "some new seq files appear in main seq dir. stop.\n";	
	goto END;
}
if (&compare_dir("$set_work_dir/atom", $set_atom_dir) == 1)
{
	print "some new atom files appear in main atom dir. stop.\n";	
	print LOG "some new atom files appear in main atom dir. stop.\n";	
	goto END;
}


#current library file
$current_cm_lib = "$cm_library_dir/$cm_database_name";
$current_fr_lib = "$fr_template_library_dir/$fr_template_library_file";

$current_fr30_lib = "$fr_template_library_dir/sort30";

$new_cm_file = "$set_work_dir/$cm_database_name.work";
$new_fr_file = "$set_work_dir/$fr_template_library_file.work";

#all ids in new cm and fr files should not appear in the current cm library (don't need to check current
#fr library).
#read current id list.

open(CM, $current_cm_lib) || die "can't read current cm library file.\n";
@current_cm = <CM>;
close CM;
@cm_list = ();
while (@current_cm)
{
	$name = shift @current_cm;
	chomp $name;
	$name = substr($name,1);
	shift @current_cm;
	push @cm_list, $name;
}

open(NEWCM, $new_cm_file) || die "can't read new cm library file.\n";
@new_cm = <NEWCM>;
close NEWCM;
@new_cm_list = ();
while (@new_cm)
{
	$name = shift @new_cm;
	chomp $name;
	$name = substr($name,1);
	shift @new_cm;
	push @new_cm_list, $name;
}

@new_cm_list_catalog = @new_cm_list;

while (@new_cm_list)
{
	$found = 0;
	$name = shift @new_cm_list;
	foreach $entry (@cm_list)
	{
		if ($entry eq $name)
		{
			$found = 1; 
		}
	}
	if ($found == 1)
	{
		print "error: some proteins in the new cm library appers in the current cm library. stop.\n";
		print LOG "error: some proteins in the new cm library appers in the current cm library. stop.\n";
		goto END;
	}
}

@new_fr_list = ();
if (-f $new_fr_file)
{
	open(NEWFR, $new_fr_file) || die "can't read new fr library file.\n";
	@new_fr = <NEWFR>;
	close NEWFR;
	while (@new_fr)
	{
		$name = shift @new_fr;
		chomp $name;
		$name = substr($name,1);
		shift @new_fr;
		push @new_fr_list, $name;
	}

}
else
{
	print "Warning: $new_fr_file is empty. Continue to update.\n";
}

print LOG "cross verification is ok.\n";
print "cross verification is ok.\n";
#######################################End of Cross Verification#######################################

#######################################Build Catalog file###############################################
print "build update catalog...\n";
print LOG "build update catalog...\n";

print CATALOG "new pdb files:";
$new_pdb_dir = "$set_work_dir/pdb";
if (! opendir(DIR, $new_pdb_dir) )
{
	print  "can't read work pdb dir.\n";
	print  LOG "can't read work pdb dir.\n";
	goto END;
}
@file_list = readdir DIR; 
closedir DIR;
while (@file_list)
{
	$file = shift @file_list;
	if ($file ne "." && $file ne "..")
	{
		print CATALOG " $file";
	}
}
print CATALOG "\n";

print CATALOG "new dssp files:";
$new_dssp_dir = "$set_work_dir/dssp";
if (! opendir(DIR, $new_dssp_dir) )
{
	print  "can't read work dssp dir.\n";
	print  LOG "can't read work dssp dir.\n";
	goto END;
}
@file_list = readdir DIR; 
closedir DIR;
while (@file_list)
{
	$file = shift @file_list;
	if ($file ne "." && $file ne "..")
	{
		print CATALOG " $file";
	}
}
print CATALOG "\n";

print CATALOG "new seq files:";
$new_seq_dir = "$set_work_dir/seq";
if (! opendir(DIR, $new_seq_dir) )
{
	print  "can't read work seq dir.\n";
	print  LOG "can't read work seq dir.\n";
	goto END;
}
@file_list = readdir DIR; 
closedir DIR;
while (@file_list)
{
	$file = shift @file_list;
	if ($file ne "." && $file ne "..")
	{
		print CATALOG " $file";
	}
}
print CATALOG "\n";

print CATALOG "new atom files:";
$new_atom_dir = "$set_work_dir/atom";
if (! opendir(DIR, $new_atom_dir) )
{
	print  "can't read work atom dir.\n";
	print  LOG "can't read work atom dir.\n";
	goto END;
}
@file_list = readdir DIR; 
closedir DIR;
while (@file_list)
{
	$file = shift @file_list;
	if ($file ne "." && $file ne "..")
	{
		print CATALOG " $file";
	}
}
print CATALOG "\n";

print CATALOG "new fr files:";
$new_fr_dir = "$set_work_dir/fr";
if (! opendir(DIR, $new_fr_dir) )
{
	print  "can't read work fr dir.\n";
	print  LOG "can't read work fr dir.\n";
	goto END;
}
@file_list = readdir DIR; 
closedir DIR;
while (@file_list)
{
	$file = shift @file_list;
	if ($file ne "." && $file ne "..")
	{
		print CATALOG " $file";
	}
}
print CATALOG "\n";

print CATALOG "new cm templates: ", join(" ", @new_cm_list_catalog), "\n";
print CATALOG "new fr templates: ", join(" ", @new_fr_list), "\n";

close CATALOG;
#######################################End of Building Catalog##########################################


#######################################Move files########################################################
#moving pdb files is tricky. they are only links. so should move files in the input pdb source dir to
#the main pdb dir.
#this regions is a critical region

#first backup the current library
$current_cm_lib = "$cm_library_dir/$cm_database_name";
`cp $current_cm_lib $current_cm_lib.$update_time`; 
$current_fr_lib = "$fr_template_library_dir/$fr_template_library_file";
`cp $current_fr_lib $current_fr_lib.$update_time`; 

`cp $current_fr30_lib $current_fr30_lib.$update_time`; 

$current_stx_info = "$cm_library_dir/chain_stx_info";
if (! -f $current_stx_info)
{
	#create the file
	`> $current_stx_info`; 
}
#backup the stx information file
`cp $current_stx_info $current_stx_info.$update_time`; 

$current_pdb_all = "$cm_library_dir/pdb_cm_all_sel.fasta";
if (! -f $current_pdb_all)
{
	#create the file
	`> $current_pdb_all`; 
}
#backup the all selected pdb sequences 
`cp $current_pdb_all $current_pdb_all.$update_time`; 

#set critical state
`>$set_work_dir/critical`;
print "enter into critical region to update the current database...\n";
print LOG "enter into critical region to update the current database...\n";

#move all pdb files to the main pdb
#this one is tricky: set_work_dir/pdb only contains virtual links
#the real files are in set_pdb_source_dir
opendir(DIR, "$set_work_dir/pdb") || die "can't read work pdb dir.\n";
@files = readdir DIR;
closedir DIR;
foreach $file (@files)
{
	if ($file eq "." || $file eq "..")
	{
		next;
	}
	`mv $set_pdb_source_dir/$file $main_pdb_dir`; 
	`rm $set_work_dir/pdb/$file`; 
}

#remove the links of all pdb files without dssp files
`rm $set_work_dir/missing/*`; 

sub move_files
{
	my ($src_dir, $dest_dir) = @_;
	-d $src_dir || die "can't find source dir: $src_dir\n";
	-d $dest_dir || die "can't find dest dir: $dest_dir\n";
	opendir(SRC, $src_dir) || die "can't read $src_dir\n";
	my @files = readdir SRC;
	closedir SRC;
	while (@files)
	{
		my $file = shift @files;
		if ($file eq "." || $file eq "..")
		{
			next; 
		}
		`mv $src_dir/$file $dest_dir`; 
	}
}

#move all dssp files to the main dssp 
&move_files("$set_work_dir/dssp", $set_dssp_dir);

#move all fr files to main fr
&move_files("$set_work_dir/fr", $fr_template_dir);

#move all seq files to main seq
&move_files("$set_work_dir/seq", $set_seq_dir);

#move all atom files to main atom
&move_files("$set_work_dir/atom", $set_atom_dir);

#combine cm library
open(CURRENT, $current_cm_lib) || die "can't read current cm library file.\n";
@current = <CURRENT>;
close CURRENT;
@seqs = ();
@sel = @current;
while (@current)
{
	shift @current;
	$seq = shift @current;
	push @seqs, $seq;
}

$new_cm_file = "$set_work_dir/$cm_database_name.work";
open(ADD, $new_cm_file) || die "can't read added cm file.\n";
@add = <ADD>;
close ADD; 
$add_num = 0;
while (@add)
{
	$name = shift @add;
	$seq = shift @add;
	$found = 0;
	foreach $entry (@seqs)
	{
		if ($entry eq $seq)
		{
			$found = 1;
			last;
		}
	}
	if ($found == 0)
	{
		push @sel, $name;
		push @sel, $seq;
		$add_num++;
	}
}
open(CURRENT, ">$current_cm_lib") || die "can't overwrite current cm library file.\n";
print CURRENT join("", @sel);
close CURRENT;
print "$add_num new cm templates are added.\n";
print LOG "$add_num new cm templates are added.\n";

#format cm database
use Cwd;
$curr_dir = getcwd;
chdir $cm_library_dir;
system("$blast_dir/formatdb -i  $cm_database_name");
chdir $curr_dir;

#combine fr library
$new_fr_file = "$set_work_dir/$fr_template_library_file.work";

if (-f $new_fr_file) #some new fr templates generated
{

	#filter out templates with a lot of X (>= 25%)
	print "check if it is necessary to filter out sequences with >= 30% X\n";
	system("$prosys_dir/script/filter_x.pl $new_fr_file 0.3");
	print "done.\n";

	`cat $new_fr_file >> $current_fr_lib`; 
	open(FRFILE, $new_fr_file);
	@newfr = <FRFILE>;
	close FRFILE;
	$add_num = @newfr;
	$add_num /= 2;
	print "$add_num new fr templates are added.\n";
	print LOG "$add_num new fr templates are added.\n";

	##################################################################
	#format fr (sort90) database (1/20/2010)
	$curr_dir = getcwd;
	chdir $fr_template_library_dir;
	system("$blast_dir/formatdb -i  $fr_template_library_file");
	chdir $curr_dir;
	##################################################################

	##########generate 30% library
	print "generate 30% template file: sort30\n";
	print LOG "generate 30% template file: sort30\n";
	system("$prosys_dir/script/build_library_blast_update.pl $prosys_dir/script $blast_dir empty $current_fr_lib 0.3 $current_fr30_lib");

}
else
{
	print "0 new fr templates are added.\n";
	print LOG "0 new fr templates are added.\n";
}

##############################################################
#added 10/11/2007
$new_hhsearch_file = "$set_work_dir/hhsearchdb.work";
if (-f $new_hhsearch_file)
{
	`cat $new_hhsearch_file >> $current_hhsearch_lib`; 
	print "hhsearchdb is updated.\n";
	print LOG "hhsearchdb is updated.\n";
}
###############################################################

#update stx information table
`cat $set_work_dir/stx_info_list >> $current_stx_info`; 

#update all selected pdb sequences 
`cat $set_work_dir/$cm_database_name.fasta >> $current_pdb_all`; 


#remove critical state
`rm $set_work_dir/critical`;
print "finish critical upadte\n";
print LOG "finish critical upadte\n";
#######################################End of Moving files###############################################

#######################################Move tempoary file to log dir#####################################
`cp $catalog_file $set_work_dir/log`;  #backup the current catalog for recovering
`mv $catalog_file $set_work_dir/sync_catalog`;  #this is the current catalog
#######################################End of moving######################################################

#########################################Verify Correctness #############################################
print "verify database after updating...\n";
print LOG "verify database after updating...\n";
$current_cm_lib = "$cm_library_dir/$cm_database_name";
if (!-f $current_cm_lib)
{
	print "COMPLETE WITH ERROR: can't find cm library file. please recover from $catalog_file. stop.\n";	
	print LOG "COMPLETE WITH ERROR: can't find cm library file. please recover from $catalog_file. stop.\n";	
	goto END;
}

$current_fr_lib = "$fr_template_library_dir/$fr_template_library_file";
if (!-f $current_fr_lib)
{
	print "COMPLETE WITH ERROR: can't find fr library file. please recover from $catalog_file. stop.\n";	
	print LOG "COMPLETE WITH ERROR: can't find fr library file. please recover from $catalog_file. stop.\n";	
	goto END;
}
if (!-f $current_fr30_lib)
{
	print "COMPLETE WITH ERROR: can't find fr30 library file. please recover from $catalog_file. stop.\n";	
	print LOG "COMPLETE WITH ERROR: can't find fr30 library file. please recover from $catalog_file. stop.\n";	
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
	print "COMPLETE WITH ERROR: some templates cm library doesn't have seq or atom files. please recover from $catalog_file. stop.\n";	
	print LOG "COMPLETE WITH ERROR: some templates cm library doesn't have seq or atom files. please recover from $catalog_file. stop.\n";	
	goto END;
}

open(FR_MISS, $fr_miss_file) || die "can't read fr miss file.\n";
@fr_miss = <FR_MISS>;
close FR_MISS;
if (@fr_miss > 0)
{
	print "COMPLETE WITH ERROR: some templates fr library doesn't have required files. please recover from $catalog_file. stop.\n";	
	print LOG "COMPLETE WITH ERROR: some templates fr library doesn't have required files. please recover from $catalog_file. stop.\n";	
	goto END;
}
print "COMPLETE WITH SUCCESS.\n";
print LOG "COMPLETE WITH SUCCESS.\n";
#######################################End of Verify Correctness#######################################


END:
close LOG;

