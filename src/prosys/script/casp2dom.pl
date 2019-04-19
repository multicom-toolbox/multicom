#!/usr/bin/perl -w
#########################################################################################
#convert casp domain format to simple format
#
#11/05/2006
#Input: casp domain file
#Output: regular domain
#Author: Jianlin Cheng
#########################################################################################

if (@ARGV != 1)
{
	die "need casp domain input file.\n";
}
	
$casp_file = shift @ARGV;
open(CASP, $casp_file) || die "can't read casp file.\n";

@casp = <CASP>;
close CASP;

while (@casp)
{
	$line = shift @casp;

	if ($line =~ /^MODEL/)
	{
		last;
	}
}

@idx = ();
@flag = ();

while (@casp)
{
	$line = shift @casp;
	if ($line =~ /^END/)
	{
		last;
	}
	@fields = split(/\s+/, $line);
	push @idx, $fields[0];
	push @flag, $fields[2]; 
}

$length = @idx;

#get domain number
#
$dom_num = 1;

for($i=0; $i < @flag; $i++)
{
	if ($flag[$i] > $dom_num)
	{
		$dom_num = $flag[$i]; 
	}
}

print "domain num: $dom_num\n";

#get the regions for each domain number
#
for ($i = 1; $i <= $dom_num; $i++)
{
	$prev = 0; 
	@start = ();
	@end = (); 
	for ($j = 0; $j < @flag; $j++)
	{
		if ($flag[$j] == $i)
		{
			if ($prev  == 0)
			{
				$prev = $j+1; 
				push @start, $prev; 
			}
			else
			{
				$prev = $j + 1; 
			}
			if ($j == $length - 1)
			{
				push @end, $j+1; 
			}
			
		}
		else
		{
			if ($prev != 0)
			{
				push @end, $prev;
			}
			$prev = 0; 
		}
	}	
	print "domain $i:";
	@start == @end || die "start number != end number\n";
	for ($k =0; $k < @start; $k++)
	{
		if ($k == 0)
		{
			print " $start[$k]-$end[$k]";
		}
		else
		{
			print ", $start[$k]-$end[$k]";
		}
	}
	print "\n";
}





