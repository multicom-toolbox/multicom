#!/usr/bin/perl -w
###################################################################
#Script to create dataset from new pdb files 
#Input: database option file. 
#Author: Jianlin Cheng
#Date: 10/11/05
###################################################################

if (@ARGV != 1)
{
	die "need 1 parameters: database option file.\n"; 
}

$db_option = shift @ARGV;

#################read option file##################################
open(OPTION, $db_option) || die "can't read option file.\n";
$prosys_dir = "";
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
	if ($line =~ /^dssp_program_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$dssp_program_dir = $value; 
	}
	if ($line =~ /^set_pdb_source_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_pdb_source_dir = $value; 
	}
	if ($line =~ /^prosys_db_stat_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_db_stat_dir = $value; 
	}
	if ($line =~ /^set_dssp_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_dssp_dir = $value; 
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
	if ($line =~ /^set_dssp_new_file/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_dssp_new_file = $value; 
	}
	if ($line =~ /^set_adjust_new_file/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_adjust_new_file = $value; 
	}
	if ($line =~ /^set_pdb_release_date/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_pdb_release_date = $value; 
	}

}
#####################End of reading options######################
-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $prosys_db_stat_dir || die "can't find database stat dir: $prosys_db_stat_dir\n";

-d $set_pdb_source_dir || die "can't find pdb source dir: $set_pdb_source_dir\n";
-d $set_dssp_dir || die "can't find dssp dir: $set_dssp_dir\n";
-d $set_seq_dir || die "cna't find set seq dir: $set_seq_dir\n";
-d $set_atom_dir || die "can't find set atom dir: $set_atom_dir\n";
-f "$dssp_program_dir/dsspcmbi" || die "can't find dssp program.\n";

if (! -d $set_work_dir)
{
	`mkdir $set_work_dir`; 	
}
#make temporary directories if necessary
#clean up what might be left 
`rm -r $set_work_dir/seq 2>/dev/null`; 	
`rm -r  $set_work_dir/atom 2>/dev/null`; 	
`rm -r $set_work_dir/dssp 2>/dev/null`; 	
`rm -r $set_work_dir/pdb 2>/dev/null`; 	

`mkdir $set_work_dir/seq 2>/dev/null`; 	
`mkdir $set_work_dir/atom 2>/dev/null`; 	
`mkdir $set_work_dir/dssp 2>/dev/null`; 	
`mkdir $set_work_dir/pdb 2>/dev/null`; 	


$set_dssp_new_file = "$set_work_dir/$set_dssp_new_file";
$set_adjust_new_file = "$set_work_dir/$set_adjust_new_file";

#set name of two working files, which will be swapped later.
$dssp_set_file = "$set_dssp_new_file.work";
$adjust_set_file = "$set_adjust_new_file.work";

#check release date

$select_all = 0; 
if ($set_pdb_release_date =~ /(\d+)-(\d+)-(\d+)/)
{
	$day = $1;
	$month = $2;
	$year = $3;
	print "select new pdb files released before or on day=$day month=$month year=$year\n";
}
else
{
	$select_all = 1; 	
	print "select all new pdb files to generate dataset.\n";
}


opendir(PDB, $set_pdb_source_dir) || die "can't read pdb source dir for data generation.\n"; 
@pdb_files = readdir(PDB);
closedir PDB; 

@select_file_list = (); 
@select_path_list = ();
@select_file_date = (); 

%month_map = ("jan", 1, "feb", 2, "mar", 3, "apr", 4, "may", 5, "jun", 6, "jul", 7, "aug", 8, "sep", 9, "oct", 10, "nov", 11, "dec", 12);

