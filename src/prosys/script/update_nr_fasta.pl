#!/usr/bin/perl -w
###################################################################
#Script to udpate nr database of FASTA sequence version (not formated)
#Input: prosys dir, nr download dir, nr main dir
#download NR protein sequence database, unzip it into nr download 
#dir. then move them to nr main dir. 
#Author: Jianlin Cheng
#Date: 10/24/05
###################################################################

if (@ARGV != 3)
{
	die "need 3 parameters: prosys dir, nr download dir, nr main dir.\n"; 
}

$prosys_dir = shift @ARGV;
$nr_download_dir = shift @ARGV;
$nr_main_dir = shift @ARGV;

-d $prosys_dir || die "can't find prosys dir: $prosys_dir\n";
-d $nr_download_dir || die "can't find $nr_download_dir\n";
-d $nr_main_dir || die "can't find $nr_main_dir\n";


$ftp = "$prosys_dir/script/autoftp";
-f $ftp || die "can't find ftp script.\n";

#get the latest list of pdb
print "connect ncbi nr database....\n";
system("$ftp -l  -u anonymous -p anonymous \'ftp.ncbi.nih.gov;./blast/db/FASTA\' > nrlist.txt"); 
open(LIST, "nrlist.txt") || die "can't read the current nr list.\n";
@list = <LIST>;
close LIST; 
@nr_list = (); 
while (@list)
{
	$line = shift @list;
	chomp $line;
	if ($line =~ /^nr\..*gz$/)
	{
		push @nr_list, $line;
	}
}

#find file that need to be downloaded
print "download nr database...\n"; 
#download the list of all new pdb files
foreach $file (@nr_list)
{
	print "download $file...\n"; 
	system("$ftp -u anonymous -p anonymous \'ftp.ncbi.nih.gov;./blast/db/FASTA;b;$file\'"); 
	`mv $file $nr_download_dir`; 
}
print "\n";
print "download is finished. start to unzip files and update nr database...\n";

$cur_dir = `pwd`;
chomp $cur_dir;

chdir $nr_download_dir;
foreach $file (@nr_list)
{
	`gunzip -f $file`;
}

#check the size of each file:
#nr.phr
#nr.pin
#nr.pnd
#nr.pni
#nr.psd
#nr.psi
#nr.psq
#(new files should have bigger size than previous files)

#move files into main nr dir to replace the old files

print "NR database updating is done.\n"; 




