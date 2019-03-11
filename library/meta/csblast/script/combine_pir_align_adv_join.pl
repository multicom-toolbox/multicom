#!/usr/bin/perl -w
##############################################################
#combine two pir alignments for the same query into one.
#Input: script dir, alignment file 1, alignment file 2, 
# minimum cover size, linker size, join max size, output file
#NOTICE: alignment file 2 contains at most 1 alignment.
#Modified from combine_pir_align_adv.pl
#Add one new function: join the fragments together in the template.
#join max size: <0: no join. >=0: join the fragments with gap size
#less or equal than join_max_size in both query and template.
#if join_max_size < 0: (work same as combine_pir_align_adv.pl)
#Author: Jianlin Cheng
#Date: 9/18/2005
###############################################################
if (@ARGV != 6 && @ARGV != 7)
{
	die "need 6 or 7 parameters: script dir, input pir file1, input pir file 2, min cover size(20), max linker size(10), join max size (optional:<0:no join;>=0:join), output file\n";
}
$param_num = @ARGV;

$script_dir = shift @ARGV;
-d $script_dir || die "can't read script dir.\n";

$pir_file1 = shift @ARGV;
open(PIR, $pir_file1) || die "can't read pir file:$pir_file1.\n";
@pir1 = <PIR>;
close PIR; 

$pir_file2 = shift @ARGV;
open(PIR, $pir_file2) || die "can't read pir file:$pir_file2.\n";
@pir2 = <PIR>;
close PIR; 

$min_cover_size = shift @ARGV;
$min_cover_size > 0 || die "minimum cover size must be bigger than 0.\n";

$max_linker_size = shift @ARGV; 
$max_linker_size >= 0 || die "max linker size can't be negative.\n"; 
if ($param_num == 7)
{
	$join_max_size = shift @ARGV;
}
else
{
	#not joining of fragments.
	$join_max_size = -1; 
}

$out_file = shift @ARGV;


#the last four lines are query
$qseq1 = pop @pir1;
#$qstx1 = pop @pir1;
pop @pir1;
$qtitle1 = pop @pir1;
#$qcom1 = pop @pir1; 
chomp $qtitle1;
pop @pir1; 

$qseq2 = pop @pir2;
$qstx2 = pop @pir2;
chomp $qstx2; 
$qtitle2 = pop @pir2;
chomp $qtitle2; 
$qcom2 = pop @pir2; 
chomp $qcom2; 

#$tcom2 = shift @pir2;
$tcom2 = shift @pir2; chomp $tcom2;
$ttitle2 = shift @pir2;
chomp $ttitle2;
$tstx2 = shift @pir2;
chomp $tstx2; 
$tseq2 = shift @pir2; 
chomp $tseq2;
chop $tseq2; 


#consistency checking.
$qtitle1  eq $qtitle2 || die "two alignment files belong to two different queries.$qtitle1 vs. $qtitle2,  stop.\n";

#strip the last \n and *
chomp $qseq1; 
chop $qseq1; 
chomp $qseq2; 
chop $qseq2; 
#chomp $tseq2;
#chop $tseq2; 

#consistence checking
$chk_seq1 = $qseq1;
$chk_seq1 =~ s/-//g;
$chk_seq2 = $qseq2;
$chk_seq2 =~ s/-//g;
$chk_seq1 eq $chk_seq2 || die "two query sequence is not equal.\n";

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

$length2 = length($qseq2);
@pos2 = ();
for ($i = 0; $i < $length2; $i++)
{
	if ( substr($qseq2, $i, 1) ne "-" ) 
	{
		push @pos2, $i;  
	}
}


#identify the useful regions that fill up the gaps in pir1. 
system("$script_dir/analyze_pir_align.pl $pir_file1 > $pir_file1.bit");
open(BIT, "$pir_file1.bit") || die "can't get bit cover string of $pir_file1\n";
$bits1 = <BIT>;
close BIT; 
chomp $bits1; 
`rm $pir_file1.bit`; 

system("$script_dir/analyze_pir_align.pl $pir_file2 > $pir_file2.bit");
open(BIT, "$pir_file2.bit") || die "can't get bit cover string of $pir_file2\n";
$bits2 = <BIT>;
close BIT; 
chomp $bits2; 
`rm $pir_file2.bit`; 

$bit_length = length($bits1); 
$bit_length == @pos1 || die "bit length doesn't match with query length 1($bit_length).\n";
$bit_length == @pos2 || die "bit length doesn't match with query length 2.\n";
$bit_length == length($bits2) || die "the lengths of two bit strings don't match.\n";

#record the newly filled positions by pir2
$new_bits = ""; 
for ($i = 0; $i < $bit_length; $i++)
{
	if (substr($bits1, $i, 1) eq "0" && substr($bits2, $i, 1) eq "1")
	{
		$new_bits .= "1"; 
	}
	else
	{
		$new_bits .= "0"; 
	}
}

