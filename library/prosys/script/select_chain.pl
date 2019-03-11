#!/usr/bin/perl -w
##########################################################################
#Select chains used in Comparative Modeling
#Criteria: length >= 40, Resolution <= 8A, found ratio > 0.95
#inputs: adjusted input set, output set, min length, resolution thresh, ratio
#Author: Jianlin Cheng
#Date: 3/25/2005
###########################################################################

if (@ARGV != 5)
{
	die " need five parameters: input set, output set, min length(30), resolution threshold(8 Ang), found ratio(0.90).\n";
}

$input_set = shift @ARGV;
$output_set = shift @ARGV;
$min_length = shift @ARGV;
$res_threshold = shift @ARGV;
$ratio = shift @ARGV;

open(INPUT, $input_set) || die "can't read input dataset.\n";
open(OUTPUT, ">$output_set") || die "can't create output dataset.\n";

$rm_ratio = 0; 
$rm_res = 0; 
$rm_len = 0; 
$keep = 0; 
while(<INPUT>)
{
	$title = $_;
	chomp $title;
	$name = <INPUT>;
	$resolution = <INPUT>;
	$length = <INPUT>;
	$seq = <INPUT>;
	<INPUT>;
	$ss = <INPUT>;
	$bp1 = <INPUT>;
	$bp2 = <INPUT>;
	$sa = <INPUT>;
	$xyz = <INPUT>;
	$blank = <INPUT>;

	$tmp_seq = $seq;
	chomp $tmp_seq; 
	@aa = split(/\s+/, $tmp_seq);
	@sec = split(/\s+/, $ss);
	@sov = split(/\s+/, $sa);
	if ($length != @aa || $length != @sec || $length != @sov)
	{
		die "sequence length doesn't match:$name";
	}

	($found, $notf) = split(/, /, $title);
	($other, $found) = split(/=/, $found);
	($other, $notf) = split(/=/, $notf);
	if ( $found/($found+$notf) <= $ratio || $found/($found+$notf) > 1.05)
	{
		$rm_ratio++; 	
		next; 
	}
	($ang, $other) = split(/\s+/, $resolution);
	if ($ang >= $res_threshold)
	{
		$rm_res++; 
		next; 
	}
	if ($length < $min_length)
	{
		$rm_len++; 
		next; 
	}
	$keep++; 
	print OUTPUT "$name$resolution$length$seq$ss$bp1$bp2$sa$xyz$blank";
}
close INPUT;
close OUTPUT;
print "total number of selected chains: $keep\n";
print "removed chains, by ratio=$rm_ratio, by resolution=$rm_res, by length=$rm_len\n";
