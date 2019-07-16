#!/usr/bin/perl
###################################################################
#Script to udpate PDB files
#Input: database option file. 
#Author: Jianlin Cheng
#Modified from update_db.pl
#Date: 10/10/05
###################################################################

use Net::FTP;
use File::Copy qw(copy);
use Scalar::Util qw(looks_like_number);


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
#$from_date = 20070101;
$from_date = 19900101;
$end_date = 20300101;
$file_out = "pdb_dates.txt";
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
		
	}
}
close TMP;
print "Checking pdb releasing dates in $file_out\n\n";
#-- close ftp connection
$ftp->quit or die "Error closing ftp connection: $!";	
###############################  end to get pdblist



