#!/usr/bin/perl -w
#####################################################
#build the prc database (a list of hmm model files)
if (@ARGV != 3)
{
	die "need three parameters: prosys library dir, sort90 file,  output database file.\n";
}

$db_dir = shift @ARGV;
$sort90 = shift @ARGV;
$prc_db = shift @ARGV;

#opendir(DB, $db_dir) || die "can't read $db_dir\n";
#@files = readdir(DB);
#closedir(DB);

open(PRC, ">$prc_db");

open(SORT, "$sort90") || die "can't read $sort90\n";
@data = <SORT>;
close SORT;

$count = 0;
while (@data)
{
	$name = shift @data;
	chomp $name;
	$name = substr($name, 1);
	$file = "$db_dir/$name.hmm";
	if (-f $file)
	{
		$filesize = -s $file;
		if ($filesize > 0)
		{
			print PRC "$file\n";	
			$count++;
		}
	}
	shift @data;
}

close PRC;
print "$count HMM models are included in the library.\n";
