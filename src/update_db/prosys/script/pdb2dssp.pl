#!/usr/bin/perl

#######pdb2dssp.pl############################## 
#convert pdb format file to dssp format file.
#usage: pdb2dssp.pl source_dir dest_dir
#the dssp file will have the same file name with pdb file except with differnt
#suffix ".dssp.gz". The dssp file is compressed by gzip. 
#Assumption: source file name format: *.Z and compress by gzip. 
#output: pdb_prefix.dssp.gz 
#Author: Jianlin Cheng, 5/28/2003
###############################################

if ($#ARGV != 2)
{
  die "Need three arguments: dssp_dir, source_dir dest_dir\n"
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

$cur_dir = `pwd`; 
`cd $dest_dir`; 

@filelist = readdir(SOURCE_DIR);

while(@filelist) 
{ 
   $pdbfile = shift @filelist;
   $full_pdb_name = $source_dir.$pdbfile;
   #if ( -f $full_pdb_name && $full_pdb_name =~ /.*Z$/)
   if ( -f $full_pdb_name && ($full_pdb_name =~ /.*Z$/ || $full_pdb_name =~ /.*gz$/) )
   {
       #extract the filename without suffix
       $pos = rindex($pdbfile, ".");
       $prefix = substr($pdbfile, 0,$pos);
       #make a copy of the original pdb file.
       $temp_file = $dest_dir.$pdbfile;
       `cp $full_pdb_name  $temp_file`; 
       `gzip -f -d $temp_file`;       
       $unzip_file = $dest_dir.$prefix;
       $dssp_file = $dest_dir.$prefix.".dssp";
       #do conversion
       $status = system("${dssp_dir}dsspcmbi $unzip_file $dssp_file");
       if ($status == 0) #succeed
       {
          `gzip -f $dssp_file`;
       }
       else
       {
          `rm $dssp_file`;
       }
       #remove the unzipped pdb file
       `rm $unzip_file`; 
   }
}

closedir(SOURCE_DIR);
`cd $cur_dir`; 


