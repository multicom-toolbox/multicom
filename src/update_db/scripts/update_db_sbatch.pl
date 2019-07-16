#!/usr/bin/perl
###################################################################
#Script to udpate template database
#Input: database option file. 
#Author: Jie Hou
#Date: 06/24/2015
###################################################################

use Net::FTP;
use File::Copy qw(copy);
use Scalar::Util qw(looks_like_number);


$num = @ARGV;
if($num !=8)
{
  die "The parameter is not correct\n";
}
$database_dir = $ARGV[0];
$script_dir = $ARGV[1];
$sbatch_dir = $ARGV[2];
$from_db_date = $ARGV[3];
$end_db_date = $ARGV[4];
$thread_num = $ARGV[5];
$by_weeks = $ARGV[6];
$run_mode = $ARGV[7];

$db_option = "$script_dir/options/db_option";

-e $db_option || die "Failed to find database option $db_option\n"; 
-d $database_dir || die "Failed to find database directory $database_dir\n"; 

if(-d "$sbatch_dir")
{
  `rm $sbatch_dir/*`;
}else{
  `mkdir $sbatch_dir`;
}

###### initialize the database file for the first run

-d "$database_dir/dbstat" || `mkdir $database_dir/dbstat`;
-d "$database_dir/pdb05_2004" || `mkdir $database_dir/pdb05_2004`;
-d "$database_dir/fr_lib" || `mkdir $database_dir/fr_lib`;
-d "$database_dir/library" || `mkdir $database_dir/library`;
-d "$database_dir/pdb" || `mkdir $database_dir/pdb`;
-d "$database_dir/cm_lib" || `mkdir $database_dir/cm_lib`;
-d "$database_dir/work" || `mkdir $database_dir/work`;
-d "$database_dir/atom" || `mkdir $database_dir/atom`;
-d "$database_dir/seq" || `mkdir $database_dir/seq`;
-d "$database_dir/dssp" || `mkdir $database_dir/dssp`;
-d "$database_dir/hhsearch1.5_db" || `mkdir $database_dir/hhsearch1.5_db`;
-d "$database_dir/prc_db" || `mkdir $database_dir/prc_db/`;
-d "$database_dir/ffas_dbs" || `mkdir $database_dir/ffas_dbs`;
-d "$database_dir/ffas_dbs/multicom_db" || `mkdir $database_dir/ffas_dbs/multicom_db`;
-d "$database_dir/compass_db" || `mkdir $database_dir/compass_db`;
-d "$database_dir/hhsuite_dbs" || `mkdir $database_dir/hhsuite_dbs/`;
-d "$database_dir/hhsuite_dbs/a3m" || `mkdir $database_dir/hhsuite_dbs/a3m`;

###the first time, the following file need exist
-e "$database_dir/cm_lib/pdb_cm" || `touch $database_dir/cm_lib/pdb_cm`;
-e "$database_dir/fr_lib/sort90" || `touch $database_dir/fr_lib/sort90`;
-e "$database_dir/fr_lib/hhsearchdb" || `touch $database_dir/fr_lib/hhsearchdb`;
-e "$database_dir/fr_lib/sort30" || `touch $database_dir/fr_lib/sort30`;



#get the latest list of pdb
print "connect rcsb pdb database....\n";
#system("$ftp -l  -u anonymous -p anonymous \'ftp.rcsb.org;./pub/pdb/data/structures/all/pdb\' > $prosys_db_stat_dir/pdblist.txt"); 
#system("$ftp -l  -u anonymous -p anonymous \'ftp.wwpdb.org;./pub/pdb/data/structures/all/pdb\' > $prosys_db_stat_dir/pdblist.txt");  # this may take too long to timeout, not safe

$host = "ftp.wwpdb.org";
$username = "bye";
$password = "hello";
$ftpdir = "/pub/pdb/data/status/";
$ftpstructure = "/pub/pdb/data/structures/all/pdb/";
$file = "added.pdb";
$glob = '*';
@remote_folders;
#$from_date = 19900101;
$from_date = $from_db_date;
$end_date = $end_db_date;
$file_out = "$sbatch_dir/pdb_dates.txt";
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


$currentdate = sprintf("%4d%02d%02d",($year + 1900),($mon+1),$mday);
print "Current date is $currentdate\n";

#-- connect to ftp server
$ftp = Net::FTP->new($host) or die "Error connecting to $host: $!";

#-- login
$ftp->login($username,$password) or die "Login failed: $!";
 
#-- chdir to $ftpdir
$ftp->cwd($ftpdir) or die "Can't go to $ftpdir: $!";	

@remote_folders = $ftp->dir($glob);
open(TMP,">$file_out");
$grabfolder = "";
# Look through each date folder on wwpdb and update according the folder date

