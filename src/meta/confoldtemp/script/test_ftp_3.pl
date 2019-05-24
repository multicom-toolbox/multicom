#!/usr/bin/perl

# perl /home/casp13/test/test_ftp_3.pl   /home/casp13/test/testpdb

##########################################################################################
# Automatically retrieve seqs from ftp.wwpdb.org to update pdblist file
#
# 5 arguments
# Output: sort90 file with recent (wwpdb) date attached onto the filename
# Example :  perl toatom.pl sort90_20120801.txt 20120812 /home/casp11/casp12/test/db
#			 perl toatom.pl <select sort90 file> <up to what date> <database folder>
# Explained:  Use sort90_20120706.txt to look for updates up till 20120812
#             File built only contains "new" pdb files from
#             20120801 till 20120812.
#             Extract atom file from PDB files
#             Extract sequence from atom files for individual chains
##########################################################################################

use Net::FTP;
use File::Copy qw(copy);

my $host = "ftp.wwpdb.org";
my $username = "bye";
my $password = "hello";
my $ftpdir = "/pub/pdb/data/status/";
my $ftpstructure = "/pub/pdb/data/structures/all/pdb/";
my $file = "added.pdb";
my $glob = '*';
my @remote_folders;
my $from_date = '20070101';
my $file_out = "pdblist.txt";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


if (@ARGV != 1){
	print "There needs to be 3 arguments!";
}
else{
	$DBfolder = @ARGV[1];	#/home/casp11/casp12/test/db
	
	if(-d $DBfolder)
	{
		$file_out = "$DBfolder/$file_out";
	}
	
	if(-e $file_out)
	{
		`rm $file_out`;
	}
	
	my $currentdate = sprintf("%4d%02d%02d",($year + 1900),($mon+1),$mday);
	print "Current date is $currentdate\n";
	
	#-- connect to ftp server
	my $ftp = Net::FTP->new($host) or die "Error connecting to $host: $!";

	#-- login
	$ftp->login($username,$password) or die "Login failed: $!";
	 
	#-- chdir to $ftpdir
	$ftp->cwd($ftpdir) or die "Can't go to $ftpdir: $!";	
	
	@remote_folders = $ftp->dir($glob);

	$grabfolder = "";
	# Look through each date folder on wwpdb and update according the folder date
	foreach my $folder (@remote_folders) 
	{
		chomp $folder;
		if($folder eq '.' or $folder eq '..')
		{
			next;
		}
		if (($folder <= $from_date)){
				next;
		}else 
		{
			$grabfolder = $folder;
			my $test = chop($folder);
			print "Saw: $ftpdir" . "$folder\n";
			
			if ($folder eq "") {
				next;
			}
			$ftp->cwd($ftpdir . $folder) or die "Can't go to $folder: $!";

			# DL the add.pdb file and adding a date to it
			$ftp->get($file, "add.pdb") or die "Can't get $file: $!";
			open(addpdf, "<add.pdb") or die "2Failed to open add.pdb, $!\n";
			open(pdbcode, ">>$file_out");
			
			while (<addpdf>) { 
				$code = $_;
				chomp $code; #pdb4md0.ent.gz
				print pdbcode "pdb$code.ent.gz\n"; 
			}
			close(addpdf);
			
			# Create pdb code file with dates
			close(pdbcode);
			
			$update = 1;
		}
	}

	if ($update  == 0){
		print "There are no new updates!\n";
		exit;
	}
	
	
	print "Checking pdb list $file_out\n\n";
	#-- close ftp connection
	$ftp->quit or die "Error closing ftp connection: $!";	
}
	



