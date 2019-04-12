#!/usr/bin/perl -w
#########################################################################################
#Generate full multiple alignments for the query
#Input:query file(fasta) and the ranked and parsed local blast alignments
#Output: a PIR full multiple alignment file
#Algorithm:
# Greedy Coverage Algorithm
# 	Evaluation: MSA score (lowest e-value, highest e-value)
# Repeat:
#	Pick one alignment from the ranked local alignment list
#	If its evalue < max_evalue(or other criteria:identity,aligned length)
#		&& it can cover the unaligned
#		query region bigger than (min_cover_size, 30)
#		Choose the alignments and add it into the list		
#
# Until: 
#	1. query sequence is covered without gap bigger than (max_gap_size, 20)
#	2. End of the alignment list
#	3. No alignment left with evalue lower than (max_evalue: 0.5)
# Generate alignments from chosen alignments: 
#	issues: if one target appears in local alignments many times
#		They either are joined together. But to facilitate the structure generation
#		, we must refer to the original templates to constructu full alignment.
#		Or: They are treated as independently. In this case, we can use the 
#		same atom file (however, they need to assign different id)
#		So we can use the original five-letter + num (starting from 2, first one still use five letters). 	
#	Decision: Each local alignment treated independently first. I will implement join later.
#	Then is very easy to generate alignments
#	Copy the alignments, and set all other areas uncovered with "-" in template.
#	Output format: PIR format (See Modeller Document)
#Three Parameters needed to tune: max_evalue, max_gap_size, min_cover_size
#Inputs to script: query file, local align file, max-evalue, max_gap_size, min_cover_size
#		, and output alignment file.
# IMPORTANT ASSUMPTIONS:
#	We trust blast will not change templates sequence. So all sequences appears in the blast local 
#	alignments are exactly as the same as in the database.
#	For the second approach, we are going to check this in the scripts.
#
#Author: Jianlin Cheng
#Date: 4/13/2005
#Bug fix: 9/05/2005: evalue-comparsion to handle 0 evalue
#########################################################################################
#PIR format:
#line1: >p1;protein_code(must be unique, consistent with code in top script)
#line2: structureX/structureN:pdb_file(name for atom file,not suffix):start_pos:chain_id(use blank):
#end_pos:chain_id(use blank):protein name:protein source:resolution:r-factor of x-ray
#line3: sequence ended with *. - denotes gap.
#line4: blank line separator.
# Query will be the last sequence in the alignment
#One issue: the atom file name should end with suffix:atm, pdb, ...
#########################################################################################
sub round
{
       my $value = $_[0];
       $value *= 100;
       $value = int($value + 0.5);
       $value /= 100;
       return $value;
}
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

if (@ARGV != 6)
{
	die "need six parameters: query file(fasta), local blast alignment file, e-value threshold(0.5), max gap size(20), min_cover_size(20), output msa file\n"; 
}
$query_file = shift @ARGV;
$blast_file = shift @ARGV;
#the selected alignments must have e-value <= max_evalue
$max_evalue = shift @ARGV;
#one criteria to stop using more alignments if gap is small than max_gap_size
$max_gap_size = shift @ARGV;
#one criteria to select alignments which must cover at least min_cover_size 
$min_cover_size = shift @ARGV;
$msa_file = shift @ARGV;

open(QUERY, $query_file) || die "can't read query file.\n";
$query_name = <QUERY>;
chomp $query_name;
if ($query_name =~ /^>(\S+)$/)
{
	$query_name = $1; 
}
else
{
	die "query file format error.\n"; 
}
$query_seq = <QUERY>;
chomp $query_seq;
close QUERY;
$query_length = length($query_seq); 

open(BLAST, $blast_file) || die "can't read blast file.\n";
@blast = <BLAST>;
close BLAST;

if (@blast <= 2)
{
	die "no local alignments in the blast file, stop.\n";
}

$title = shift @blast;
($qname, $qlength, @other) = split(/\s+/, $title);  
#check consistency
if ($qname ne $query_name || $qlength != $query_length)
{
	die "blast file doesn't match with query file:$qname, $qlength, $query_name, $query_length.\n"; 
}

shift @blast;

#choose the alignments
@cover = ();
for($i = 0; $i < $query_length; $i++)
{
	#set covered flat 0. 
	$cover[$i] = 0; 
}

#template names
@align_names = ();
#template length
@align_temp_len = ();
@align_evalue = ();
#alignment length
@align_size = ();
#alignment identity
@align_ind = ();
@align_qstart = ();
@align_qend = ();
@align_tstart = ();
@align_tend = ();
@align_cover_size = (); 
@align_qseq = ();
@align_tseq = (); 
@align_score = (); 

