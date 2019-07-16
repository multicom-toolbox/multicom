#!/usr/bin/perl -w
#######################################################################
#Generate hhblits profile (both a3m and hmm) for a list of sequences
#Input: sort90, profiles dir, output dir
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

-d "$output_db" || die "Failed to find $output_db\n";

if(-d "$output_db/a3m")
{
  `rm $output_db/a3m/*`;
}else{
  `mkdir $output_db/a3m`;
}

if(-d "$output_db/hhm")
{
  `rm $output_db/hhm/*`;
}else{
  `mkdir $output_db/hhm`;
}

if(-d "$output_db/cs219")
{
  `rm $output_db/cs219/*`;
}else{
  `mkdir $output_db/cs219`;
}

chdir($output_db);

open(IN,"$sort90_file") || die "Failed to find $sort90_file\n";
while(<IN>)
{
  $line = $_;
  chomp $line;
  if(substr($line,0,1) eq '>')
  {
    $pdbid = substr($line,1);
    if(-e "$input_dir/$pdbid.hhm" and -e "$input_dir/$pdbid.a3m" and -e "$input_dir/$pdbid.cs219")
    {
      `ln -s $input_dir/$pdbid.hhm $output_db/hhm/$pdbid`;
      `ln -s $input_dir/$pdbid.a3m $output_db/a3m/$pdbid`;
      `ln -s $input_dir/$pdbid.cs219 $output_db/cs219/$pdbid`;
    }
  } 
}
close IN;

