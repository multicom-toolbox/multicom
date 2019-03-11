#!/usr/bin/perl -w
##############################################################
#combine two pir alignments for the same query into one.
#Input: alignment file 1, alignment file 2, output file
#Author: Jianlin Cheng
#Date: 8/30/2005
###############################################################
if (@ARGV != 3)
{
	die "need 3 parameter: input pir file1, input pir file 2, output file\n";
}
$pir_file1 = shift @ARGV;
open(PIR, $pir_file1) || die "can't read pir file.\n";
@pir1 = <PIR>;
close PIR; 

$pir_file2 = shift @ARGV;
open(PIR, $pir_file2) || die "can't read pir file.\n";
@pir2 = <PIR>;
close PIR; 

$out_file = shift @ARGV;


#the last four lines are query
$qseq1 = pop @pir1;
$qstx1 = pop @pir1;
$qtitle1 = pop @pir1;
$qcom1 = pop @pir1; 

if (length($qseq1) <= 1)
{
	die "qseq1 is empty.\n";
}

$qseq2 = pop @pir2;
pop @pir2;
$qtitle2 = pop @pir2;
pop @pir2; 

if (length($qseq2) <= 1)
{
	die "qseq2 is empty.\n";
}

#consistency checking.
#print "$qtitle1";
#print "$qtitle2";
$qtitle1  eq $qtitle2 || die "two alignment files belong to two different queries. stop.\n";

#strip the last \n and *
chomp $qseq1; 
chop $qseq1; 
chomp $qseq2; 
chop $qseq2; 


#pos is used to record the indices of aa in query alignments
$length1 = length($qseq1);
@pos1 = ();
for ($i = 0; $i < $length1; $i++)
{
	if ( substr($qseq1, $i, 1) ne "-" ) 
	{
		push @pos1, $i;  
	}
}
#add a virtual end position
push @pos1, $length1; 

$length2 = length($qseq2);
@pos2 = ();
for ($i = 0; $i < $length2; $i++)
{
	if ( substr($qseq2, $i, 1) ne "-" ) 
	{
		push @pos2, $i;  
	}
}
push @pos2, $length2; 

#compute the distance(gap) between two adjacent residues
#gap array include gaps before each residue and after the last one(before the virtual end)
@gaps1 = ();
$prev = -1;
$size = @pos1; 
for ($i = 0; $i < $size; $i++)
{
	$gaps1[$i] = $pos1[$i] - $prev;	
	$prev = $pos1[$i]; 
}

@gaps2 = ();
$prev = -1;
$size == @pos2 || die "query 2's length doesn't match with query 1\n"; 
for ($i = 0; $i < $size; $i++)
{
	$gaps2[$i] = $pos2[$i] - $prev;	
	$prev = $pos2[$i]; 
}
#$gaps2[$size] = $length2 - $pos2[$size-1];   

#compare gasp to check where to add more gaps
@add1 = ();
@add2 = (); 
for ($i = 0; $i < $size; $i++)
{
	if ($gaps1[$i] > $gaps2[$i])
	{
		$add2[$i] = $gaps1[$i] - $gaps2[$i]; 
		$add1[$i] = 0; 
	}
	elsif ($gaps1[$i] < $gaps2[$i])
	{
		$add1[$i] = $gaps2[$i] - $gaps1[$i]; 
		$add2[$i] = 0; 
	}
	else
	{
		$add1[$i] = 0; 
		$add2[$i] = 0; 
	}
}

#function to make a gap with specified size
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

#insert a gap before an index for a string
sub insert_gap
{
	my ($org, $idx, $gap) = @_; 
	my $len = length($org);
	if ($idx < 0 || $idx > $len)
	{
		print "org = $org\n";
		print "idx=$idx\n";
		 die "input index is out of bounary of string.\n";
	}
	my $first = ""; 
	my $end = ""; 
	if ($idx == 0)
	{
		$first = "";
		$end = $org;
	}
	elsif ($idx == $len)
	{
		$first = $org;
		$end = ""; 
	}
	else
	{
		$first = substr($org, 0, $idx);
		$end = substr($org, $idx); 
	}
	return $first . $gap . $end; 
}


#change the sequences in templates 

@pir1 % 5 == 0 || die "number of alignes in pir file 1 is not correct.\n";
@pir2 % 5 == 0 || die "number of alignes in pir file 2 is not correct.\n";

for ($i = 1; $i <= @pir1; $i++)
{
	if ($i % 5 == 0)
	{
		$tseq = $pir1[$i-2]; 
		#print "$tseq\n";
		#<STDIN>;
		$acc = 0; 
		for ($j = 0; $j < @pos1; $j++)
		{
			$pos = $pos1[$j];
			$num = $add1[$j]; 
			if ($num > 0)
			{
				$chd = $acc + $pos;	
				$gap = &make_gaps($num); 
				$tseq = &insert_gap($tseq, $chd, $gap);
				$acc += $num;
			}
		}
		$pir1[$i-2] = $tseq;
	}
}

for ($i = 1; $i <= @pir2; $i++)
{
	if ($i % 5 == 0)
	{
		$tseq = $pir2[$i-2]; 
		$acc = 0; 
		for ($j = 0; $j < @pos2; $j++)
		{
			$pos = $pos2[$j];
			$num = $add2[$j]; 
			if ($num > 0)
			{
				$chd = $acc + $pos;	
				$gap = &make_gaps($num); 
				$tseq = &insert_gap($tseq, $chd, $gap);
				$acc += $num;
			}
		}
		$pir2[$i-2] = $tseq;
	}
}

#change query
$acc = 0; 
for ($j = 0; $j < @pos1; $j++)
{
	$pos = $pos1[$j];
	$num = $add1[$j]; 
	if ($num > 0)
	{
		$chd = $acc + $pos;	
		$gap = &make_gaps($num); 
		$qseq1 = &insert_gap($qseq1, $chd, $gap);
		$acc += $num;
	}
}

#change query
$acc = 0; 
for ($j = 0; $j < @pos2; $j++)
{
	$pos = $pos2[$j];
	$num = $add2[$j]; 
	if ($num > 0)
	{
		$chd = $acc + $pos;	
		$gap = &make_gaps($num); 
		$qseq2 = &insert_gap($qseq2, $chd, $gap);
		$acc += $num;
	}
}

#query 1 == $query 2
$qseq1 eq $qseq2 || die "after change, query 1 is not equal to the query 2. \n";

open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT  join("", @pir1);
print OUT  join("", @pir2);
print OUT $qcom1;
print OUT $qtitle1;
print OUT $qstx1;
print OUT "$qseq1*\n";

close OUT; 