while (@blast)
{
	$line1 = shift @blast;
	chomp $line1; 
	$line2 = shift @blast;
	chomp $line2; 
	$qseq = shift @blast;
	chomp $qseq; 
	$tseq = shift @blast;
	chomp $tseq; 

	($temp_name, $temp_length, $score, $evalue, $ali_len, $ali_ind, @other) = split(/\s+/, $line1);
	($qstart, $qend, $tstart, $tend) = split(/\s+/, $line2); 

	if (&comp_evalue($evalue, $max_evalue) <= 0 || $ali_len >= $min_cover_size)
	{
		#check the cover size
		$cover_size = 0; 
		for ($i = $qstart -1; $i <= $qend -1; $i++)
		{
			if ($cover[$i] == 0)
			{
				$cover_size++; 
			}
		}
		if ($cover_size >= $min_cover_size)
		{
			#this alignment is chosen
			push @align_names, $temp_name;
			push @align_temp_len, $temp_length;
			push @align_evalue, $evalue;
			push @align_size, $ali_len;
			push @align_ind, $ali_ind;
			push @align_qstart, $qstart;
			push @align_qend, $qend;
			push @align_tstart, $tstart;
			push @align_tend, $tend;
			push @align_cover_size, $cover_size; 
			push @align_qseq, $qseq;
			push @align_tseq, $tseq;
			push @align_score, $score;

			#set cover flag 
			for ($i = $qstart -1; $i <= $qend -1; $i++)
			{
				if ($cover[$i] == 0)
				{
					$cover[$i] = 1; 
				}
			}
		}
	}

	#shift out blank if necessary
	if (@blast)
	{
		shift @blast;
	}

	#do we check the gap size to decide if we need to stop?
	#maybe not necessary?, right now seems to be somewhat redundant.
	$cov = 0; 
	for ($i = 0; $i < $query_length; $i++)
	{
		if ($cover[$i] == 1)
		{
			$cov++; 
		}
	}
	$not_cover = $query_length - $cov; 
	if ($not_cover < $max_gap_size)
	{
		last;
	}
}

$num = @align_names;
if ($num == 0)
{
	die "no qualified alignments in the blast file.\n";
}

#check consistency of query squence (compare fasta file with query in alignments)
#in future we also need to check local alignments with targets
for ($i = 0; $i < $num; $i++)
{
	$qseq = $align_qseq[$i];
	#make sure the two ends of query in alignment is not "-"
	if (substr($qseq, 0, 1) eq "-" || substr($qseq, length($qseq)-1, 1) eq "-")
	{
		die "the two ends of query are "-" for $qseq.\n";
	}
	$qstart = $align_qstart[$i];
	$qend = $align_qend[$i];
	for ($j = 0; $j < length($qseq); $j++)
	{
		$aa = substr($qseq, $j, 1);
		if ($aa ne "-")
		{
			if ($aa ne substr($query_seq, $qstart-1, 1) )
			{
				print "$qstart, $aa\n"; 
				print "$query_seq\n$qseq\n";
				die "query in alignment:$align_names[$i] doesn't match with query fasta file.\n";
			}
			else
			{
				$qstart++; 
			}
		}
	}
}

#make the template name of each alignment uniq in the case same template appears more than once 
for ($i = $num -1; $i > 0; $i--)
{
	$copy = 1; 
	for ($j = 0; $j < $i; $j++)
	{
		if ($align_names[$j] eq $align_names[$i])
		{
			$copy++; 
		}
	}
	if ($copy > 1)
	{
		$align_names[$i] = "$align_names[$i]$copy"; 
	}
}

#generate msa in PIR format

#first step:
#compute number of gaps between each pair of adjacent amino acids in the query
@gaps = ();
for ($i=0; $i < $query_length - 1; $i++)
{
	$gaps[$i] = 0; 
}
#start from the second residue
for ($i = 2; $i <= $query_length; $i++)
{
	$gap_size = 0;	
	#check all the aligments and find the maximum gap
	for ($j = 0; $j < $num; $j++)
	{
		$qstart = $align_qstart[$j];
		$qend = $align_qend[$j];
		if ($i <= $qstart || $i > $qend)
		{
			next; 
		}
		$qseq = $align_qseq[$j]; 

		#try to find the positions of residues(i-1 and i) in the alignment
		$pos = $qstart - 1;
		$ida = $idb = 0;
		for($m = 0; $m < length($qseq); $m++)
		{
			$residue = substr($qseq, $m, 1);
			if ($residue ne "-")
			{
				$pos++;
				if ($pos == $i - 1)
				{
					$ida = $m;		
				}
				if ($pos == $i)
				{
					$idb = $m; 
					last;
				}
			}
		}
		$diff = $idb - $ida - 1; 
		if ($diff > $gap_size)
		{
			#set gap size between residue i-1 and i. 
			$gap_size = $diff; 
		}
	}
	$gaps[$i-1] = $gap_size; 
}