#select regions(segments) that cover at least min_cover_gap.
$sel_bits = "";
$segment = ""; 
for ($i = 0; $i < length($new_bits); $i++)
{
	$bit = substr($new_bits, $i, 1); 	
	if ($bit eq "0")
	{
		if ($segment ne "")
		{
			if (length($segment) >= $min_cover_size)
			{
				$sel_bits .= $segment; 
			}
			else
			{
				#deselect this segment by set it to 0s.
				$segment =~ s/1/0/g;
				$sel_bits .= $segment; 
			}
			$segment = ""; 
		}

		$sel_bits .= "0";
	}
	else
	{
		$segment .= "1"; 
		if ($i == length($new_bits) - 1) #reach the end
		{
			if (length($segment) >= $min_cover_size)
			{
				$sel_bits .= $segment; 
			}
			else
			{
				$segment =~ s/1/0/g;
				$sel_bits .= $segment; 
			}
			$segment = ""; 
		}
	}
}

length($new_bits) == length($sel_bits) || die "length of selected bit string doesn't match.\n";

#map the selected bits into the template in pir 2.
for ($i = 0; $i < $length2; $i++)
{
	push @temp_bits, 0;
}
for ($i = 0; $i < length($sel_bits); $i++)
{
	if (substr($sel_bits, $i, 1) eq "1")
	{
		$position = $pos2[$i];
		$temp_bits[$position] = 1; 
	}
}

