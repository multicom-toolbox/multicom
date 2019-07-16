#!/usr/bin/perl -w
#######################################################################
#Generate hhblits profile (both a3m and hmm) for a list of sequences
#Input: hhsuite dir, #cpu cores, database, input fasta file, output dir
#output: name.a3m and name.hmm
#Author: Jie Hou, Jianlin Cheng
#Date: 07/01/2019
#######################################################################

if (@ARGV != 3)
{
	die "need three parameters: sort90 fasta, hhsuite profiles, output dir.\n";
}

$sort90_file = shift @ARGV;
$input_dir = shift @ARGV;
$output_db = shift @ARGV; 

-d "$output_db" || `mkdir $output_db`;
-d "$output_db/a3m" || `mkdir $output_db/a3m`;
-d "$output_db/hhm" || `mkdir $output_db/hhm`;


chdir($output_db);

open(IN,"$sort90_file") || die "Failed to find $sort90_file\n";
while(<IN>)
{
  $line = $_;
  chomp $line;
  if(substr($line,0,1) eq '>')
  {
    $pdbid = substr($line,1);
    if(-e "$input_dir/$pdbid.hhm" and -e "$input_dir/$pdbid.a3m")
    {
      `ln -s $input_dir/$pdbid.hhm $output_db/hhm/$pdbid`;
      `ln -s $input_dir/$pdbid.a3m $output_db/a3m/$pdbid`;
    }else{
      print "$input_dir/$pdbid.hhm or $input_dir/$pdbid.a3m not exists\n\n";
    }
  } 
}
close IN;

