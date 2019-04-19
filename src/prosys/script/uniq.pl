#!/usr/bin/perl -w
####################################################
#Create a uniq list of chains in Rych dataset from pair list
#Author: Jianlin Cheng, Date: 1/29/05
####################################################

$file = shift @ARGV;
open(FILE, "$file");
<FILE>;
@content = <FILE>; 
close FILE; 
@list = ();
while (@content)
{
	$line = shift @content;
	chomp $line; 
	@entries = split(/\s+/, $line);
	$id1 = shift @entries;
	$id2 = shift @entries;

	$found = 0; 
	foreach $chain(@list)
	{
		if ($chain eq $id1)
		{
			$found = 1; 
		}
	}
	if ($found == 0)
	{
		push @list, $id1; 
	}

	$found = 0; 
	foreach $chain(@list)
	{
		if ($chain eq $id2)
		{
			$found = 1; 
		}
	}
	if ($found == 0)
	{
		push @list, $id2; 
	}

}
$size = @list;
print "total number of chains: $size\n";
foreach $chain(@list)
{
	print "$chain\n"; 
}