#record start and end index of each selected segments
#this will map back to the alignment and can create a series short 
#fragments than $min_cover_size.
@start = ();
@end = (); 
$state = 0; #not in cover region
for ($i = 0; $i < @temp_bits; $i++)
{
	if ($temp_bits[$i] == 0 && $state == 1)
	{
		push @end, $i - 1; 
		$state = 0; 
	}
	if ($temp_bits[$i] == 1)
	{
		if ($state == 0)
		{
			$state = 1; 
			push @start, $i; 
		}

		#process the last special case
		if ($i == $#temp_bits)
		{
			push @end, $#temp_bits;  
		}
	}
}

$num = @start;
$num == @end || die "number of start regions is not equal to number of end regions.\n";


###################################################################################################################
#join adjacent fragments if the distance between them is <= $join_max_size
if ($join_max_size >= 0 && $num > 0)
{
	#print "number of fragments: $num\n";
	@join_start = ();
	@join_end = ();
	push @join_start, $start[0];
	push @join_end, $end[0];
	#print "start: $start[0]\n";
	#print "end: $end[0]\n";
	for ($i = 1; $i < $num; $i++)
	{
		$start_pos = $start[$i];	
		$end_pos = $end[$i]; 
	#	print "start: $start[$i]\n";
	#	print "end: $end[$i]\n";
		$prev_end = $join_end[$#join_end];
		$inter_len = $start_pos - $prev_end - 1; 
		$inter_len >= 0 || die "intermediate length between two fragments is < 0. wrong. stop.\n";
		defined $start_pos || die "start pos is not defined.\n";
		defined $end_pos || die "end pos is not defined.\n";
		if ($inter_len <= $join_max_size)
		{
			#combine them and set new end
			$join_end[$#join_end] = $end_pos;
		}
		else
		{
			push @join_start, $start_pos;	
			push @join_end, $end_pos;
		}
	}
	@start = @join_start;
	@end = @join_end;

	$num = @start;
	#print "number of fragments after joining: $num\n";
}

##################################################################################################################


#extend start position for linkers 
for ($i = 0; $i < $num; $i++)
{
	$org = $start[$i];
	#print "org = $org\n";
	#<STDIN>;
	$ext = 0;
	for ($j = 1; $j <= $max_linker_size; $j++)
	{
		if ($org - $j >= 0)
		{
			if (substr($qseq2, $org - $j, 1) ne "-" && substr($tseq2, $org - $j, 1) ne "-")
			{
				$ext++;
			}
			else
			{
				last;
			}
		}
	}
	$start[$i] = $org - $ext;
}

#extend end position for linkers
for ($i = 0; $i < $num; $i++)
{
	$org = $end[$i];
	$ext = 0;
	for ($j = 1; $j <= $max_linker_size; $j++)
	{
		if ( $org + $j < length($qseq2) ) 
		{
			if (substr($qseq2, $org + $j, 1) ne "-" && substr($tseq2, $org + $j, 1) ne "-")
			{
				$ext++;
			}
			else
			{
				last;
			}
		}
	}
	$end[$i] = $org + $ext;
}


#join and combine regions if not gap separate them.
for ($i = 0; $i < $length2; $i++)
{
	push @temp_bits, 0;
}
for ($i = 0; $i < $num; $i++)
{
	$a = $start[$i];
	$b = $end[$i];
	for ($j = $a; $j <= $b; $j++)
	{
		$temp_bits[$j] = 1; 
	}
}
#recompute the start/end positions 
@start = ();
@end = (); 
$state = 0; #not in cover region
for ($i = 0; $i < @temp_bits; $i++)
{
	if ($temp_bits[$i] == 0 && $state == 1)
	{
		push @end, $i - 1; 
		$state = 0; 
	}
	if ($temp_bits[$i] == 1 )
	{
		if ($state == 0)
		{
			$state = 1; 
			push @start, $i; 
		}

		#process the last special case
		if ($i == $#temp_bits)
		{
			push @end, $#temp_bits;  
		}
	}
}
$num = @start;
$num == @end || die "number of start regions is not equal to number of end regions.\n";


#generate one pir alignment for each region

sub make_bits
{
	my $size = $_[0];
	my $gap = "";
        for (my $i = 0; $i < $size; $i++)
        {
               $gap .= "-";
        }
        return $gap;
}

`cp $pir_file1 $out_file 2>/dev/null`; 
for ($i = 0; $i < $num; $i++)
{
	$a = $start[$i];
	$b = $end[$i];

	#skip the short fragments (gapped short fragments)
	#ideally, this short fragments may be joined 
	if ($b - $a < $min_cover_size)
	{
		next; 
	}

	$qleft = "";
	$qright = "";
	$qsel = substr($qseq2, $a, $b - $a + 1);
	if ($a > 0)
	{
		$qleft = substr($qseq2, 0, $a);
	}
	if ($b < length($qseq2) - 1)
	{
		$qright = substr($qseq2, $b+1, length($qseq2) - $b - 1);
	}
	$qleft =~ s/-//g;
	$qright =~ s/-//g;
	$new_qseq = $qleft . $qsel . $qright;

	$tsel = substr($tseq2, $a, $b - $a + 1);
	$tleft = $qleft;
	$tleft =~ s/./-/g;
	$tright = $qright;
	$tright =~ s/./-/g;
	$new_tseq = $tleft . $tsel . $tright;

	#generate title and index in stx information
	$new_title = $ttitle2; 
	if ($num > 1)
	{
		$idx = $i + 1; 
		$new_title .= "$idx";
	}

	@stx_info = split(/:/,$tstx2); #2, 4 are stx indices  
	$org_stx_start = $stx_info[2];  
	$org_stx_end = $stx_info[4];  

	$offset = 0; 
	for ($j = 0; $j < $a; $j++)
	{
		if (substr($tseq2, $j, 1) ne "-")
		{
			$offset++; 
		}
	}
	$new_stx_start = $org_stx_start + $offset;

	$offset = 0; 
	for ($j = $b+1; $j < length($tseq2); $j++)
	{
		if (substr($tseq2, $j, 1) ne "-")
		{
			$offset++; 
		}
	}
	$new_stx_end = $org_stx_end - $offset; 
	#print "seq: \n$tseq2\n";
	#print "off: $offset\n";

	#################################################################################
	#now we allow gaps between $a and $b, so we need to recompute non-gap length 
	#
	$non_gap = 0; 
	for ($j = $a; $j <= $b; $j++)
	{
		if (substr($tseq2, $j, 1) ne "-")
		{
			$non_gap++; 
		}
	}
	################################################################################

	if ( $non_gap != $new_stx_end - $new_stx_start + 1 )
	{
		warn "error on combining $pir_file2\n";
		$stx_len = $new_stx_end - $new_stx_start + 1;
		$seq_len = $non_gap;  

		warn "org stx start=$org_stx_start  org stx end = $org_stx_end\n";
		warn "stx start=$new_stx_start stx end = $new_stx_end\n";
		warn "seq start = $a  seq end = $b (may have gap between them)\n";
		die "structure regions is not euqal to sequence regions ($seq_len != $stx_len).\n";
	}
	$stx_info[2]= $new_stx_start;
	$stx_info[4]= $new_stx_end;

	$new_stx_info = join(":", @stx_info);

	open(OUT, ">$out_file.tmp") || die "can't create combined alignment file.\n";
	print OUT "C;template; advanced alignment combination (original info = $tcom2)\n";
	print OUT "$new_title\n";
	print OUT "$new_stx_info\n";
	print OUT "$new_tseq*\n\n";
	print OUT "$qcom2\n"; 
	print OUT "$qtitle2\n";
	print OUT "$qstx2\n";
	print OUT "$new_qseq*\n";
	close OUT; 

	#combine with pir1;
	system("$script_dir/combine_pir_align.pl $out_file $out_file.tmp $out_file"); 
}
`rm $out_file.tmp 2>/dev/null`;


