#!/usr/bin/perl -w
######################################################################
#remove inconsistent pairs for each query
#Input: rank_query.txt, pair.list, output file name
#Date: 4/29/2005
#Author: Jianlin Cheng
######################################################################

if (@ARGV != 3)
{
	die "need two parameters: rank_query.txt, pair.list, and output file name.\n";
}

$rank_file = shift @ARGV;
$pair_file = shift @ARGV;
$out_file = shift @ARGV;

open(RANK, $rank_file) || die "can't read rank file.\n";
@rank = <RANK>;
close RANK;

open(PAIR, $pair_file) || die "can't read pair list file.\n";
@pairs = <PAIR>;
close PAIR; 
shift @pairs;

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
}

open(OUT, ">$out_file") || die "can't create output file.\n";

#check the adjacent list and remove inconsistent
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

	$size = @group;
	@new_group = (); 

	#remove inconsistency
	$has_one_true = 0;
	for ($i = $size - 1; $i >= 0; $i--)
	{
		$pa = $group[$i]{"prot1"};
		$pb = $group[$i]{"prot2"};

		#if pa and pb forms a pair (in pair.list), them remove all non-true pairs before it
		$is_true = 0;
		foreach $entry (@pairs)
		{
			($que, $tar, @other) = split(/\s+/, $entry);
			if ($que eq $pa && $tar eq $pb)
			{
				$is_true = 1; 
			}
		}

		#remove pairs the not ture, but before it
		if ($is_true)
		{
			unshift @new_group, $group[$i]; 
			for ($j = $i - 1; $j >= 0; $j--)
			{
				$pa = $group[$j]{"prot1"};
				$pb = $group[$j]{"prot2"};
				$is_ok = 0;
				foreach $entry (@pairs)
				{
					($que, $tar, @other) = split(/\s+/, $entry);
					if ($que eq $pa && $tar eq $pb)
					{
						$is_ok = 1; 
						last;
					}
				}
				if ($is_ok == 1)
				{
					unshift @new_group, $group[$j]; 
				}
				else
				{
					print "$pa $pb pair is ahead of true pairs, removed.\n";
				}
				
			}
				
			$has_one_true = 1; 
			last;
		}
		else
		{
			unshift @new_group, $group[$i]; 
		}
	}

	if ($has_one_true == 0)
	{
		print "$prot1 doesn't have one true pairs.\n";
	}

	for ($j = 0; $j <= $#new_group; $j++)
	{
		print OUT $new_group[$j]{"prot1"}, " ";
		print OUT $new_group[$j]{"prot2"}, " ";
		print OUT $j + 1, " ";
		print OUT $new_group[$j]{"match1"}, " ";
		print OUT $new_group[$j]{"match_small"}, " ";
		print OUT $new_group[$j]{"ind"}, " ";
		print OUT $new_group[$j]{"align_len"}, " ";
		print OUT $new_group[$j]{"len1"}, " ";
		print OUT $new_group[$j]{"len2"}, " ";
		print OUT $new_group[$j]{"rmsd"}, "\n"; 
	}
}

close OUT; 



