#!/usr/bin/perl -w

if (@ARGV != 1) {
  print "Usage: prosys database directory.\n";
  exit;
}

$work_dir = $ARGV[0]; #/home/chengji/software/prosys_database/

$update_time = `date`;
chomp $update_time;
$update_time =~ s/\s/_/g; 

$logfile = "delete_db_files.log.$update_time"; # due to permission, set to home/jh7x3 temporarily, Dr.Cheng need comment this

#$logfile = "$work_dir/delete_db_files.log.$update_time";  # Dr.Cheng need uncomment this


open(LOG,">$logfile") || die "Failed to write file to $logfile\n";




######  1. Initialize the DB options to process
%db_array=();
$db_array{"$work_dir/pdb05_2004"}='main_pdb_dir';  #main_pdb_dir
$db_array{"$work_dir/dssp"}='set_dssp_dir'; #set_dssp_dir
$db_array{"$work_dir/library"}='fr_template_dir'; #fr_template_dir
$db_array{"$work_dir/seq"}='set_seq_dir'; #set_seq_dir
$db_array{"$work_dir/atom"}='set_atom_dir'; #set_atom_dir





######  2. Initialize the month and year to process
#@month_select = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
@month_array = ('Aug','Sep','Oct','Nov','Dec');
%month_select = ();

foreach $mon (@month_array)
{
	$month_select{$mon}  =1;
}

%year_select = ();
$year_select{'2016'}=1;





###### 3. find the files that created after Aug 2016

foreach $db (sort keys %db_array)
{
	print "#################  Start processing db $db\n\n";
	print LOG "#################  Start processing db $db\n\n";
	
	opendir(DIR,$db) || die "Failed to open directory $db\n";
	@files = readdir(DIR);
	closedir(DIR);
	
	$clean_file_num=0;
	foreach $file (@files)
	{
		chomp $file;
		if($file eq '.' or $file eq '..')
		{
			next;
		}
		
		$file_path = "$db/$file";
		if(!(-e $file_path))
		{
			die "Failed to find file $file_path\n";
		}
		
		$file_info = `ls -l $file_path`;
		chomp $file_info;
		
		
		@info_array = split(/\s+/,$file_info);
		$mon = $info_array[5];
		$year = $info_array[7];
		
		if(exists($month_select{$mon}) and exists($year_select{$year}))
		{
			print "Clearning <$file_info>\n";
			print LOG "Clearning <$file_info>\n";
			$clean_file_num++;
			`rm $file_path`;    # Dr.Cheng need uncomment this
		}
		
		
	}
	
	print "#################  Finish processing db $db, $clean_file_num files are removed\n\n";
	print LOG "#################  Finish processing db $db, $clean_file_num files are removed\n\n";
	
}
close LOG;
