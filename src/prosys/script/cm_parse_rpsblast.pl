#!/usr/bin/perl -w
##############################################################
#Parse the output from blast(gapped blast, psi-blast)
#Input: blast output file
#Output: A list of significant alignments from blast
#Parameters: input file, output file
#Output format: line 1: target name(query), length, database, 
# and total seq num in database.
#For each alignment(separated by blank line): template name, 
#length, score, E value, 
#alignment length, identitities(rate, num), positives(rate, number),
#gaps(rate, num), 
# type(gapped-blast, psi-blast-no-nr, psi-blast-nr);
# Range: q_start, q_end, Sub_start, sub_end; seq1, seq2 
# If no significant alignments are found, just first two lines.
#Author: Jianlin Cheng
#Date: 4/12/2005
#Modified from cm_parse_blast.pl, 5/9/2005 to parse rps_blast results
#
#bug fix: 09/05/2005: fix evalue comparison to handle 0 evalue
###############################################################

##########################################################################
#for the same alingmnet(every thins is same except for e-value)
#appears more than once in more than one round
#only the last one (lower evalue) is retained.
##########################################################################

######################################################################
#format of blast file:
#line 9: Query= name
#line 10: (num letters)
#line 12: database name
#line 13: num sequence, other (, in numbers need to be removed)
#Results from round # (get round information) from psi-blast) (for psi-blast only)
#for each alignment: 
#>temp_name (starting of each alignment)
#	Length = ####
# Score = ##.# bits (??), Expect = #.#### or #e-##
# Identities = ##/align_length (rate), Positives..., Gaps...
#Query:start ................ end
#Sbjct: start ............... end
#Repeat: here we need to check consistency. 
#########################################################################
sub round
{
       my $value = $_[0];
       $value *= 100;
       $value = int($value + 0.5);
       $value /= 100;
       return $value;
}