print "select proteins to generate dataset...\n";
while (@pdb_files)
{
	$file = shift @pdb_files;
	if ($file eq ".." || $file eq ".")
	{
		next; 
	}
	$full_path = "$set_pdb_source_dir/$file";
	if ($select_all != 0)
	{
		push @select_path_list, $full_path;
		push @select_file_list, $file;
		next;
	}

	`cp $full_path .`;  
	if ($file =~ /(.+)\.Z$/ || $file =~ /(.+)\.gz$/)
	{
		`gunzip -f $file`; 		
		$prefix = $1; 
	}
	else
	{
		print "unrecognized pdb file name $file\n";
		`rm $file`; 
	}

	#read latest release date
	open(ENT, $prefix) || die "can't read pdb entry file: $prefix\n";
	$release_date = "01-jan-70";
	while (<ENT>)
	{
		$line = $_;
		chomp $line;
		if ($line =~ /^REVDAT /)
		{
			$release_date = substr($line, 13, 9);
			last;
		}
	}
	close ENT;
	`rm $prefix`;
	#print "release date: $release_date\n";
	if ($release_date =~ /(.+)-(.+)-(.+)/)
	{
		$pday = $1;
		$pmonth = $2;
		$pmonth = lc($pmonth);
		#print "pmonth = $pmonth\n";
		$pyear = $3;
		$pmonth = $month_map{$pmonth};
		if ($pmonth < 1 || $pmonth > 12)
		{
			warn "unregonized month in pdb file: $file, month=$2\n";
			next;
		}
	}

	#convert year to four digits.
	if ($pyear < 20)
	{
		$pyear = "20$pyear";
	}
	else
	{
		$pyear = "19$pyear";
	}

	#print "protein release date: $pday, $pmonth, $pyear\n";
	#print "cut off date: $day, $month, $year\n";

	#check the date
	$choose = 0;

	if ($pyear < $year)
	{
		$choose = 1; 
	}
	elsif ($pyear == $year && $pmonth < $month)
	{
		$choose = 1; 	
	}
	elsif ($pyear==$year && $pmonth==$month && $pday <= $day)
	{
		$choose = 1; 
	}
	#print "choose = $choose\n";

	if ($choose == 1)
	{
		push @select_path_list, $full_path;
		push @select_file_list, $file;
		push @select_file_date, $release_date;
	}
}

$num = @select_path_list;
print "total $num new proteins are chosen to generate dataset.\n";


#create a virtual link for each selected protein
for ($i = 0; $i < $num; $i++)
{
	$path = $select_path_list[$i]; 
	$file = $select_file_list[$i]; 
	`ln -s $path  $set_work_dir/pdb/$file`; 
}

#convert pdb file to dssp file (first round)
print "convert the selected pdb files to dssp files (Round 1)...\n";
system("$prosys_dir/script/pdb2dssp.pl $dssp_program_dir $set_work_dir/pdb $set_work_dir/dssp >/dev/null 2>/dev/null");

#check if some files don't have dssp file generated
@missing_files = ();
@missing_prefix = ();
opendir(PDB_DIR, "$set_work_dir/pdb") || die "can't read dssp dir.\n";
@files = readdir PDB_DIR;
closedir PDB_DIR;

while (@files)
{
	$file = shift @files;
	if ($file eq "." || $file eq "..")
	{
		next;
	}
	if ( $file =~ /(.+)\.Z$/ || $file =~ /(.+)\.gz$/ )
	{
		$dssp_file = "$1.dssp.gz";	
	}
	else
	{
		`rm  $set_work_dir/pdb/*`; 
		die "illegal pdb file name.\n";
	}
	if (! -f "$set_work_dir/dssp/$dssp_file")
	{
		push @missing_files, "$set_work_dir/pdb/$file";
		push @missing_prefix, $file; 
	}
}
$miss_num = @missing_files;
if ($miss_num > 0)
{
	print "in round 1: $miss_num files don't have dssp files generated.\n";
	print "Round 2: try to regenerate the dssp files for these pdb files.\n";
	`rm -r $set_work_dir/missing 2>/dev/null`;
	`mkdir $set_work_dir/missing`;
	for ($i = 0; $i < $miss_num; $i++)
	{
		`ln -s $missing_files[$i] $set_work_dir/missing/$missing_prefix[$i]`; 
	}
	system("$prosys_dir/script/pdb2dssp.pl $dssp_program_dir $set_work_dir/missing $set_work_dir/dssp >/dev/null 2>/dev/null");
	system("$prosys_dir/script/pdb2dssp.pl $dssp_program_dir $set_work_dir/missing $set_work_dir/dssp >/dev/null 2>/dev/null");
}


#generate dataset
print "generate dataset from dssp and pdb files.\n";
system("$prosys_dir/script/gen_seq_atom.pl $prosys_dir/script $set_work_dir/pdb $set_work_dir/dssp $set_work_dir/seq $set_work_dir/atom $dssp_set_file $adjust_set_file >$set_work_dir/set.log");

#write down the select new protein list
open(LIST, ">$set_work_dir/select_prot.list") || die "can't create selected protein list.\n";
for ($i = 0; $i < $num; $i++)
{
	print LIST $select_file_list[$i], "\t";
	if ($select_all == 0)
	{
		print LIST $select_file_date[$i], "\n";
	}
	else
	{
		print LIST "select_all\n";
	}
}
close LIST;


#generate structure information list
$stx_info_file = "$set_work_dir/stx_info_list";
system("$prosys_dir/script/get_res_ratio.pl $set_work_dir/seq $stx_info_file");









