#!/usr/bin/perl
###############################################################################
#Convert modeller pdb file to CASP format.
#Input: modeller pdb file, pir alignment file, casp desc file, output file
#Author: Jianlin Cheng
#Date: 11/23/2004
###############################################################################
if (@ARGV != 4)
{
	die "need four parameters: pdb file, model number, target name, output file.\n";
}
$pdb_file = shift @ARGV;
$model_num = shift @ARGV;
$target_name = shift @ARGV;
$out_file = shift @ARGV;

push @templates, "N/A";

#read casp descript file.
$title = "PFRMAT TS\n";
$title .= "TARGET $target_name\n"; 
$title .= "AUTHOR MULTICOM\n";
$title .= "METHOD model evaluation, model combination, and model refinement\n";
$title .= "MODEL $model_num\n"; 
#open(DESC, $desc_file) || die "can't find casp description file: $desc_file.\n";
#while (<DESC>)
#{
#	if (/^PFRMAT/ || /^TARGET/ || /^AUTHOR/ || /^REMARK/ || /^METHOD/ || /^MODEL/)
#	{
#		$title .= $_;
#	}
#}
#close DESC;

#read pdb file
open(PDB, $pdb_file) || die "can't read pdb file.\n";
@atoms = ();
while (<PDB>)
{
	if (/^ATOM\s+/)
	{
		push @atoms, $_; 
	}
}
close PDB;

#output the results
open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT $title;
@uniq_templates = ();
foreach $temp_name (@templates)
{
	$found = 0;
	foreach $utemp (@uniq_templates)
	{
		if ($temp_name eq $utemp)
		{
			$found = 1; 
		}
	}
	if ($found == 0)
	{
		push @uniq_templates, $temp_name;
	}
}
print OUT "PARENT ", join(" ", @uniq_templates), "\n";
print OUT join("", @atoms);
print OUT "TER\nEND\n";
close OUT; 

