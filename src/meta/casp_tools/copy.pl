#!/usr/bin/perl -w


$src_dir =  "/var/www/html/refine/";

opendir(DIR, $src_dir);
@files = readdir(DIR);
close DIR;

while (@files)
{
	$file = shift @files;

	if ($file !~ /^T0/ || length($file) > 5)
	{
		next;
	}

	$target_dir = $src_dir . $file . "/hhsearch";

	mkdir $file;

	`cp $target_dir/hh1.pir $file/$file.pir`; 
	`cp $target_dir/hh1.pdb $file/$file.pdb`; 
	`cp $target_dir/*.atm $file/`; 
}
