#!/usr/bin/perl -w

#######scop_pdb2dssp.pl############################## 
#convert SCOP pdb format file to dssp format file.
#usage: pdb2dssp.pl source_dir dest_dir
#the dssp file will have the same file name with pdb file except with differnt
#suffix ".dssp". 
#Author: Jianlin Cheng, 1/31/2005
###############################################

if ($#ARGV != 2)
{
  die "Need three arguments: dssp_dir of dssp program, source_dir dest_dir\n"
}

$dssp_dir = shift @ARGV; 
$source_dir =  shift @ARGV;
$dest_dir =  shift @ARGV;

if (substr($source_dir, length($source_dir) - 1, 1) ne "/")
{
    $source_dir .= "/";
}
if (substr($dssp_dir, length($dssp_dir) - 1, 1) ne "/")
{
    $dssp_dir .= "/";
}
if (substr($dest_dir, length($dest_dir)-1, 1) ne "/")
{
    $dest_dir .="/";
}

opendir(SOURCE_DIR, "$source_dir") || die "can't open the source dir!";
if (! -d "$dest_dir")
{
  die "can't open the dest dir!";
}

@filelist = readdir(SOURCE_DIR);

while(@filelist) 
{ 
   $pdbfile = shift @filelist;
   if ($pdbfile eq "." || $pdbfile eq "..")
   {
   	next; 
   }
   $full_pdb_name = $source_dir.$pdbfile;
   $dssp_file = $dest_dir.$pdbfile.".dssp";
   #do conversion
   $status = system("${dssp_dir}dsspcmbi $full_pdb_name $dssp_file");
   if ($status == 0) #succeed
   {
   	print "process $pdbfile successfully.\n"; 
   }
   else
   {
   	
   	print "problem with $pdbfile.\n"; 
   }
}

closedir(SOURCE_DIR);


