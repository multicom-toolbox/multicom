#!/usr/bin/perl -w
##########################################################################
#Generate prc alignment from an input file
#Input: input prc match file, output file name
#Output: the output file contains an alignment of two sequences
#Author: Jianlin Cheng
#Starte Date: 12/31/2009
##########################################################################

if (@ARGV != 2)
{
	die "need two parameters: input prc matched file, output alignment file"; 
}

$input_file = shift @ARGV; 

$output_file = shift @ARGV;

#read two sequences
open(INPUT, $input_file) || die "can't read $input_file.\n";
@inputs = <INPUT>;
close INPUT; 
$name1 = shift @inputs; ;
chomp $name1;
$seq1 = "";
while (@inputs)
{
	$line = shift @inputs; 
	chomp $line; 
	$seq1 .= $line;  	
	if ($inputs[0] =~ /^>/)
	{
		last;
	}
}
$name2 = shift @inputs; 
chomp $name2; 
$seq2 = "";
while (@inputs)
{
	$line = shift @inputs; 
	chomp $line; 
	$seq2 .= $line; 
}


@fragments_1 = ();
@fragment_lens_1 = ();

@fragments_2 = ();
@fragment_lens_2 = ();

#get fragments for the first sequence
$len1 = length($seq1);
$aa = substr($seq1, 0, 1); 
if ($aa =~ /[a-z]/)
{
	$prev_case = 0;
}
else
{
	$prev_case = 1; 
}
$fragment = ""; 
$match1 = 0; 
for ($i = 0; $i < $len1; $i++)
{
	$aa = substr($seq1, $i, 1); 
	if ($aa =~ /[a-z]/)
	{
		$curr_case = 0;
	}
	else
	{
		$curr_case = 1; 
		$match1++; 
	}
	if ($curr_case == $prev_case)
	{
		$fragment .= $aa; 
	}
	else
	{
		push @fragments_1, $fragment;
		push @fragment_lens_1, length($fragment);
		$fragment = $aa;
		$prev_case = $curr_case;
	}
	
	if ($i == $len1 - 1)
	{
		push @fragments_1, $fragment; 	
		push @fragment_lens_1, length($fragment);
	}
}


#get fragments for the second sequence
$len2 = length($seq2);
$aa = substr($seq2, 0, 1); 
if ($aa =~ /[a-z]/)
{
	$prev_case = 0;
}
else
{
	$prev_case = 1; 
}
$fragment = ""; 
$match2 = 0; 
for ($i = 0; $i < $len2; $i++)
{
	$aa = substr($seq2, $i, 1); 
	if ($aa =~ /[a-z]/)
	{
		$curr_case = 0;
	}
	else
	{
		$curr_case = 1; 
		$match2++; 
	}
	if ($curr_case == $prev_case)
	{
		$fragment .= $aa; 
	}
	else
	{
		push @fragments_2, $fragment;
		push @fragment_lens_2, length($fragment);
		$fragment = $aa;
		$prev_case = $curr_case;
	}
	
	if ($i == $len2 - 1)
	{
		push @fragments_2, $fragment; 	
		push @fragment_lens_2, length($fragment);
	}
}

#print "fragments 1:", join(" ", @fragments_1), "\n";
#print "fragments 2:", join(" ", @fragments_2), "\n";

$match1 == $match2 || die "The number of matching states in two alignments is not equal.\n";

$align1 = $align2 = ""; 

sub padding
{
	#add gaps to the second string which must be shorter than the first one
	#direction: -1: left, +1: right, 0: no direction
	my ($str1, $str2, $direction) = @_; 	
	my $len1 = length($str1);		
	my $len2 = length($str2);		
	
	$len1 - $len2 > 0 || die "the second string must be shorter.\n"; 

	for ($i = 1; $i <= $len1 - $len2; $i++)
	{
		if ($direction < 0)
		{
			$str2 = "-$str2";
		}
		else
		{
			$str2 .= "-"; 
		}
	}	
	return $str2; 
}

