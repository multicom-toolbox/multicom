#!/usr/bin/perl -w
########################################################################
#Sort blast local alignment file, considering blast evalue, resolution,
#match ratio, and stx determination methods
#Input: blast local alignment file, stx info file, evalue ratio (5), deta resolution, output file
#evalue ratio: only if ratio < evalue ratio, we consider exchange
#the order of two considering other information. smaller, more conservative
#delta resolution: only if resolution diff > delta res, consider exchange.
#Author: Jianlin Cheng
#Date: 11/11/2005
########################################################################

#compute ratio of two evalue
#different format: 0.####, e-####, #e-#### 
#return ratio
sub comp_evalue_ratio
{
	my ($a, $b) = @_;
	#get format of the evalue
	my $formata = $formatb = "";
	my $a_prev = 0;
	my $a_next = 0;
	my $b_prev = 0;
	my $b_next = 0;

	if ( $a =~ /^[\d\.]+$/ )
	{
		$formata = "num";
	}
	elsif ($a =~ /^([\d]*)e(-\d+)$/)
	{
		$formata = "exp";
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
		if ($a_next >= 0)
		{
			die "exponent must be negative: $a\n"; 
		}
		$a = $a_prev * (10 ** $a_next)
	}
	else
	{
		die "evalue format error: $a";	
	}

	if ( $b =~ /^[\d\.]+$/ )
	{
		$formatb = "num";
	}
	elsif ($b =~ /^([\d]*)e(-\d+)$/)
	{
		$formatb = "exp";
		$b_prev = $1;
		$b_next = $2;  
		if ($1 eq "")
		{
			$b_prev = 1; 
		}
		if ($b_next >= 0)
		{
			die "exponent must be negative: $b\n"; 
		}
		$b = $b_prev * (10**$b_next); 
	}
	else
	{
		die "evalue format error: $b";	
	}

	if ($b == 0)
	{
		if ($a == 0)
		{
			return 1; 
		}
		else
		{
			return 1000000; 
		}
	}
	else
	{
		return $a / $b; 
	}

}

if (@ARGV != 5)
{
	die "need 5 parameters: blast local file, stx info file, evalue ratio (5), delta resolution(2), output file.\n";
}
$rank_file = shift @ARGV;
$stx_info_file = shift @ARGV;
$evalue_ratio = shift @ARGV;
$evalue_ratio > 1 || die "evalue ratio must > 1.\n";
$delta_reso = shift @ARGV;
$delta_reso > 0 || die "delta resolution must be bigger than 0.\n";
$out_file = shift @ARGV;

#compare the rank of two templates (a, b).
#return 1: a > b (a must be ranked before b); 0: a < b
sub compare_rank
{
	my ($evalue1, $res1, $match1, $stx_method1, $evalue2, $res2, $match2, $stx_method2) = @_; 

	defined $evalue_ratio || die "delta rank is not defined. stop sorting.\n";
	defined $delta_reso || die "delta resolution is not defined. stop sorting.\n";

	my $ratio = &comp_evalue_ratio($evalue1, $evalue2);

	if ($ratio < 1 / $evalue_ratio)
	{
		return 1; 
	}
	elsif ($ratio < 1)
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
	elsif ($ratio == 1)
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
	elsif ($ratio < $evalue_ratio) 
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
	else 
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

#read local alignment file
open(RANK, $rank_file) || die "can't read rank file: $rank_file\n";
$rank_title = <RANK>;
@ranks = <RANK>;
close RANK;

if (@ranks <= 5)
{
	`cp $rank_file $out_file`; 	
	die "less than two local alignments. exit by making a copy.\n";
}

@local_list = ();
while (@ranks)
{
	#shift the blank line
	shift @ranks;
	$line1 = shift @ranks;
	$line2 = shift @ranks;
	$line3 = shift @ranks;
	$line4 = shift @ranks;

	@fields = split(/\s+/, $line1);
	$code = $fields[0];
	$evalue = $fields[3]; 

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
	push @local_list, {
		code => $code,
		rvalue => $evalue,
		reso => $reso,
		match => $match,
		method => $method,
		line1 => $line1,
		line2 => $line2,
		line3 => $line3,
		line4 => $line4
	}
}

$last = @local_list - 1; 

for ($i = $last; $i > 0 ; $i--)
{
	for ($j = 0; $j < $i; $j++)
	{
		$curr = $local_list[$j];
		$next = $local_list[$j+1];

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
			$local_list[$j] = $next;
			$local_list[$j+1] = $curr;
		}
	}
}

#output the sorted list
open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT $rank_title;
for ($i = 0; $i < @local_list; $i++)
{
	print OUT "\n";
	print OUT $local_list[$i]{"line1"};
	print OUT $local_list[$i]{"line2"};
	print OUT $local_list[$i]{"line3"};
	print OUT $local_list[$i]{"line4"};
}
close OUT;
