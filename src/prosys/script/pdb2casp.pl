#!/usr/bin/perl
###############################################################################
#Convert modeller pdb file to CASP format.
#Input: modeller pdb file, pir alignment file, casp desc file, output file
#Author: Jianlin Cheng
#Date: 11/23/2004
###############################################################################
if (@ARGV != 4)
{
	die "need four parameters: pdb file, pir file, model number, output file.\n";
}
$pdb_file = shift @ARGV;
$pir_file = shift @ARGV;
$model_num = shift @ARGV;
$out_file = shift @ARGV;

#read pir alignment file to get all templates
open(PIR, $pir_file) || die "can't read pir file: $pir_file\n";
@pir = <PIR>;
close PIR;

@templates = (); 
#list at most 5 template names
$max_parent = 8; 
while (@pir > 4)
{
	$line = shift @pir;
	chomp $line;
	if ($line =~ /^>P1;(.+)$/)
	{
		if ($1 =~ /^ab1/ || $1 =~ /^ab2/)
		{
			if (@templates <= 0)
			{
				push @templates, "N/A";
			}
		}
		elsif (@templates < $max_parent)
		{
			$temp_name = substr($1,0,5);
			push @templates, $temp_name; 
		}
	}
}

if (@templates < 1)
{
	die "fail to convert pdb file to CASP because I can't find parent in pir file.\n";
}

#get the target name
$target_name = $pir[1]; 
chomp $target_name;
$target_name = substr($target_name, 4);

#read casp descript file.
$title = "PFRMAT TS\n";
$title .= "TARGET $target_name\n"; 
$title .= "AUTHOR MULTICOM\n";
$title .= "REMARK Protein fold recognition using FOLDpro\n";
#$title .= "REMARK Use one or more templates for structure modeling\n";
$title .= "METHOD Cheng and Baldi.A Machine Learning Information Retrieval Approach\n";
$title .= "METHOD to Protein Fold Recognition.Bioinformatics,2006:22:1456-1463.\n";
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

