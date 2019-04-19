#!/usr/bin/perl

#Create a data set file from a set of dssp file. 
#Input parameters: source dir of dssp files, dataset name 
#Output: a dataset file in current directory. 
#Dependent script: dssp2adataset.pl. 
#Assumption: if the dssp files are zipped, filename: pdb*dssp.gz , otherwise: filename="*.dssp"
#Author: Jianlin Cheng, 5/28/2003
#Copied from dipro/script, modified on 8/12/2004, then modified on 1/31/2005

if ($#ARGV != 2)
{
   die "need three parameters: script_dir, source dir of zip(or non-zip) dssp files and data set name. \n";
}
$script_dir = shift @ARGV; 
if (substr($script_dir, length($script_dir) -1, 1) ne  "/")
{
    $script_dir .= "/";
}
$source_dir = shift @ARGV; 
$dest_file = shift @ARGV;
`touch $dest_file`;
`touch error.log`;
if (substr($source_dir, length($source_dir) -1, 1) ne  "/")
{
    $source_dir .= "/";
}
opendir(DSSP, "$source_dir") || die "can't open the source directory. ";
@filelist = readdir(DSSP);
closedir(DSSP);

open(STDERR, ">error.log");

while (@filelist)
{
    $file = shift @filelist;
    $temp_file = $file;
    $file = $source_dir.$file;
    if (-f $file)
    {
      if ($file =~/.*pdb.*dssp\.gz$/) #check if it is a dssp zip file
      {
	#copy the dssp file to current directory
    	`cp $file $temp_file`;
    	#strip the .gz 
    	$pos = rindex($temp_file, ".");
    	$prefix = substr($temp_file, 0,$pos);
    	`gunzip $temp_file`;
    	`${script_dir}dssp2adataset.pl $prefix  $dest_file`;    
    	`rm $prefix`;
      }
      elsif ($file =~/.*\.+dssp$/) #non-zip dssp file, end with ".dssp" suffix
      {
    	`cp $file $temp_file`;
    	$prefix = $temp_file;
    	`${script_dir}dssp2adataset.pl $prefix  $dest_file`;    
    	`rm $prefix`;
      }
    }
}

