#!/usr/bin/perl -w
############################################################################
#Remove redundant alginments from the same template in a pir alignment file
#Input: pir alignment file
#Effect: reduce redundancy in pir alignment file if necessary
#Author: Jianlin Cheng
#Date: 1/4/2006
############################################################################

if (@ARGV != 1)
{
	die "need pir alignment file as input.\n";
}

$pir_file = shift @ARGV;

open(PIR, $pir_file) || die "can't read $pir_file.\n";
@pir = <PIR>;
close PIR;

if (@pir < 10)
{
	die "There are less than two templates. Don't need to remove redundancy.\n";
}

#check the consistency
(@pir - 4) % 5 == 0 || die "pir format is wrong. stop.\n";

@temps = ();
@start = ();
@end = (); 

@select = ();

$modified = 0; 

while (@pir > 4)
{
	$title = shift @pir;
	$name = shift @pir;
	$stx = shift @pir;
	$align = shift @pir;
	$blank = shift @pir;

	@fields = split(/:/, $stx);
	$id = $fields[1];
	$x = $fields[2];
	$y = $fields[4];

	#check if the region is redundant
	$found = 0; 
	for ($i = 0; $i < @temps; $i++)
	{
		if ($id eq $temps[$i] && $x >= $start[$i] && $y <= $end[$i])
		{
			$found = 1; 
		}
	}

	if ($found == 0)
	{
		push @temps, $id;
		push @start, $x;
		push @end, $y;

		push @select, $title;
		push @select, $name;
		push @select, $stx;
		push @select, $align;
		push @select, $blank;
	}
	else
	{
		print "remove redundant alignment: $name";
		$modified = 1; 
	}
}

if ($modified == 1)
{
	open(PIR, ">$pir_file") || die "can't overwrite $pir_file\n";
	print PIR join("", @select);
	print PIR join("", @pir); 
	close PIR;
}
