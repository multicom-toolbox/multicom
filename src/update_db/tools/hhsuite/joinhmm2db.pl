#!/usr/bin/perl -w

#$input_dir = "/storage/htc/bdm/jh7x3/multicom/databases/prosys_database/hhsuite_dbs/a3m/";

$num = @ARGV;
if($num != 1)
{
  die "need one parameters: databasae directory.";
}

$database_path=$ARGV[0];

-d "$database_path" || die "Failed to find database path $database_path\n";

$input_dir = "$database_path/hhsuite3_dbs/profiles/";
$output_db = "$database_path/hhsuite_dbs/a3m/hhsuitedb";

-d "$database_path/hhsuite_dbs/a3m" || `mkdir -p $database_path/hhsuite_dbs/a3m/`;

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
print "total number of hhm files is $count, saved in $output_db\n";



