#!/usr/bin/perl -w
if (@ARGV != 2)
{
	die "need two parameters: rank file, model list file\n";
}

$rank_file = shift @ARGV;
$model_list = shift @ARGV;
open(RANK, $rank_file) || die "can't read $rank_file.\n";
@rank = <RANK>;
close RANK; 
shift @rank;

open(MLIST, ">$model_list") || die "can't create $model_list.\n";

while (@rank)
{
	$model = shift @rank;
	@fields = split(/\s+/, $model);
	$mname = $fields[0]; 

	print MLIST "$mname\n";	
}

close MLIST;


