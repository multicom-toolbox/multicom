#!/usr/bin/perl -w
###########################################################################
#Rank the stx-stx alignments for each protein from sarf output
#Input: stx-stx.txt file, output file
#Output: prot 1, length 1, protein 2, length 2, match, identity in match,
#        rank 
#Author: Jianlin Cheng
#Date: 4/21/2005
###########################################################################
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
	die "need two params: stx-stx alignment file, output file.\n";
}
$align_file = shift @ARGV;
$rank_file = shift @ARGV;

open(ALIGN, $align_file) || die "can't read alignment file.\n";
open(RANK, ">$rank_file") || die "can't create ranking file.\n";

@align = <ALIGN>;
close ALIGN;

$first = 1;
@group = (); 
$pre_id = ""; 

while (@align)
{
	$line = shift @align;
	chomp $line;
	#replace % with blank
	#$line =~ s/\%/ /g; 
	#field: 1:prot1, 2:length1, 3:prot2, 4:length3, 5:align_length, 
	#6:rmsd, 7:match 8:identity of match, other
	@fields = (); 
	if ($line =~ /^(\S+)\s+\(\s*(\d+)\)\s+(\S+)\s+\(\s*(\d+)\)\s+(\d+)\s+([\.\d]+) ([\d\.]+)\%\s+([\d\.]+)\%\s+/)
	{
		$prot1 = $1;
		$len1 = $2;
		$prot2 = $3;
		$len2 = $4;
		$align_len = $5;
		$rmsd = $6;
		$match = $7;
		$ind = $8;
		#prot 1, prot2, match,iden, align_len, len1, len2, rmsd) 
		push @fields, ($prot1, $prot2, $match, $ind, $align_len, $len1, $len2, $rmsd); 
	}
	else
	{
		die "format error: $line\n";
	}
	if ($first == 1)
	{
		$first = 0;
		$pre_id = $prot1; 
	}

	#$record = join(" ", @fields); 
	if ($prot1 eq $pre_id)
	{
		#push @group, $record;

		push @group, {
			prot1 => $prot1,
			prot2 => $prot2,
			match0 => &round($align_len / $len1),
			match => $match,
			ind => $ind,
			align_len => $align_len,
			len1 => $len1,
			len2 => $len2,
			rmsd => $rmsd
			};

	}
	else
	{
		if (@group > 0)
		{
			#sort the group and write it out
			#@sorted_i = sort { $group[$a]{"match"} <=> $group[$b]{"match"} } (0..$#group);
			#@sorted_group = (); 
			#for ($j = 0; $j <= $#group; $j++)
			#{
			#	@sorted_group[$sorted_i[$j]] =  $group[$j]; 
			#}
			@sorted_group = sort {$b->{"match0"} <=> $a->{"match0"}} @group;

			for ($j = 0; $j <= $#sorted_group; $j++)
			{
				print RANK $sorted_group[$j]{"prot1"}, " ";
				print RANK $sorted_group[$j]{"prot2"}, " ";
				print RANK $j + 1, " ";
				print RANK $sorted_group[$j]{"match0"}, " ";
				print RANK $sorted_group[$j]{"match"}, " ";
				print RANK $sorted_group[$j]{"ind"}, " ";
				print RANK $sorted_group[$j]{"align_len"}, " ";
				print RANK $sorted_group[$j]{"len1"}, " ";
				print RANK $sorted_group[$j]{"len2"}, " ";
				print RANK $sorted_group[$j]{"rmsd"}, "\n"; 

			}
		}

		#start the next group
		@group = ();
		push @group, {
			prot1 => $prot1,
			prot2 => $prot2,
			match0 => &round($align_len / $len1),
			match => $match,
			ind => $ind,
			align_len => $align_len,
			len1 => $len1,
			len2 => $len2,
			rmsd => $rmsd
			};
	#	push @group, $record; 
		$pre_id = $prot1; 
	}
}

if (@group > 0)
{
	#sort the last group and write it out
	#@sorted_group = sort { $a{"match"} cmp $b{"match"} } @group; 
	#@sorted_i = sort { $group[$a]{"match"} <=> $group[$b]{"match"} } (0..$#group);
	#@sorted_group = (); 
	#for ($j = 0; $j <= $#group; $j++)
	#{
	#	@sorted_group[$sorted_i[$j]] =  $group[$j]; 
	#}
	@sorted_group = sort {$b->{"match0"} <=> $a->{"match0"}} @group;
	for ($j = 0; $j <= $#sorted_group; $j++)
	{
		print RANK $sorted_group[$j]{"prot1"}, " ";
		print RANK $sorted_group[$j]{"prot2"}, " ";
		print RANK $j + 1, " ";
		print RANK $sorted_group[$j]{"match0"}, " ";
		print RANK $sorted_group[$j]{"match"}, " ";
		print RANK $sorted_group[$j]{"ind"}, " ";
		print RANK $sorted_group[$j]{"align_len"}, " ";
		print RANK $sorted_group[$j]{"len1"}, " ";
		print RANK $sorted_group[$j]{"len2"}, " ";
		print RANK $sorted_group[$j]{"rmsd"}, "\n"; 
	}
			
}

close RANK; 
