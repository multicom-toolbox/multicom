#!/usr/bin/perl -w
###########################################################################
#Convert a local alignment (assuming palign format) to pir format
#Modified from cm_align_blast.pl (blast format, ranked by evalue)
#Input: query file(fasta), local alignment file(palign), max gap size(20), 
# min_cover_size(20), output pir file
#
#This script is supposed to work on the alignment generated between query and 
#fold recognition targets.
#The alignments for each template will ranked by the alignment length
#This ranking should be done for each template before calling this script. 
#The alignments for the different templates should be ranked by fold recognithion method
#This ranking will be done outside (the program that calls this script.)
#Use the same Gap-Drived-Greedy-Coverage algorithm in cm_align_blast.pl
#Author: Jianlin Cheng
#Date: 7/13/2005
########################################################################################
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

if (@ARGV != 5)
{
	die "need five parameters: query file(fasta), local alignment file (palign format), max gap size(20), min_cover_size(20), output msa file\n"; 
}
$query_file = shift @ARGV;
$local_file = shift @ARGV;
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

open(LOCAL, $local_file) || die "can't read blast file.\n";
#blast is a vector to store local alignments.
@blast = <LOCAL>;
#first two lines are ignored. (modified:keep one line original information about the alignment for blast CM)
shift @blast; $original_info = shift @blast; chomp $original_info;
close LOCAL;

if (@blast <= 4)
{
	die "no local alignments in the local file, stop.\n";
}

#choose the alignments
@cover = ();
for($i = 0; $i < $query_length; $i++)
{
	#set covered flat 0. 
	$cover[$i] = 0; 
}

#template names
@align_names = ();
#alignment length  (qend - qstart + 1), slightly different from comparative modeling.
@align_size = ();
#query start and end
@align_qstart = ();
@align_qend = ();
#template start and end
@align_tstart = ();
@align_tend = ();
#covered size by alignment
@align_cover_size = (); 
#aligned query sequence
@align_qseq = ();
#aligned template sequence
@align_tseq = (); 

#select local alignments that will be used
while (@blast)
{
	#starting/end positions
	$line1 = shift @blast;
	chomp $line1; 
	#query name
	$qname = shift @blast;
	chomp $qname; 
	#qeury seq
	$qseq = shift @blast;
	chomp $qseq; 
	#template name
	$temp_name = shift @blast;
	chomp $temp_name;
	#template seq
	$tseq = shift @blast;
	chomp $tseq; 

	($qstart, $qend, $tstart, $tend) = split(/\s+/, $line1); 

	$ali_len = $qend - $qstart + 1; 

	if ($ali_len >= $min_cover_size)
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
			push @align_size, $ali_len;
			push @align_qstart, $qstart;
			push @align_qend, $qend;
			push @align_tstart, $tstart;
			push @align_tend, $tend;
			push @align_cover_size, $cover_size; 
			push @align_qseq, $qseq;
			push @align_tseq, $tseq;

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

	#do we check the gap size to decide if we need to stop?
	#maybe not necessary?, right now seems to be somewhat redundant.
	#this code is buggy: we should check the maximum continuous gap size?
	#7/13/2005. We need to fix this bug in the cm_align_blast.pl too!!!!!!!
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
	die "no qualified alignments in the local alignment file.\n";
}

#check consistency of query squence (compare fasta file with query in alignments)
#in future we also need to check local alignments with targets
for ($i = 0; $i < $num; $i++)
{
	$qseq = $align_qseq[$i];
	#make sure the two ends of query in alignment is not "-"
	if (substr($qseq, 0, 1) eq "-" || substr($qseq, length($qseq)-1, 1) eq "-")
	{
		die "the two ends of query are - for $qseq.\n";
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
#compute number of maximum gap size between each pair of adjacent amino acids in the query
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
#generate alignments for each template from the local alignments
for ($i = 0; $i < $num; $i++)
{
	$tname = $align_names[$i];

	#print "process: $tname\n";
	$tali_len = $align_size[$i];
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
	print MSA "C;cover size:$tcover_size; local alignment length=$tali_len (original info = $original_info)\n";
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
print MSA "C;query_length:$query_length num_of_temps:$num cover_ratio:$ratio cover:$cov not_cover:$not_cover\n";
print MSA ">P1;$query_name\n";
print MSA " : : : : : : : : : \n";
print MSA "$msa_query*\n"; 
close MSA; 


