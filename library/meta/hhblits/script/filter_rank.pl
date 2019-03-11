#!/usr/bin/perl -w

#######################################################
#filter the rank list of hhblits ranking
#Inputs: pdb library, hhblits old ranking, new ranking
#Author: Jianlin Cheng
#######################################################
if (@ARGV != 3)
{
	die "need three parameters: pdb library file, old ranking file, new ranking file name.\n";
}

$pdb_cm = shift @ARGV;
-f $pdb_cm || die "The pdb library file:$pdb_cm does not exist.\n";
$rank_global = shift @ARGV;
-f $rank_global || die "The global rank file:$rank_global does not exist.\n"; 
$new_rank = shift @ARGV;

#generate a rank file that is consistent with our pdb database
#get all pdb codes
@pdb_codes = (); 
open(PDB, "$pdb_cm") || die "can't read $pdb_cm.\n";
@pdb = <PDB>;
close PDB; 

while (@pdb)
{
	$title = shift @pdb;
	chomp $title; 
	$code = substr($title, 1); 
	push @pdb_codes, $code; 
	shift @pdb;
}

open(RANK, "$rank_global") || die "can't read $rank_global.\n";
@rank = <RANK>;
close RANK;
$title = shift @rank;
open(NEWR, ">$new_rank") || die "can't create $new_rank.\n";
print NEWR $title;
$ord = 0; 
while (@rank)
{
	$line = shift @rank;	
	chomp $line;	
	@fields = split(/\s+/, $line);
	$pid = $fields[1];
	$tid = substr($pid, 0, 4);   
	if (length($pid) == 6)
	{
		$tid .= substr($pid, 5, 1);
	}		
	else
	{
		$tid .= "A";
	}
	$tid = uc($tid);

	#check if the code exists
	$found = 0; 
	foreach $record (@pdb_codes)
	{
		if ($tid eq $record)
		{
			$found = 1; 			
			last;
		}	
	}
	if ($found == 1)
	{
		$ord++; 
		print NEWR "$ord\t$tid\t$fields[2]\t$fields[3]\n"; 
	}

}
close NEWR; 