#generate the query sequence in MSA
#copy the first residue
$msa_query = substr($query_seq, 0, 1);
#starting from the second reside
for ($i = 1; $i < $query_length; $i++)
{
	$gap = $gaps[$i];
	$msa_query .= &make_gaps($gap);
	$msa_query .= substr($query_seq, $i, 1);
}

open(MSA, ">$msa_file") || die "can't create msa file.\n";

#print "number of local alignments: $num\n"; 
#generate alignments for each templates from the local alignments
for ($i = 0; $i < $num; $i++)
{
	$tname = $align_names[$i];

	#print "process: $tname\n";
	$tlength = $align_temp_len[$i];
	$tevalue = $align_evalue[$i]; 
	$tali_len = $align_size[$i];
	$tind = $align_ind[$i]; 
	$qstart = $align_qstart[$i];
	$qend = $align_qend[$i]; 
	$tstart =  $align_tstart[$i];
	$tend =  $align_tend[$i];
	$tcover_size = $align_cover_size[$i]; 
	$qseq = $align_qseq[$i]; 
	$tseq = $align_tseq[$i];
	
	#set the first position
	if ($qstart == 1)
	{
		if (substr($qseq, 0, 1) eq substr($query_seq, 0, 1))
		{
			$target = substr($tseq, 0, 1); 
		}
		else
		{
			die "in template $tname, alignment doesn't match with query sequence.\n";
		}
		$cur_pos = 1; 
	}
	else
	{
		$target = "-";
	}

	#start from the second residue 
	#print "query_length: $query_length, qstart: $qstart, qend: $qend\n";
	#<STDIN>;
	for ($j = 2; $j <= $query_length; $j++)
	{
		if ( $j < $qstart || $j > $qend ) #out of range of local alignments
		{
			#add gaps if necessary
			$gap = $gaps[$j-1];  
			$target .= &make_gaps($gap); 
			$target .= "-"; 
			next; 
		}
		
		if ($j == $qstart)
		{
			#handle the first residue appearing in the local alignment
			if (substr($qseq, 0, 1) eq substr($query_seq, $qstart-1, 1))
			{
				$gap = $gaps[$j-1];  
				$target .= &make_gaps($gap); 
				$target .= substr($tseq, 0, 1); 
			}
			else
			{
				die "in template $tname, alignment doesn't match with query sequence.\n";
			}
			$cur_pos = 1; #current pos in the local alignments  
			next; 
		}

		#find the current position
		$between = "";
		#print "$qstart, $qend, $i, cur: $cur_pos\n";
		$prev_pos = $cur_pos; 
		#find the next residue not "-"
		while (++$cur_pos)
		{
			if (substr($qseq, $cur_pos -1, 1) ne "-")
			{
				last; 
			}
		}
		#print "prev: $prev_pos, cur: $cur_pos\n";
		$between_len = $cur_pos - $prev_pos - 1; 
		#print "between_len: $between_len\n";
		#<STDIN>;
		if ($between_len > 0)
		{
			$between = substr($tseq, $prev_pos, $between_len);
		}
		$gap = $gaps[$j-1]; #insertion happens in the template in MSA 
		#print "gap: $gap\n";
		if ($between_len < $gap)
		{
			$between .= &make_gaps($gap - $between_len); 
		}
		$target .= $between;
		#add the residue into the alignment
		$target .= substr($tseq, $cur_pos -1, 1); 
	}

	if (length($target) != length($msa_query))
	{
		print "msa_query: $msa_query\n";
		print "msa_temp:  $target\n"; 
		die "MSA error: the length of targets doesn't match with length of query.\n"; 
	}

	#output the alignment
	#output the information in comments
	print MSA "C;template_length:$tlength eval:$tevalue ind:$tind cover:$tcover_size local_alignment_length:$tali_len\n";
	print MSA ">P1;$tname\n";
	#better to figure out the structure determination method later
	print MSA "structureX:";
	print MSA substr($tname, 0, 5); 
	print MSA ": $tstart: :";
	print MSA " $tend: :";
	#protein name, source, resolution, and r-factor
	print MSA " : : : \n";
	print MSA "$target*\n\n"; 
}

#output query
#compute the coverage ratio
$ratio = 0; 
for ($i = 0; $i < $query_length; $i++)
{
	if ($cover[$i] == 1)
	{
		$ratio++; 
	}
}
$not_cover = $query_length - $ratio; 
$cov = $ratio; 
$ratio /= $query_length;
$ratio = &round($ratio); 
print MSA "C;query_length:$query_length num_of_temps:$num max_evalue:$align_evalue[0] min_evalue:$align_evalue[$num-1] cover_ratio:$ratio cover:$cov not_cover:$not_cover\n";
print MSA ">P1;$query_name\n";
print MSA " : : : : : : : : : \n";
print MSA "$msa_query*\n"; 
close MSA; 
