#!/usr/bin/perl -w
########################################################################
#Sort SVM template ranking file, considering svm-value, resolution,
#match ratio, and stx determination methods
#Input: svm rank file, stx info file, delta rank (0.1), deta resolution, output file
#delta rank: only if rank difference < delta rank, we consider exchange
#the order of two considering other information. smaller, more conservative
#delta resolution: only if resolution diff > delta res, consider exchange.
#Author: Jianlin Cheng
#Date: 11/11/2005
########################################################################

if (@ARGV != 5)
{
	die "need 5 parameters: svm rank file, stx info file, delta rank (0.1), delta resolution(2), output file.\n";
}
$rank_file = shift @ARGV;
$stx_info_file = shift @ARGV;
$delta_rank = shift @ARGV;
$delta_rank > 0 || die "delta rank must be bigger than 0.\n";
$delta_reso = shift @ARGV;
$delta_reso > 0 || die "delta resolution must be bigger than 0.\n";
$out_file = shift @ARGV;

#compare the rank of two templates (a, b).
#return 1: a > b (a must be ranked before b); 0: a < b
sub compare_rank
{
	my ($rank1, $res1, $match1, $stx_method1, $rank2, $res2, $match2, $stx_method2) = @_; 

	defined $delta_rank || die "delta rank is not defined. stop sorting.\n";
	defined $delta_reso || die "delta resolution is not defined. stop sorting.\n";

	#in this case, we always choose positive.
	if ($rank1 > 0 && $rank2 < 0)
	{
		return 1; 
	}
	if ($rank1 < 0 && $rank2 > 0)
	{
		return 0; 
	}

	if ($rank1 - $rank2 > $delta_rank)
	{
		return 1; 
	}
	elsif ($rank1 - $rank2 > 0)
	{
		if ($res1 - $res2 < $delta_reso)
		{
			return 1; 	
		}
		else
		{
			return 0; 
		}
	}
	elsif ($rank1 - $rank2 == 0)
	{
		if ($res1 < $res2)
		{
			return 1; 
		}
		elsif ($res1 == $res2)
		{
			if ($match1 > $match2)
			{
				return 1; 
			}
			elsif ($match1 == $match2)
			{
				if ($stx_method1 eq "X")
				{
					return 1; 
				}
				elsif ($stx_method2 eq "O")
				{
					return 1;
				}
				else
				{
					return 0; 
				}
			}
			else
			{
				return 0; 
			}
		}
		else
		{
			return 0; 
		}
	}
	elsif ($rank2 - $rank1 < $delta_rank) #equivalent to: $rank1 - $rank2 > -$delta_rank
	{
		if ($res2 - $res1 < $delta_reso)
		{
			return 0; 	
		}
		else
		{
			return 1; 
		}
	}
	else #in case, no. 2 has much higer rank value than no. 1
	{
		return 0; 
	}
}

#read stx information file
open(INFO, $stx_info_file) || die "can't read stx information file.\n";
%map_reso = ();
%map_match = ();
$map_method = ();
while (<INFO>)
{
	$line = $_;
	chomp $line;
	($code, $reso, $match, $method) = split(/\s+/, $line);
	$map_reso{$code} = $reso;
	$map_match{$code} = $match;
	$map_method{$code} = $method;
}
close INFO;

#read svm rank file
open(RANK, $rank_file) || die "can't read rank file: $rank_file\n";
$rank_title = <RANK>;
@ranks = <RANK>;
close RANK;

@fields = split(/\s+/, $rank_title); 
$size = pop @fields;


@svm_list = ();
while (@ranks)
{
	$line = shift @ranks;
	chomp $line;
	$no = "";
	($no, $code, $rvalue) = split(/\s+/, $line);
	$reso = $map_reso{$code};
	if (! defined $reso)
	{
		`cp $rank_file $out_file`;
		die "resolution is not found for $code. exit by making a copy.\n";
	}
	$match = $map_match{$code};
	if (! defined $match)
	{
		`cp $rank_file $out_file`;
		die "match ratio is not found for $code. exit by making a copy.\n";
	}
	$method = $map_method{$code};
	if (! defined $method)
	{
		`cp $rank_file $out_file`;
		die "structure determination method is not found for $code. exit by making a copy.\n";
	}
	push @svm_list, {
		code => $code,
		rvalue => $rvalue,
		reso => $reso,
		match => $match,
		method => $method
	}
}

#resort the list using bubble sort
if ($size != @svm_list)
{
	`cp $rank_file $out_file`;
	die "the size of rank list doesn't match. exit by making a copy.\n"; 
}

$last = $size - 1; 

#sort the top 100 entries only
if ($last > 99)
{
	$last = 99; 
}

for ($i = $last; $i > 0 ; $i--)
{
	for ($j = 0; $j < $i; $j++)
	{
		$curr = $svm_list[$j];
		$next = $svm_list[$j+1];

		#compare them
		$rank1 = $curr->{"rvalue"};
		$reso1 = $curr->{"reso"};
		$match1 = $curr->{"match"};
		$stx_method1 = $curr->{"method"};

		$rank2 = $next->{"rvalue"};
		$reso2 = $next->{"reso"};
		$match2 = $next->{"match"};
		$stx_method2 = $next->{"method"};

		$res = &compare_rank($rank1, $reso1, $match1, $stx_method1, $rank2, $reso2, $match2, $stx_method2); 
		if ($res == 0)  #curr > next
		{
			#exchange curr and next 
			$svm_list[$j] = $next;
			$svm_list[$j+1] = $curr;
		}
	}
}

#output the sorted list
open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT $rank_title;
for ($i = 0; $i < $size; $i++)
{
	$idx = $i + 1;
	print OUT "$idx\t";  
	print OUT $svm_list[$i]{"code"};
	print OUT "\t";
	print OUT $svm_list[$i]{"rvalue"};
	print OUT "\n";
}
close OUT;
