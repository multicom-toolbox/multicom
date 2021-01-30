#!/usr/bin/perl -w
###################################################################
#Verify if the templates of local alignment file exist in database
#Input: input local file, atom dir, output local file
#Ouput: local alignments with verified templates are kept
#Author: Jianlin Cheng
#Date: 6/29/2012
###################################################################

if (@ARGV != 3)
{
	die "need three parameters: input local file, atom dir, output local file.\n";
}

$input_file = shift @ARGV;
$atom_dir = shift @ARGV;
$output_file = shift @ARGV;

open(INPUT, $input_file) || die "can't read $input_file.\n";
@input = <INPUT>;
close INPUT; 

open(OUTPUT, ">$output_file") || die "can't create output file.\n";
$title = shift @input;
print OUTPUT $title;

while (@input)
{
	$separator = shift @input;
	$template_info = shift @input;
	$range_info = shift @input;
	$qseq = shift @input;
	$tseq = shift @input;

	#check if template exists
	@fields = split(/\s+/, $template_info);
	$tname = $fields[0]; 
	$tfile = "$atom_dir/$tname.atom.gz";
	if (-f $tfile)
	{
		print OUTPUT "$separator$template_info$range_info$qseq$tseq";
	}
	else
	{
		warn "Template $tname doesn't exist. Skip!\n";
	}
}
close OUTPUT;







