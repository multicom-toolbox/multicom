#!/usr/bin/perl -w
#################################################################
#Order the local alignments by alignmened lengths for query
#Input: local alignment file, output file.
#Output: sorted local alignments for the same template
#Author: Jianlin Cheng
#Date: 7/13/2005
#################################################################

if (@ARGV != 2)
{
	die "need two parameters: local alignment file, output file.\n";
}
$local_file = shift @ARGV;
$out_file = shift @ARGV;

open(LOCAL, $local_file) || die "can't read local alignment file.\n";
@local = <LOCAL>;
close LOCAL;

$feature = shift @local;
$value = shift @local;
if (@local < 5)
{
	die "no local alignments.\n";
}

@group = ();
$prev = ""; 
while (@local)
{
	$pos = shift @local;
	chomp $pos;
	($qstart, $qend, $tstart, $tend) = split(/\s+/, $pos);
	$qname = shift @local;
	chomp $qname;
	$qseq = shift @local;
	chomp $qseq; 
	$tname = shift @local;
	chomp $tname;
	$tseq = shift @local;
	chomp $tseq;

	if ($prev ne "" && $prev ne $tname)
	{
		die "local alignments belong to more than one template.\n";
	}
	$prev = $tname; 

	$size = $qend - $qstart + 1;
	if ($size < 1 || $tend - $tstart + 1 < 1)
	{
		die "local alignment size is less than 0.\n";
	}
	push @group, {
		qname => $qname,
		qseq => $qseq,
		qstart => $qstart,
		qend => $qend,
		tname => $tname,
		tseq => $tseq,
		tstart => $tstart,
		tend => $tend,
		size => $size
		}; 
}
@sorted_group = sort {$b->{"size"} <=> $a->{"size"}} @group;

open(OUT, ">$out_file") || die "can't create output file\n";

print OUT "$feature$value";
#output the sorted alignment
for ($j = 0; $j <= $#sorted_group; $j++)
{
	print OUT $sorted_group[$j]{"qstart"}, " ";
	print OUT $sorted_group[$j]{"qend"}, " ";
	print OUT $sorted_group[$j]{"tstart"}, " ";
	print OUT $sorted_group[$j]{"tend"}, "\n";
	print OUT $sorted_group[$j]{"qname"}, "\n";
	print OUT $sorted_group[$j]{"qseq"}, "\n";
	print OUT $sorted_group[$j]{"tname"}, "\n";
	print OUT $sorted_group[$j]{"tseq"}, "\n";
}
close OUT; 

