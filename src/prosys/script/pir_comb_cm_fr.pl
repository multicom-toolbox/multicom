#!/usr/bin/perl -w
########################################################################
#Combine a cm pir alignment with a list of fr alignment
#Input: script_dir, cm_pir_file, fr_pir_file_list, min_cover_size, 
#       gap_stop_size, max_linker_size, output_file
#Notice: if max_linker_size < 0, using simple combination; otherwise,
#use advanced combination.
#Author: Jianlin Cheng
#Date: 10/04/2005
#########################################################################

if (@ARGV != 7)
{
	die "need 7 parameters: script_dir, cm_pir_file, fr_pir_file_list, min_cover_size(20), gap_stop_size(20), max_linker_size(10), output file\n";
}

$script_dir = shift @ARGV;
$cm_pir_file = shift @ARGV;
$fr_pir_list = shift @ARGV;
$min_cover_size = shift @ARGV;
$gap_stop_size = shift @ARGV;
$max_linker_size = shift @ARGV;
$output_file = shift @ARGV;

#set full path to cm pir file
$cur_dir = `pwd`;
chomp $cur_dir;
if ( substr($cm_pir_file, 0, 1) ne "/" )
{
	if ( substr($cm_pir_file, 0, 2) eq "./" )
	{
		$cm_pir_file = $cur_dir . "/" . substr($cm_pir_file, 2); 
	}
	else
	{
		$cm_pir_file = $cur_dir . "/" . $cm_pir_file; 
	}
}
#read cm alignment file and generate a list of templates used in it.
open(PIR, $cm_pir_file) || die "can't read cm pir file.\n";
@cm_pir = <PIR>;
close PIR; 

if (@cm_pir < 8)
{
	die "$cm_pir_file doesn't contain alignments. stop.\n";
}

#read query information
pop @cm_pir;
pop @cm_pir;
$query = pop @cm_pir;
pop @cm_pir;
chomp $query;
$query = substr( $query, index($query, ";") + 1 );

#generate template list used in the cm alignment
@cm_list = (); 
while (@cm_list)
{
	shift @cm_list;
	shift @cm_list;
	$stx = shift @cm_list;
	shift @cm_list;
	shift @cm_list;

	@records = split(/:/, $stx);
	$id = $records[1]; 
	push @cm_list, $id; 
}

#read fr_pir_list
open(FR_LIST, $fr_pir_list) || die "can't read fr template list.\n";
@temp_list = <FR_LIST>;
close FR_LIST;

#create a temporary candidate list file
open(CAN, ">$cm_pir_file.can") || die "can't create a candidate list file.\n";
print CAN "$cm_pir_file\n";

while (@temp_list)
{
	$temp_file = shift @temp_list;
	chomp $temp_file;

	open(PIR, $temp_file) || die "can't read cm pir file.\n";
	@temp_pir = <PIR>;
	close PIR; 
	pop @temp_pir;
	pop @temp_pir;
	$temp = pop @temp_pir;
	pop @temp_pir;
	chomp $temp;
	$temp = substr( $temp, index($temp, ";") + 1 );

	#check if the temp appears in the cm pir file
	$found = 0; 
	foreach $id (@cm_list)
	{
		if ($temp eq $id)
		{
			$found = 1; 
		}
	}
	if ($found == 0)
	{
		print CAN "$temp_file\n"; 
	}
}

close CAN; 

#do combination
if ($max_linker_size < 0)
{
	system("$script_dir/pir_simple_comb.pl $script_dir $cm_pir_file.can $min_cover_size $gap_stop_size 1 $output_file");
}
else
{
	system("$script_dir/pir_adv_comb.pl $script_dir $cm_pir_file.can $min_cover_size $gap_stop_size $max_linker_size 1 $output_file");
}

#rename the file
`mv ${output_file}1.pir $output_file`; 

#remove the temporary file
`rm $cm_pir_file.can`; 