$db_index = 0;
$weeks_index = 0;
foreach $folder (@remote_folders) 
{
	chomp $folder;
	if($folder eq '.' or $folder eq '..')
	{
		next;
	}
	if ($folder eq "") {
		next;
	}
  $folder =~ s/\://g;
	if (($folder <= $from_date) || ($folder > $end_date)){
			next;
	}else 
	{
		$grabfolder = $folder;
		print "Saw: $ftpdir" . "$folder\n";
    print TMP "$folder\n";



      #################cp option file##################################
      $weeks_index ++;
      if($weeks_index % $by_weeks != 0 and $by_weeks>1)
      {
        next;
      }
      $db_index ++;
      $option_tmp = "$sbatch_dir/db${db_index}_${folder}_option";
      
      open(OPTION, $db_option) || die "can't read option file.\n";
      open(OUT, ">$option_tmp") || die "can't write option file.\n";
      
      while (<OPTION>)
      {
      	$line = $_; 
      	chomp $line;
      	if ($line =~ /^end_date/)
      	{
          print OUT "end_date = $folder\n";
        }elsif ($line =~ /^running_mode/)
      	{
          print OUT "running_mode = $run_mode\n";
        }elsif ($line =~ /^thread_num/)
      	{
          print OUT "thread_num = $thread_num\n";
        }elsif ($line =~ /^prosys_db_stat_dir/)
      	{
          print OUT "prosys_db_stat_dir = $database_dir/dbstat\n";
        }elsif ($line =~ /^main_pdb_dir/)
      	{
          print OUT "main_pdb_dir = $database_dir/pdb05_2004\n";
        }elsif ($line =~ /^pdb_download_dir/)
      	{
          print OUT "pdb_download_dir = $database_dir/pdb\n";
        }elsif ($line =~ /^set_pdb_source_dir/)
      	{
          print OUT "set_pdb_source_dir = $database_dir/pdb\n";
        }elsif ($line =~ /^set_dssp_dir/)
      	{
          print OUT "set_dssp_dir = $database_dir/dssp\n";
        }elsif ($line =~ /^set_seq_dir/)
      	{
          print OUT "set_seq_dir = $database_dir/seq\n";
        }elsif ($line =~ /^set_atom_dir/)
      	{
          print OUT "set_atom_dir = $database_dir/atom\n";
        }elsif ($line =~ /^set_work_dir/)
      	{
          print OUT "set_work_dir = $database_dir/work\n";
        }elsif ($line =~ /^cm_library_dir/)
      	{
          print OUT "cm_library_dir = $database_dir/cm_lib\n";
        }elsif ($line =~ /^fr_template_dir/)
      	{
          print OUT "fr_template_dir = $database_dir/library\n";
        }elsif ($line =~ /^fr_template_library_dir/)
      	{
          print OUT "fr_template_library_dir = $database_dir/fr_lib\n";
        }else{
          print OUT "$line\n";
        }
      }
      close OPTION;
      close OUT;
      
      `touch $sbatch_dir/db${db_index}_${folder}.queued`;
    	open SB, ">$sbatch_dir/db${db_index}_${folder}.sh" or confess $!;
    	print SB "#!/bin/bash -l\n";
    	print SB "#SBATCH -J db${db_index}_${folder}\n";
    	print SB "#SBATCH -o db${db_index}_${folder}.log\n";
    	print SB "#SBATCH -p hpc4,Lewis\n";
    	print SB "#SBATCH -n 1\n";
    	print SB "#SBATCH --mem 10G\n";
    	print SB "#SBATCH -t 2-00:00\n";
    	print SB "mv $sbatch_dir/db${db_index}_${folder}.queued $sbatch_dir/db${db_index}_${folder}.running\n\n";
  		#within the child process
  		print SB "echo 'start updating database to date $folder'\n\n";
        print SB "cd $database_dir/work\n\n";
  		print SB "echo '$script_dir/scripts/casp12_update_once.pl $script_dir/prosys/script/update_main.pl $script_dir/bin/update_nr.sh $script_dir/tools/compass/update_compass_db_v2.sh $script_dir/tools/hhsearch1.5/make_hhsearch1.5_db.sh $script_dir/tools/prc/make_prc_db.sh  $option_tmp'\n\n";
  		print SB "$script_dir/scripts/casp12_update_once.pl $script_dir/prosys/script/update_main.pl $script_dir/bin/update_nr.sh $script_dir/tools/compass/update_compass_db_v2.sh $script_dir/tools/hhsearch1.5/make_hhsearch1.5_db.sh $script_dir/tools/prc/make_prc_db.sh  $option_tmp\n\n";
    	print SB "mv $sbatch_dir/db${db_index}_${folder}.running $sbatch_dir/db${db_index}_${folder}.done\n\n";
    	close SB;
    	system("chmod +x $sbatch_dir/db${db_index}_${folder}.sh");      
      
	}
}
close TMP;
print "Checking pdb releasing dates in $file_out\n\n";
print "Checking update scripts in $sbatch_dir\n\n";
#-- close ftp connection
$ftp->quit or die "Error closing ftp connection: $!";	
###############################  end to get pdblist






