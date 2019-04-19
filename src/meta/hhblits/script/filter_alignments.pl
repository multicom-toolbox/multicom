#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using hhsearch and combinations
#filter out alignments whose pdb templates cannot be found
##########################################################################

if (@ARGV != 3)
{
	die "need three parameters: pdb list file, input alignment file, output alignment file.\n"; 
}

$pdb_list_file = shift @ARGV;
$input_alignment_file = shift @ARGV;
$output_alignment_file = shift @ARGV;

open(PDBLIST, $pdb_list_file) || die "cant read the pdb list file: $pdb_list_file\n";
@pdb_list = <PDBLIST>;
close PDBLIST;

$total = @pdb_list;
print "total number of alignments: $total\n";

open(INPUTALIGN, $input_alignment_file) || die "can't read input alignment file: $input_alignment_file.\n";
@inputali = <INPUTALIGN>;
close INPUTALIGN;

open(OUTPUTALIGN, ">$output_alignment_file") || die "can't create output alignment file: $output_alignment_file.\n";
if (@inputali < 1)
{
	close OUTPUTALIGN;
	die "There is no alignment in $input_alignment_file.\n";	
}


$line = shift @inputali; 
print OUTPUTALIGN $line; 

while (@inputali)
{
	$first = shift @inputali;		
	$second = shift @inputali;
	$third = shift @inputali;
	$fourth = shift @inputali;
	$fifth = shift @inputali;

	$pdb_id = substr($second, 0, 6);
	
	#check if the id exists 
	$found = 0;
	foreach $entry (@pdb_list)
	{
		if ($entry =~ /^$pdb_id/)
		{
			$found = 1; 		
		}
	}
	
	if ($found == 1) 
	{
		print OUTPUTALIGN "$first$second$third$fourth$fifth";
	}
	else
	{
		print "One alignment is filtered out because the template id is not found: $pdb_id\n";
	}

}
close OUTPUTALIGN;






