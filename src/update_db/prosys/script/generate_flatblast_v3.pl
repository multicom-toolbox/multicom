#!/usr/bin/perl -w
#generate blast flat alignment
#depend on: process-blast.pl

#input parameters
#1. path of blastpgp: e.g: /home/baldig/blast/
#2. path of support perl script(installation dir)
#3. fullpath to big database: e.g: /home/baldig/Data/big/big_98_X
#4. fullpath to nr database: e.g.: /home/baldig/Data/nr/nr
#5. fullpath of input file: fasta format
#6. fullpath of outputfile 

#Author: Jianlin Cheng, 4/5/04
#Update: Jie Hou, remove big db search, 08/2019
################################################################################
#Modification:
#Let script to generate a blast pssm file, which can be used by prosys system
#Date: 4/30/05
#pssm file name: output_file.pssm
#Author: Jianlin Cheng
################################################################################

if(@ARGV != 5)
{
	die "need six parameters: path of blastpgp tool, path of perl script, fullpath of big database, fullpath of nr database, fullpath of input file(fasta format), fullpath of outputfile.\n"; 
}


$blast_dir = $ARGV[0];
if (! -d $blast_dir)
{
	die "the blast directory doesn't exists.\n"; 
}
if ( substr($blast_dir, length($blast_dir) - 1, 1) ne "/" )
{
	$blast_dir .= "/"; 
}

#the directory where process-blast.pl resides.  (usually it is the installation directory of this package
$exec_dir = $ARGV[1]; 
if (! -d $exec_dir)
{
	die "the perl script directory doesn't exists.\n"; 
}
if ( substr($exec_dir, length($exec_dir) - 1, 1) ne "/" )
{
	$exec_dir .= "/"; 
}

$big_nr = $ARGV[2];
$input_file = $ARGV[3]; 
$output_file = $ARGV[4]; 


system("${blast_dir}blastpgp -i $input_file  -o $input_file.blastpgp -j 3 -e 0.001 -h 1e-10 -d $big_nr -Q $output_file.pssm");
$ret = system("${exec_dir}process-blast.pl $input_file.blastpgp $output_file $input_file");
if ($ret != 0)
{
     print "fail to create profile for $input_file\n";
}

#remove the temporay file. 
#`rm $input_file.tmp $input_file.chk $input_file.blastpgp`; 