#compare evalue
#different format: 0.####, e-####, #e-#### 
#return: -1: less, 0: equal, 1: more
sub comp_evalue
{
	my ($a, $b) = @_;
	#get format of the evalue
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
		else
		{
			#a is bigger
			return $a <=> $b_prev * (10**$b_next); 
			#return 1; 	
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			return $a_prev * (10 ** $a_next) <=> $b; 
			#return -1; 
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


if (@ARGV != 2)
{
	die "need two parameters: input blast file, output local alignmnet file.\n";
}
$blast_file = shift @ARGV;
$align_file = shift @ARGV;

open(BLAST, $blast_file) || die "can't read blast file.\n";
@blast = <BLAST>;
close BLAST;

open(ALIGN, ">$align_file") || die "can't create output file.\n";

#check the format
$title = $blast[0];
if ($title !~ /RPS-BLAST/)
{
	die "blast file format error.\n"; 
}

$new_version = 0;

if ($title =~ /2\.2\.17/)
{
	$new_version = 1;
	shift @blast;
	shift @blast;
	shift @blast;
	shift @blast;
	shift @blast;
}

#gather query and database information
$query = $blast[2];
chomp $query;
$query =~ /^Query= (\S+)$/ || die "foramt error, can't find query name.\n";
#($token, $query_name) = split(/\s+/, $query);
$query_name = $1; 
$query_length = $blast[3]; 
if ( $query_length =~ /^\s+\((\d+) letters\)/ )
{
	$query_length = $1; 
}
else
{
	die "can't find query length:$query_length"; 
}
print ALIGN "$query_name $query_length\n\n"; 

#table is used to hold all local aligments found by blast
@table = (); 
while (@blast)
{
	$line = shift @blast;
	chomp $line; 
	if ($line =~ /^>(.+)/)
	{
		$temp_name = $1; 
		$temp_len = shift @blast;
		chomp $temp_len;
		if ($temp_len =~ /\s+Length = (\d+)$/)
		{
			$temp_len = $1; 	
		}
		else
		{
			die "length format error at: $temp_name.\n";
		}
		shift @blast;
		$score_exp = shift @blast;
		chomp $score_exp;
		if ($score_exp =~ /Score =\s+([\d\.]+) bits.+Expect =\s+(\S+)/)
		{
			$score = $1;
			$expe = $2; 
		}
		else
		{
			die "score expectation error: $score_exp\n";
		}
		$int_pos_gap = shift @blast;
		chomp $int_pos_gap; 
		#1: int 2:align_len 3:int_rate 4:pos 5:align_len 6:pos_rate 7:gap 8:align_len 9: gap_rate
		if ($int_pos_gap =~ /Identities = (\d+)\/(\d+) \((\d+)%\), Positives = (\d+)\/(\d+) \((\d+)%\), Gaps = (\d+)\/(\d+) \((\d+)%\)/)
		{
			if ($2 != $5 || $2 != $8)
			{
				die "alignment length doesn't match: $temp_name\n"; 
			}
			$align_len = $2;  #including gap
			#$align_int = $1;
			$align_int_rate = $3/100;
			#$align_pos = $4;
			$align_pos_rate = $6/100;
			#$align_gap = $7;
			$align_gap_rate = $9/100; 
		}
		#no gap case
		elsif ($int_pos_gap =~ /Identities = (\d+)\/(\d+) \((\d+)%\), Positives = (\d+)\/(\d+) \((\d+)%\)/)
		{
			if ($2 != $5)
			{
				die "alignment length doesn't match: $temp_name\n"; 
			}
			$align_len = $2;  #including gap
			#$align_int = $1;
			$align_int_rate = $3/100;
			#$align_pos = $4;
			$align_pos_rate = $6/100;
			#$align_gap = $7;
			$align_gap_rate = 0; 
	
		}
		else
		{
			die "indentity, positive, gaps wrong:$temp_name.\n"; 
		}
		shift @blast;
		#two consective empty lines mean "end" 
		$query_start = 100000;
		$query_end = 0;
		$sub_start = 100000;
		$sub_end = 0; 
		$align_query = "";
		$align_sub = ""; 
		while (@blast)
		{
			$seg_query = shift @blast;
			#print "line: $seg_query\n";
			#<STDIN>;
			chomp $seg_query;
			
			if ($seg_query eq "")
			{
				#done with this alignment
				if ($align_len != length($align_query) || $align_len != length($align_sub))
				{
					die "alignment length not consistent: $temp_name\n"; 
				}
				if ($query_end < $query_start || $sub_end < $sub_start ||
				$query_end > $query_length || $sub_end > $temp_len)
				{
					die "alignment range is out of bondary:$temp_name\n";
				}
				#output
				$entry = "$temp_name\t$temp_len\t$score\t$expe\t$align_len\t";
				$entry .= "$align_int_rate\t$align_pos_rate\t$align_gap_rate\n"; 
				$entry .= "$query_start\t$query_end\t$sub_start\t$sub_end\n"; 
				$entry .= "$align_query\n";
				$entry .= "$align_sub\n";
				push @table, $entry; 
				last;
			}
			if ($seg_query =~ /^Query: (\d+)\s+(\S+)\s+(\d+)$/)
			{
				$start = $1;
				$segment = $2;
				$end = $3; 
				$align_query .= $segment;
				if ($start < $query_start)
				{
					$query_start = $start;
				}
				if ($end > $query_end)
				{
					$query_end = $end; 
				}
			}
			else
			{
				die "alignment error(query): $seg_query\n"; 
			}
			shift @blast;
			$seg_sub = shift @blast;
			chomp $seg_sub; 
			if ($seg_sub =~ /^Sbjct: (\d+)\s+(\S+)\s+(\d+)$/)
			{
				$start = $1;
				$segment = $2;
				$end = $3; 
				$align_sub .= $segment;
				if ($start < $sub_start)
				{
					$sub_start = $start;
				}
				if ($end > $sub_end)
				{
					$sub_end = $end; 
				}
			}
			else
			{
				die "alignment error(template): $seg_sub\n"; 
			}
			#shift out the empty line at the end of each entry
			shift @blast;
		}

	}
}

#remove redundancy
@uniq = ();
$num = 0; 
foreach $entry (@table)
{
	$found = 0; 
	@values1 = split(/\s+/, $entry);
	$evalue1 = $values1[3]; 
	$values1[2] = ""; 
	$values1[3] = ""; 
	$temp1 = join("", @values1); 

	for ($i = 0; $i < @uniq; $i++)
	{
		@values2 = split(/\s+/, $uniq[$i]);
		$evalue2 = $values2[3];
		$values2[2] = ""; 
		$values2[3] = ""; 
		$temp2 = join("", @values2); 

		#everything is the same except for e-value
		if ($temp1 eq $temp2)
		{
			if ( &comp_evalue($evalue1, $evalue2) < 0)
			{
				#replace it
				$uniq[$i] = $entry; 
				$num++; 
			}
			$found = 1; 
			last;
		}
	}
	if ($found == 0)
	{
		push @uniq, $entry; 
	}
}

#sort the alignments by e-value or length or identity
#here we sort them by evalues
#using selection sorting
$size = @uniq; 
for ($i = 0; $i < $size; $i++)
{
	$idx = $i; 
	@values = split(/\s+/, $uniq[$i]);
	$evalue = $values[3];

	for ($j = $i + 1; $j < $size; $j++)
	{
		@values = split(/\s+/, $uniq[$j]);
		$value = $values[3];
		if (&comp_evalue($value, $evalue) < 0)
		{
			$idx = $j;
			$evalue = $value
		}
	}
	#exchange entry
	if ($idx != $i)
	{
		$temp = $uniq[$i];
		$uniq[$i] = $uniq[$idx];
		$uniq[$idx] = $temp; 
	}
}

#ouput the ranked alignments 
print ALIGN join("\n", @uniq); 
close ALIGN; 


