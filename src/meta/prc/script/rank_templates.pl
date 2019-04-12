#!/usr/bin/perl -w
###############################################################
#report the top models (ranked by e-value) given a score file
#generate by sam
#Inputs: input score file, output file
#Author: Jianlin Cheng
#Date: 12/14/2009
############################################################### 
#return: -1: less, 0: equal, 1: more
sub comp_evalue
{
	my ($a, $b) = @_;
	#get format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		$formata = "num";
	}
	elsif ($a =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formata = "exp";
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
	#	if ($a_next > 0)
#		{
	#		die "exponent must be negative or 0: $a\n"; 
#		}
	}
	else
	{
		die "evalue format error: $a";	
	}

	if ( $b =~ /^[\d\.]+$/ )
	{
		$formatb = "num";
	}
	elsif ($b =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formatb = "exp";
		$b_prev = $1;
		$b_next = $2;  
		if ($1 eq "")
		{
			$b_prev = 1; 
		}
	#	if ($b_next > 0)
	#	{
	#		die "exponent must be negative or 0: $b\n"; 
	#	}
	}
	else
	{
		die "evalue format error: $b";	
	}
	if ($formata eq "num")
	{
		if ($formatb eq "num")
		{
			return $a <=> $b
		}
		else  #bug here
		{
			#a is bigger
			#return 1; 	
			#return $a <=> $b_prev * (10**$b_next); 
			return $a <=> $b_prev * (2.72**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			#return -1; 
			#return $a_prev * (10 ** $a_next) <=> $b; 
			return $a_prev * (2.72 ** $a_next) <=> $b; 
		}
		else
		{
			if ($a_next < $b_next)
			{
				#a is smaller
				return -1; 
			}
			elsif ($a_next > $b_next)
			{
				return 1; 
			}
			else
			{
				return $a_prev <=> $b_prev; 
			}
		}
	}
}
########################End of compare evalue################################
if (@ARGV != 2)
{
	die "need two parameters: input sam scoring file, output file\n";
}

$score_file = shift @ARGV;
$out_file = shift @ARGV;

if (! open(DIST, "$score_file"))
{
	die "can't open sam scoring file: $score_file.\n";
}
@dist = <DIST>;
close DIST;
while (@dist)
{
	$line = shift @dist;
	if ($line =~ /^\# hmm1/)
	{
		last;
	}
}

while (@dist)
{
	$score = shift @dist;
	if ($score =~ /^\#\s+END/)
	{
		last;
	}
	chomp $score;
	@fields = split(/\s+/, $score);
	$evalue = $fields[12];	
					
	if ($evalue =~ /nan/)
	{
		warn "$fields[0] evalue is nan\n";
		next;
	}

	push @evalues, $evalue;

	push @sel_models, $fields[5];
}	
			
############################################################################
#sort templates by evalue (not necessary since templates have been ranked?)
if (0)
{

$num = @evalues;
for ($m = $num - 1; $m > 0; $m--)
{
	for ($n = 0; $n < $m; $n++)
	{
		if (&comp_evalue($evalues[$n], $evalues[$n+1]) == 1)
		{

			$value = $evalues[$n];
			$evalues[$n] = $evalues[$n+1];
			$evalues[$n+1] = $value;

			$value = $sel_models[$n];
			$sel_models[$n] = $sel_models[$n+1];
			$sel_models[$n+1] = $value;
		}	

	}
}
}
###############################################################################

open(OUT, ">$out_file");

print OUT "Ranked templates for $score_file\n";
for ($m = 0; $m < @evalues; $m++)
{
	print OUT $m+1, "\t", $sel_models[$m], "\t", "$evalues[$m]", "\n";
}

close OUT; 





