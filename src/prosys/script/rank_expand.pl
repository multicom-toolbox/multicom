#!/usr/bin/perl -w
######################################################################
#Expand the rank_all.txt file to a full matrix instead of a triangle
#Input: rank_all.txt, output file name
#Date: 4/29/2005
#Author: Jianlin Cheng
######################################################################
sub round
{
     my $value = $_[0];
     $value *= 10000;
     $value = int($value + 0.5);
     $value /= 10000;
     return $value;
}

if (@ARGV != 2)
{
	die "need two parameters: rank_all.txt, and output file name.\n";
}

$rank_file = shift @ARGV;
$out_file = shift @ARGV;

open(RANK, $rank_file) || die "can't read rank file.\n";
@rank = <RANK>;
close RANK;

#create adjacent list
%adj_list = ();

while(@rank)
{
	$line = shift @rank;
	chomp $line;
	($prot1, $prot2, $order, $match1, $match_small, $ind, $align_len, $len1, $len2, $rmsd) = split(/\s+/, $line);
	

	#add into adjacent list
	if ( exists $adj_list{$prot1} )
	{
		$current = $adj_list{$prot1};
		if ($current !~ /$prot2/)
		{
			$adj_list{$prot1} .= ":$prot2 $match1 $match_small $ind $align_len $len1 $len2 $rmsd";
		}
		else
		{
			print "redudant: $line\n";
		}
	}
	else
	{
		$adj_list{$prot1} = "$prot2 $match1 $match_small $ind $align_len $len1 $len2 $rmsd";
	}
	$match1 = &round($align_len / $len2);
	if ( exists $adj_list{$prot2} )
	{
		$current = $adj_list{$prot2};
		if ($current !~ /$prot1/)
		{
			$adj_list{$prot2} .= ":$prot1 $match1 $match_small $ind $align_len $len2 $len1 $rmsd";
		}
		else
		{
			print "redudant: $line\n";
		}
	}
	else
	{
		$adj_list{$prot2} = "$prot1 $match1 $match_small $ind $align_len $len2 $len1 $rmsd";
	}
}

open(OUT, ">$out_file") || die "can't create output file.\n";

#rerank each adjacent list
foreach $prot1 (keys %adj_list)
{
	$adj_nodes = $adj_list{$prot1};
	@nodes = split(/:/, $adj_nodes);
	if (@nodes <= 0)
	{
		die "$prot1 has no adjacent nodes.\n";
	}
	@group = ();
	foreach $edge (@nodes)
	{
		($prot2, $match1, $match_small, $ind, $align_len, $len1, $len2, $rmsd) = split(/\s+/, $edge);

		push @group, {
			prot1 => $prot1,
			prot2 => $prot2,
			match1 => $match1,
			match_small => $match_small,
			ind => $ind,
			align_len => $align_len,
			len1 => $len1,
			len2 => $len2,
			rmsd => $rmsd
			};
	}
	#@sorted_group = sort {$b->{"match1"} <=> $a->{"match1"}} @group;
	@sorted_group = sort {$b->{"align_len"} <=> $a->{"align_len"}} @group;

	for ($j = 0; $j <= $#sorted_group; $j++)
	{
		print OUT $sorted_group[$j]{"prot1"}, " ";
		print OUT $sorted_group[$j]{"prot2"}, " ";
		print OUT $j + 1, " ";
		print OUT $sorted_group[$j]{"match1"}, " ";
		print OUT $sorted_group[$j]{"match_small"}, " ";
		print OUT $sorted_group[$j]{"ind"}, " ";
		print OUT $sorted_group[$j]{"align_len"}, " ";
		print OUT $sorted_group[$j]{"len1"}, " ";
		print OUT $sorted_group[$j]{"len2"}, " ";
		print OUT $sorted_group[$j]{"rmsd"}, "\n"; 
	}
}

close OUT; 



