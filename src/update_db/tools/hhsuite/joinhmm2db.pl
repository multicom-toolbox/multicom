#!/usr/bin/perl -w

$input_dir = "/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite_dbs/a3m/";
$output_db = "/storage/hpc/scratch/jh7x3/multicom/databases/prosys_database/hhsuite_dbs/a3m/hhsuitedb";
`> $output_db`; 
opendir(HHM, $input_dir);
@files = readdir(HHM);
$count = 0; 
while (@files)
{
	$file = shift @files;
	if ($file =~/hhm$/)
	{
		`cat $input_dir/$file >> $output_db`; 		
		$count++; 
	}
}
print "total number of hhm files is $count.\n";



