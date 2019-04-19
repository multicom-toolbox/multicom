#!/usr/bin/perl -w
#########################################################################
#Compute the palign profile alignment score (with or without ss info)
#Currently, does not support SS. 
#Input: palign dir, query file(fasta), query pssm, 
# target file(fasta), target pssm
#Output: score, and alignments (how to represent this local alignments)
#alignment is the simliar as local alignment format as in CM scripts
#Author: Jianlin Cheng
#Date: 5/3/2005
#########################################################################
if (@ARGV != 6)
{
	die "need six parameters: palignp dir, query file(fasta), query pssm file, target file(fasta), target pssm file, ouptut file.\n";
}
#$script_dir = shift @ARGV;
#-d $script_dir || die "can't find script dir.\n";

$palign_dir = shift @ARGV;
-d $palign_dir || die "can't find palignp dir.\n";
if (!-f "$palign_dir/palignp")
{
	die "can't find palignp executable file.\n";
}

$query_fasta = shift @ARGV;
-f $query_fasta || die "can't find query fasta file.\n";
open(QUERY, $query_fasta);
$code1 = <QUERY>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY;

$query_pssm = shift @ARGV;
-f $query_pssm || die "can't find query pssm file.\n";

$target_fasta = shift @ARGV;
-f $target_fasta || die "can't find target fasta file.\n";

open(TARGET, $target_fasta);
$code2 = <TARGET>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <TARGET>;
chomp $seq2; 
close QUERY;
$target_pssm = shift @ARGV;
-f $target_pssm || die "can't find target pssm file.\n";

$out_file = shift @ARGV;

#do prof-prof alignment using palignp
#`$palign_dir/palignp -ali -seq $query_pssm - -prof $target_pssm - >$query_pssm.pal`;
`$palign_dir/palignp -ali -seq $query_pssm - -prof $target_pssm - >$out_file.pal`;

#read and parse alignment results
open(RES, "$out_file.pal") || die "can't read palignp alignment results.\n";
$line1 = <RES>;
chomp $line1;
print "$line1\n";
@other = split(/\s+/, $line1); 
$len1 = pop @other;
if ($len1 != length($seq1))
{
	die "palign alignment length 1 doesn't match with sequence length.\n";
}
$line2 = <RES>;
chomp $line2;
@other = split(/\s+/, $line2); 
$len2 = pop @other;
if ($len2 != length($seq2))
{
	die "palign alignment length 2 doesn't match with sequence length.\n";
}
<RES>;
$score = <RES>;
#if ( $score =~ /SCORE>\s+([\d\.]+)E([\+-]+)(\d+)\s+([\d\.]+)E([\+-]+)(\d+)/)
if ( $score =~ /SCORE>\s+([\d\.]+)E([\+-]+)(\d+)\s+([-\d\.]+)E([\+-]+)(\d+)/)
{
	$qa = $1;
	$qsign = $2;
	$qb = $3;

	#print "$qa $qsign $qb\n";
	if ($qsign eq "+")
	{
		$score1 = log($qa) + $qb;
	}
	elsif ($qsign eq "-")
	{
		$score1 = log($qa) - $qb;
	}
	else
	{
		die "score format error:$score\n";
	}

	$ta = $4;
	$tsign = $5;
	$tb = $6;

	#print "$ta $tsign $tb\n";
	if ($ta > 0)
	{
		if ($tsign eq "+")
		{
			$score2 = log($ta) + $tb;
		}
		elsif ($tsign eq "-")
		{
			$score2 = log($ta) - $tb;
		}
		else
		{
			die "score format error:$score\n";
		}
	}
	else
	{
		#warn "warning: score2 of profile palign is negative.\n";
		$score2 = -10; 
	}

	#change to use original value
	#warn "score:$score\n"; 
	if ($tsign eq "-")
	{
		$score2 = $ta * exp(-$tb);
	}
	else
	{
		$score2 = $ta * exp($tb);
	}
	if ($score2 > 10)
	{
		$score2 = 10; 
	}
	elsif ($score2 < -10)
	{
		$score2 = -10; 
	}
}
else
{
	die "alignment score error:$score\n";
}
@aligns = <RES>;
close RES;
if (@aligns != $len1)
{
	die "alignment doesn't match with query length.\n";
}

