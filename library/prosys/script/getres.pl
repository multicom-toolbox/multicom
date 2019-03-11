#!/usr/bin/perl -w

##################################################################################################
#parse pdb file and extract useful information (right now: resolution only)
#input: pdb_file, output file 
#Assumption: If source file name format is  *.Z, assume
# is is compressed by gzip or compress. 
#
#output format: seq_name(pdb code),
#resolution(number) and experiment methods (X: X-ray, O: other), 
#Author: Modified from parse_pdb_atom.pl, Jianlin Cheng, 3/25/2005 
#################################################################################################

if (@ARGV != 2)
{
	die "Need two arguments: pdb file, output file\n"
}

$pdb_file =  shift @ARGV;
-f $pdb_file || die "pdb file doesn't exist.\n"; 
$output_file =  shift @ARGV;

$pdbfile = ""; #file name without path
$index = rindex($pdb_file, "/");
if ($index >= 0)
{
	$pdbfile = substr($pdb_file, $index+1); 
}
else
{
	$pdbfile = $pdb_file; 
}
#create tmp file name
$tmp_file = "tmp$pdbfile"; 
`cp $pdb_file $tmp_file`; 

if ($pdb_file =~ /.*Z$/)
{
       #unzip the file
       `gzip -f -d $tmp_file`;       
       $pos = rindex($tmp_file, ".");
       $tmp_file = substr($tmp_file, 0,$pos);
}
#extract pdb code
$pdb_code = substr($tmp_file, 6, 4); #"file format: tmppdbxxxx...." 

open(PDB, "$tmp_file") || die "fail to open unzip pdb file:$tmp_file.\n";
@content = <PDB>;
close PDB;

$x_ray = "O"; #default: non-x-ray 
$resolution = "6.0";

foreach $text(@content)
{
	chomp $text; 
	#check if it is X-RAY
	if ($text =~ /.*EXPDTA\s+X-RAY/)
	{
		$x_ray = "X"; 
	}
	#extract resolution
	if ($text=~/.*REMARK.*2.*RESOLUTION.*ANGSTROMS.*/)
	{
	     ($tmp, $tmp, $tmp, $resolution, @otherstuff) = split(/\s+/, $text);
	     @otherstuff = (); 
	     $resolution =~ /^(\d+\.\d+)/; 
	     $resolution = $1; 
	     if (length($resolution) == 0)
	     {
	     	#some case, not resolution information (not applicable), set resolution to 10A. 
		$resolution = 6.0; 
	     	print "$pdb_code: resolution is not found, set to 6.0\n"; 
	     }
	}
}

open(OUT, ">$output_file") || die "can't create output file.\n"; 
print OUT "$pdb_code\n$resolution $x_ray\n";
close OUT; 

#remove the unzipped pdb file
`rm $tmp_file`; 

