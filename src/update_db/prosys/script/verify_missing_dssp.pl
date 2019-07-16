#!/usr/bin/perl -w
###################################################################
#Script to to check pdb files without dssp files generated
#try to regenerate dssp files for them. if still can't be generated,
#the pdb will be put into bad list. otherwise, it will be moved to
#the new pdb download directory. So it can be recovered. 
#Input: database option file. 
#Author: Jianlin Cheng
#Date: 10/12/05
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
	if ($line =~ /^dssp_program_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$dssp_program_dir = $value; 
	}
	if ($line =~ /^main_pdb_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$main_pdb_dir = $value; 
	}
	if ($line =~ /^pdb_download_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_download_dir = $value; 
	}

	#this is the dir that dataset is generated. it usually is the same as pdb_download_dir
	if ($line =~ /^set_pdb_source_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_pdb_source_dir = $value; 
	}

	#this the main dssp repository.
	if ($line =~ /^set_dssp_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$set_dssp_dir = $value; 
	}
	if ($line =~ /^prosys_db_stat_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_db_stat_dir = $value; 
	}
	if ($line =~ /^pdb_bad_list/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_bad_list = $value; 
	}

}
#####################End of reading options######################
-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $main_pdb_dir || die "can't find main pdb dir: $main_pdb_dir\n";
-d $pdb_download_dir || die "can't find pdb download dir: $pdb_download_dir\n";
-d $prosys_db_stat_dir || die "can't find database stat dir: $prosys_db_stat_dir\n";
-d $set_pdb_source_dir || die "can't find pdb source dir: $set_pdb_source_dir\n";
-d $set_dssp_dir || die "can't find main dssp dir: $set_dssp_dir\n";
-f "$dssp_program_dir/dsspcmbi" || die "can't find dssp program.\n";

$pdb_bad_list = "$prosys_db_stat_dir/$pdb_bad_list";

@bad_list = (); 
if (-f $pdb_bad_list)
{
	open(BAD, $pdb_bad_list) || die "can't read pdb bad list file: $pdb_bad_list\n";	
	while (<BAD>)
	{
		chomp $_; 
		push @bad_list, $_; 
	}
	close BAD;
}

@missing_files = ();
@missing_prefix = ();
opendir(PDB_DIR, "$main_pdb_dir") || die "can't read main pdb dir.\n";
@files = readdir PDB_DIR;
closedir PDB_DIR;

print "check pdb files in $main_pdb_dir against dssp dir $set_dssp_dir, and move recoveredd files to $pdb_download_dir\n";

while (@files)
{
	$file = shift @files;
	if ($file eq "." || $file eq "..")
	{
		next;
	}
	if ( $file =~ /(.+)\.Z$/ || $file =~ /(.+)\.gz$/)
	{
		$dssp_file = "$1.dssp.gz";	
	}
	else
	{
		die "illegal pdb file name.\n";
	}
	if (! -f "$set_dssp_dir/$dssp_file")
	{
		$isbad = 0;
		foreach $bad (@bad_list)
		{
			if ($file eq $bad)
			{
				$isbad = 1;
				last;
			}
		}

		if ($isbad == 0)
		{
			push @missing_files, "$main_pdb_dir/$file";
			push @missing_prefix, $file; 
		}
	}
}

$miss_num = @missing_files;
$recover = 0; 
if ($miss_num > 0)
{
	print "$miss_num files don't have dssp files generated in the main pdb dir: $main_pdb_dir.\n";
	print "try to regenerate the dssp files for these pdb files.\n";
	`rm -r $prosys_db_stat_dir/missing 2>/dev/null`;
	`mkdir $prosys_db_stat_dir/missing`;
	`rm -r $prosys_db_stat_dir/dssp 2>/dev/null`;
	`mkdir $prosys_db_stat_dir/dssp`;

	#create links for these missing pdb files
	for ($i = 0; $i < $miss_num; $i++)
	{
		`ln -s $missing_files[$i] $prosys_db_stat_dir/missing/$missing_prefix[$i]`; 
	}
	system("$prosys_dir/script/pdb2dssp.pl $dssp_program_dir $prosys_db_stat_dir/missing $prosys_db_stat_dir/dssp >/dev/null 2>/dev/null");


	#check how may get dssp files generated
	foreach $file (@missing_prefix)
	{
		if ( $file =~ /(.+)\.Z$/)
		{
			$dssp_file = "$1.dssp.gz";	
		}
		else
		{
			push @bad_list, $file;
			next;
		}
		if (-f "$prosys_db_stat_dir/dssp/$dssp_file")
		{
			#regenerate successfully
			#mv the file from main pdb respository to download dir
			if (!-f "$pdb_download_dir/$file")
			{
				`mv $main_pdb_dir/$file $pdb_download_dir`; 
			}
			$recover++; 
		}
		else
		{
			push @bad_list, $file;
		}
	}
}

open(BAD, ">$pdb_bad_list") || die "can't create pdb bad list file: $pdb_bad_list\n";	
print BAD join("\n", @bad_list);
close BAD;

print "total num of pdb files without dssp files is $miss_num. $recover files are recovered into $pdb_download_dir\n";