#parse alignments
@align1 = ();
@pos1 = ();
@align2 = ();
@pos2 = ();
$empty = $value = "";
foreach $record (@aligns)
{
	chomp $record;
	($empty, $aa1, $idx1, $aa2, $idx2, $value) = split(/\s+/, $record); 
	push @align1, $aa1;
	push @pos1, $idx1;
	push @align2, $aa2;
	push @pos2, $idx2;
}

#check consistency
for ($i = 0; $i < $len1; $i++)
{
	if ( substr($seq1, $pos1[$i]-1, 1) ne $align1[$i] )
	{
		#check if orignal residue is "X"
		if ( substr($seq1, $pos1[$i]-1, 1) eq "X" )
		{
			$align1[$i] = "X"; 
		}
		else
		{
			print "pos = $pos1[$i]\n";
			die "query aa not match at pos ",  $i + 1, " ", $align1[$i], " v.s ", substr($seq1, $pos1[$i]-1, 1); 
		}
	}
	if ( $pos2[$i] > 0 && substr($seq2, $pos2[$i]-1, 1) ne $align2[$i] )
	{
		if ( substr($seq2, $pos2[$i]-1, 1) eq "X")
		{
			$align2[$i] = "X"; 
		}
		else
		{
			die "target aa not match at pos ",  $i + 1, " ", $align2[$i], " v.s ", substr($seq2, $pos2[$i]-1, 1); 
		}
	}
}

#extract local alignments
#for each aligned segment: 
open(OUT, ">$out_file") || die "can't create output file.\n";
print "feature num: 2\n";
print OUT "feature num: 2\n";
print "$score1 $score2\n";
print OUT "$score1 $score2\n";
#foramt: line 1: query start, query end, sub start, sub end 
#	 line 2: query name
#	 line 3: aligned query
#	 line 4: target name
#	 line 5: aligned target
$sega = "";
@posa  = (); 
$segb = "";
#$pre_one = "."; 

sub make_gaps
{
	my $size = $_[0];
	my $gap = "";
	for (my $i = 0; $i < $size; $i++)
	{
		$gap .= "-";
	}
	return $gap; 
}

for ($i = 0; $i < $len1; $i++)
{
	if ($align2[$i] ne ".")
	{

		########################################################
		#fix a bug of gapping, 9/1/2005.
		#check if need to add gaps
		$gapb = 0;
		$gapa = 0;
		if ($i > 0 && $align2[$i-1] ne ".")
		{
			$gapa = $pos2[$i] - $pos2[$i-1] - 1;
			$gapb = $pos1[$i] - $pos1[$i-1] - 1;
		}
		$agap = "";
		$ainsert = "";
		$bgap = "";
		$binsert = "";
		if ($gapa > 0)
		{
			$agap = &make_gaps($gapa);		
			$binsert = substr($seq2, $pos2[$i-1], $gapa);
		}
		if ($gapb > 0)
		{
			$bgap = &make_gaps($gapb);		
			$ainsert = substr($seq1, $pos1[$i-1], $gapb);
		}
		$sega .= "$agap$ainsert";
		$segb .= "$binsert$bgap";
		
		#end of bug fix.
		########################################################
		$sega .= $align1[$i];  
		push @posa, $pos1[$i];
		$segb .= $align2[$i];  
		push @posb, $pos2[$i];
	}
	else
	{
		if (@posa > 0)
		{
			
			print "$posa[0] $posa[$#posa] $posb[0] $posb[$#posb]\n";
			print "$code1\n";
			print "$sega\n";
			print "$code2\n";
			print "$segb\n";
			print OUT "$posa[0] $posa[$#posa] $posb[0] $posb[$#posb]\n";
			print OUT "$code1\n";
			print OUT "$sega\n";
			print OUT "$code2\n";
			print OUT "$segb\n";
			@posa = ();
			@posb = ();
			$sega = "";
			$segb = "";
		}
	}
}

#print out the last local alignment if necessary
if (@posa > 0)
{
	print "$posa[0] $posa[$#posa] $posb[0] $posb[$#posb]\n";
	print "$code1\n";
	print "$sega\n";
	print "$code2\n";
	print "$segb\n";
	print OUT "$posa[0] $posa[$#posa] $posb[0] $posb[$#posb]\n";
	print OUT "$code1\n";
	print OUT "$sega\n";
	print OUT "$code2\n";
	print OUT "$segb\n";
	@posa = ();
	@posb = ();
	$sega = "";
	$segb = "";
}
close OUT; 

`rm $out_file.pal`; 
