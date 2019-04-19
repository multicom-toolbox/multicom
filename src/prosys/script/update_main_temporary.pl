#!/usr/bin/perl -w
###################################################################
#the main control script to update database
#Input: database option file. 
#Author: Jianlin Cheng
#Date: 10/16/05
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
#	if ($line =~ /^cm_database_name/)
#	{
#		($other, $value) = split(/=/, $line);
#		$value =~ s/\s//g; 
#		$cm_database_name = $value; 
#	}
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

	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}

#	if ($line =~ /^fr_template_library_file/)
#	{
#		($other, $value) = split(/=/, $line);
#		$value =~ s/\s//g; 
#		$fr_template_library_file = $value; 
#	}

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

	if ($line =~ /^pdb_index_new/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_index_new = $value; 
	}
}
#####################End of reading options######################
close OPTION;
-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $prosys_db_stat_dir || die "can't find database stat dir: $prosys_db_stat_dir\n";
-d $set_seq_dir || die "cna't find set seq dir: $set_seq_dir\n";
-d $set_atom_dir || die "can't find set atom dir: $set_atom_dir\n";
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $nr_dir || die "can't find nr dir:$nr_dir.\n";
-d $set_work_dir || die "can't find work dir: $set_work_dir\n";
-d $fr_template_library_dir || die "can't find fr template library dir:$fr_template_library_dir.\n";
-d $cm_library_dir || die "can't find cm library dir: $cm_library_dir\n";
-d $fr_template_dir || die "can't find fr template dir.\n";
-d $set_dssp_dir || die "can't find set dssp dir.\n";
-d $main_pdb_dir || die "can't find main pdb dir.\n";
-d $set_pdb_source_dir || die "can't find pdb source dir.\n";

$pdb_index_new = "$prosys_db_stat_dir/$pdb_index_new";

$log_file = "$set_work_dir/main.log";
-f $log_file || `> $log_file`; 
open(LOG, ">>$log_file") || die "can't create database synchronization log file.\n";

$date = `date`;
print LOG "\n-------------------------------------------------------\n";
print LOG $date;

$db_lock = "$set_atom_dir/_db_lock";
if ( -f $db_lock )
{
	print "One database updating process is running: $db_lock.\n";
	print LOG "One database updating process is running: $db_lock.\n";
	goto FRUPDATE;
	die "Stop.\n";
}
else
{
	system("touch $db_lock");
	print "Set database lock.\n";
	print LOG "Set database lock.\n";
}

print "step 1: try to recover pdb files without dssp files...\n";
print LOG "step 1: try to recover pdb files without dssp files...\n";
system("$prosys_dir/script/verify_missing_dssp.pl $db_option");

print "step 2: download new pdb files...\n";
print LOG "step 2: download new pdb files...\n";
system("$prosys_dir/script/update_pdb.pl $db_option");

#check if there are new files are downloaded
#this will be uncommented later on.
#open(PDB_NEW, $pdb_index_new) || die "can't read index of newly downloaded pdb files.\n";
#@pdb_new = <PDB_NEW>;
#close PDB_NEW;
#if (@pdb_new <= 0)
#{
#	print LOG "no new proteins are downloaded. update stops. \n";
#	die "no new proteins are downloaded. update stops. \n";
#}

print "step 3: update dataset...\n";
print LOG "step 3: update dataset...\n";
system("$prosys_dir/script/update_dataset.pl $db_option");

#check if there are proteins to be processed.
opendir(PDB_DIR, "$set_work_dir/pdb") || die "can't read work pdb dir.\n";
@files = readdir PDB_DIR;
closedir PDB_DIR;
$is_new = 0;
while (@files)
{
       $file = shift @files;
       if ($file eq "." || $file eq "..")
       {
              next;
       }
       $is_new = 1; 
       last;
}
if ($is_new == 0)
{
	print LOG "no new proteins selected in $set_work_dir/pdb. stop.\n";
	#release database lock
	print "release database lock.\n";
	print LOG "release database lock.\n";
	`rm $db_lock`; 
	die "no new proteins selected in $set_work_dir/pdb. stop.\n";
}

print "step 4: update cm...\n";
print LOG "step 4: update cm...\n";
system("$prosys_dir/script/update_cm.pl $db_option");

FRUPDATE: 

print "Skip the first four steps. step 5: update fr DIRECTLY...\n";
print LOG "step 5: update fr...\n";
system("$prosys_dir/script/update_fr.pl $db_option");

print "step 6: synchronize database...\n";
print LOG "step 6: synchronize database...\n";

$lib_lock = "$set_atom_dir/_lib_lock";
print "try to get library lock to change database...\n"; 
print LOG "try to get library lock to change database (into loop)...\n"; 
while (1)
{
	if (! -f $lib_lock)
	{
		print "get library lock.\n";
		print LOG "get library lock.\n";
		`touch $lib_lock`; 
		last;
	}
	else
	{
		#block for 5 seconds
		sleep(5);
	}
}
system("$prosys_dir/script/sync_database.pl $db_option");
print "release library lock.\n"; 
print LOG "release library lock.\n"; 
`rm $lib_lock`; 

print "update is done. please check the final state in $set_work_dir/sync_db.log\n";
print LOG "update is done. please check the final state in $set_work_dir/sync_db.log\n";

#release database lock
print "release database lock.\n";
print LOG "release database lock.\n";
`rm $db_lock`; 

close LOG;