##########Match fragmetns##############################################
$prev_match_len = -1; 
while (@fragments_1 > 0 || @fragments_2 > 0)
{
	if (@fragments_1 == 0)
	{
		if (@fragments_2 == 1)
		{
			$frag2 = shift @fragments_2; 
			$frag1 = &padding($frag2, "", 0); 
			$align1 .= $frag1;
			$align2 .= $frag2; 
			last;
		}
		else
		{
			die "alignment does not match: @fragments_2.\n";
		}
	}

	if (@fragments_2 == 0)
	{
		if (@fragments_1 == 1)
		{
			$frag1 = shift @fragments_1; 
			$frag2 = &padding($frag1, "", 0); 
			$align1 .= $frag1;
			$align2 .= $frag2; 
			last;
		}
		else
		{
			die "alignment not match: @fragments_1.\n";
		}
	}


	$frag1 = $fragments_1[0];
	$frag2 = $fragments_2[0]; 	

	#get the case of two fragments (lower case: unaligned loops; upper case: match states)
	$case1 = 1; 
	$aa1 = substr($frag1, 0, 1);
	if ($aa1 =~ /[a-z]/)
	{
		$case1 = 0;
	}
	$case2 = 1; 
	$aa2 = substr($frag2, 0, 1);
	if ($aa2 =~ /[a-z]/)
	{
		$case2 = 0;
	}

	if ($case1 == 0 && $case2 == 0) #both are lower case, unalignalble regions 
	{
		if (length($frag1) > length($frag2))
		{
			if (@fragments_2 == 1) #last fragment
			{
				$frag2 = &padding($frag1, $frag2, +1);
			}
			elsif ($prev_match_len < length($fragments_2[1])) #move aa toward longer match fragments
			{
				$frag2 = &padding($frag1, $frag2, -1);
			}
			else
			{
				$frag2 = &padding($frag1, $frag2, 1);
			}
		}
		elsif (length($frag1) < length($frag2))
		{
			if (@fragments_1 == 1) #last fragment
			{
				$frag1 = &padding($frag2, $frag1, +1);
			}
			elsif ($prev_match_len < length($fragments_1[1]))
			{
				$frag1 = &padding($frag2, $frag1, -1); 
			}
			else
			{
				$frag1 = &padding($frag2, $frag1, 1); 
			}

		}
		$align1 .= $frag1;
		$align2 .= $frag2; 
		shift @fragments_1;
		shift @fragments_2;
	}  	
	elsif ($case1 == 0 && $case2 == 1) #(1) is loops, (2) is matched
	{
		$frag2 = &padding($frag1, "", 0);
		$align1 .= $frag1;
		$align2 .= $frag2; 
		shift @fragments_1; 	
	}
	elsif ($case1 == 1 && $case2 == 0) # (1) is match, (2) is loop
	{
		$frag1 = &padding($frag2, "", 0);
		$align1 .= $frag1;
		$align2 .= $frag2; 
		shift @fragments_2; 
	}
	else #both are matched regions
	{
		$num1 = length($frag1);
		$num2 = length($frag2);
		if ($num1 > $num2)
		{
			$beused = substr($frag1, 0, $num2);	
			$remain = substr($frag1, $num2, $num1 - $num2); 

			$align1 .= $beused;
			$align2 .= $frag2;
			
			$fragments_1[0] = $remain; 
			shift @fragments_2;			
			$prev_match_len = $num2;   
		}	
		elsif ($num1 < $num2)
		{
			$beused = substr($frag2, 0, $num1);	
			$remain = substr($frag2, $num1, $num2 - $num1); 
			$align1 .= $frag1; 	
			$align2 .= $beused; 
			shift @fragments_1; 
			$fragments_2[0] = $remain; 
			$prev_match_len = $num1; 
		}
		else
		{
			$align1 .= $frag1; 
			$align2 .= $frag2; 
			shift @fragments_1; 
			shift @fragments_2; 
			$prev_match_len = $num1; 
		}
		
	}

}

length($align1) == length($align2) || die "alignment length is not equal.\n";

$align1 = uc($align1);
$align2 = uc($align2);
open(OUTPUT, ">$output_file") || die "can't create file: $output_file.\n";
print OUTPUT "$name1\n$align1\n";
print OUTPUT "$name2\n$align2\n";
close OUTPUT; 



