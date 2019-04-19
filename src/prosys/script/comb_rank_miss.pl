#!/usr/bin/perl -w
############################################################################
#combine the rank.txt and missout.txt, and rank them altogether
#inputs: rank.txt, missout.txt and output file name
#output: same format as rank.txt
#for each entry in missout.txt, we need to find the length from rank.txt
#Author: Jianlin Cheng
#Date: 4/28/2005
#############################################################################
sub round
{
     my $value = $_[0];
     $value *= 100;
     $value = int($value + 0.5);
     $value /= 100;
     return $value;
}

if (@ARGV != 3)
{
	die "need three parameters: rank.txt, missout.txt file, output file.\n";
}

$rank_file = shift @ARGV;
$miss_file = shift @ARGV;
$out_file = shift @ARGV;

open(RANK, $rank_file) || die "can't read rank file.\n";
@rank = <RANK>;
close RANK;
open(MISS, $miss_file) || die "can't read miss file.\n";
@miss = <MISS>;
close MISS; 

#generate the length for each protein
%lengths = (); 
foreach $entry (@rank)
{
	($pa, $pb, $num, $match0, $match, $ind, $align_len, $len1, $len2, $rmsd) = split(/\s+/, $entry);

	if (!exists $lengths{$pa})
	{
		$lengths{$pa} = $len1; 
	}
	elsif ($lengths{$pa} != $len1)
	{
		die "length doesn't match: $pa, $len1, $lengths{$pa}\n";
	}

	if (!exists $lengths{$pb})
	{
		$lengths{$pb} = $len2; 
	}
	elsif ($lengths{$pb} != $len2)
	{
		die "length doesn't match: $pb, $len2, $lengths{$pb}\n";
	}
}

#process miss file
#for each entry in the miss file, find the entry in the rank file
#insert it into the appropriate place. 
while (@miss)
{
	$pair = shift @miss;
	print "process: $pair";
	chomp $pair;
	$info = shift @miss;
	chomp $info; 
	if (length($info) <= 13)
	{
		die "format error, info = $info\n";
	}

	($prot1, $prot2) = split(/\s+/, $pair); 
	if ($info =~ /^(\S+)\s+\(\s*(\d+)\)\s+(\S+)\s+\(\s*(\d+)\)\s+(\d+)\s+([\.\d]+) ([\d\.]+)\%\s+([\d\.]+)\%\s+/)
	{
		$prota = $1;
		$len1 = $2;
		$protb = $3;
		$len2 = $4;
		$align_len = $5;
		$rmsd = $6;
		$match = $7;
		$match0 = &round($align_len / $len1),
		$ind = $8;
		if ($prota ne $prot1 || $protb ne $prot2)
		{
			die "proteins don't match.\n"; 
		}
	}
	elsif ($info =~ /^\s*(\d+)\s+Ca-atoms\s+\(\s*(\d+)\%\),\s+rmsd\s+=\s+([\d\.]+),\s+(\d+)\%\s+/)
	{
		$align_len = $1;
		$match = $2;
		$rmsd = $3; 
		$ind = $4;
		$len1 = $lengths{$prot1};
		$len2 = $lengths{$prot2};
		$match0 = &round($align_len / $len1); 
	}
	else
	{
		die "format error in miss file: $pair, $info.";
	}
	#find appropriate positions to insert the entry

	@new_rank = ();
	$is_added = 0; 
	$rank = 1; 
	foreach $entry (@rank)
	{
		($pa, $pb, $num, $e_match0, $e_match, $e_ind, $e_align_len, $e_len1, $e_len2, $e_rmsd) = split(/\s+/, $entry);
		if ($prot1 eq $pa)
		{
			if ($match0 >= $e_match0 && $is_added == 0)
			{
				#insert the new data point
				$add = "$prot1 $prot2 $rank $match0 $match $ind $align_len $len1 $len2 $rmsd\n";
				push @new_rank, $add; 
				$is_added = 1; 
				$rank++; 
			}
			push @new_rank, "$pa $pb $rank $e_match0 $e_match $e_ind $e_align_len $e_len1 $e_len2 $e_rmsd\n";
			$rank++; 	
		}
		else
		{
			push @new_rank, $entry; 
		}
	}
	@rank = @new_rank; 
}

#print out the new rank file
open(OUT, ">$out_file") || die "can't create output file.\n";
foreach $entry (@new_rank)
{
	print OUT $entry;
}
close OUT; 


