#!/usr/bin/perl -w
################################################################################
#Join local alignments from palign into larger chunk
#Should be called before ordering the local alignments. 
#Input: query fasta, template fasta, local alignments, gap threshold(5), out file
#If can't make a join due to any reason, simply copy the alignment to output file.
#Author: Jianlin Cheng
#Date: 7/15/2005
###############################################################################
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
	die "need five parameters: query fasta, template fasta, local alignments, gap threshold(5), output file.\n";	
}

$query_file = shift @ARGV;
$temp_file = shift @ARGV;
$local_file = shift @ARGV;
$gap_thresh = shift @ARGV;
$out_file = shift @ARGV;

open(QUERY, $query_file) || die "can't read query file.\n";
$query_name = <QUERY>;
chomp $query_name;
$query_name = substr($query_name, 1); 
$query_seq = <QUERY>;
chomp $query_seq; 
close QUERY; 

open(TEMPL, $temp_file) || die "can't read template file:$temp_file.\n";
$temp_name = <TEMPL>;
chomp $temp_name; 
$temp_name = substr($temp_name, 1); 
$temp_seq = <TEMPL>;
chomp $temp_seq;
close TEMPL;

open(LOCAL, $local_file) || die "can't read local alignment file.\n";
@local = <LOCAL>;
close LOCAL;

$feature = shift @local;
$value = shift @local;
if (@local < 5)
{
	die "no local alignments.\n";
}

@group = ();
$prev = ""; 
while (@local)
{
	$pos = shift @local;
	chomp $pos;
	($qstart, $qend, $tstart, $tend) = split(/\s+/, $pos);
	$qname = shift @local;
	chomp $qname;
	if ($qname ne $query_name)
	{
		die "query name doesn't match:$qname, $query_name\n";
	}
	$qseq = shift @local;
	chomp $qseq; 
	$tname = shift @local;
	chomp $tname;
	if ($tname ne $temp_name)
	{
		die "template name doesn't match: $tname, $temp_name\n"; 
	}
	$tseq = shift @local;
	chomp $tseq;

	if ($prev ne "" && $prev ne $tname)
	{
		die "local alignments belong to more than one template.\n";
	}
	$prev = $tname; 

	$size = $qend - $qstart + 1;
	if ($size < 1 || $tend - $tstart + 1 < 1)
	{
		die "local alignment size is less than 0.\n";
	}
	push @group, {
		qname => $qname,
		qseq => $qseq,
		qstart => $qstart,
		qend => $qend,
		tname => $tname,
		tseq => $tseq,
		tstart => $tstart,
		tend => $tend,
		size => $size
		}; 
}
#sort the alignment by start positions of query in ascending order
@sorted_group = sort {$a->{"qstart"} <=> $b->{"qstart"}} @group;

if (@sorted_group < 2) #having less than two local alignments
{
	`cp $local_file $out_file`; 
	die "$local_file:less than two local alignments, do a simple copy and return."; 
}

#check if the integrity of the local alignments.
$prev_qend = 0;
$prev_tend = 0; 
for ($i = 0; $i < @sorted_group; $i++)
{
	$qstart = $sorted_group[$i]{"qstart"};
	$tstart = $sorted_group[$i]{"tstart"};  
	if ($qstart <= $prev_qend)
	{
		`cp $local_file $out_file`; 
		die "query: start is less than previous end: $qstart, $prev_qend\n";
	}
	if ($tstart <= $prev_tend)
	{
		`cp $local_file $out_file`; 
		die "query: start is less than previous end: $qstart, $prev_tend\n";
	}
	$prev_qend = $sorted_group[$i]{"qend"};
	$prev_tend = $sorted_group[$i]{"tend"}; 
}

@join_group = (); 
#Here is prev_record a reference to the record? let's assume that first.
$prev_record = shift @sorted_group; 
#<STDIN>;
while (@sorted_group)
{
	$record = shift @sorted_group; 
	#check if the record can be joined with the previous one. 
	$qx1 = $prev_record->{"qstart"};
	$qy1 = $prev_record->{"qend"};
	$qx2 = $record->{"qstart"};
	$qy2 = $record->{"qend"};

	$tx1 = $prev_record->{"tstart"};
	$ty1 = $prev_record->{"tend"};
	$tx2 = $record->{"tstart"};
	$ty2 = $record->{"tend"};

	if ($qx2 - $qy1 <= $gap_thresh && 
	$tx2 - $ty1 <= $gap_thresh)
	{
		#join them
		#compute the gap size
		$gap1 = $qx2 - $qy1 - 1; #need to add to the template
		$gap2 = $tx2 - $ty1 - 1;  #need to add to the query
		$qgap = &make_gaps($gap2);
		$tgap = &make_gaps($gap1);

		#gap insertion in the query
		$qinsertion = ""; 
		for ($k = $qy1+1; $k <= $qx2 - 1; $k++)
		{
			$qinsertion .= substr($query_seq, $k-1, 1); 
		}
		#gap insertion in the template
		$tinsertion = ""; 
		for ($k = $ty1+1; $k <= $tx2 - 1; $k++)
		{
			$tinsertion .= substr($temp_seq, $k-1, 1); 
		}

		#join the alignment
		$new_query = $prev_record->{"qseq"} . $qinsertion . $qgap . $record->{"qseq"};
		$new_temp = $prev_record->{"tseq"} . $tgap . $tinsertion . $record->{"tseq"}; 

		#invariance checking
		if (length($new_query) != length($new_temp))
		{
			`cp $local_file $out_file`; 
			die "fail to join two local alignments.\n";
		}

		#update the record
		$prev_record->{"qseq"} = $new_query;
		$prev_record->{"qend"} = $qy2; 
		$prev_record->{"tseq"} = $new_temp;
		$prev_record->{"tend"} = $ty2; 
		$prev_record->{"size"} = $qy2 - $qx1 + 1; 

		#invariance checking
		if ($qy2 - $qx1 != $ty2 - $tx1)
		{
			#`cp $local_file $out_file`; 
			#print "qy2=$qy2, qx1=$qx1, ty2=$ty2, tx1=$tx1\n"; 
			#die "joined query length is not equal to the joined template length.\n"; 
			#This condition doesn't hold for gapped alignment.
		}
	}
	else
	{
		#save the previous record 
		push @join_group, $prev_record; 
		$prev_record = $record; 
	}
}
push @join_group, $prev_record; 

#sort the group by size 
@sorted_group = sort {$b->{"size"} <=> $a->{"size"}} @join_group;

open(OUT, ">$out_file") || die "can't create output file\n";

print OUT "$feature$value";
#output the sorted alignment
for ($j = 0; $j <= $#sorted_group; $j++)
{
	print OUT $sorted_group[$j]{"qstart"}, " ";
	print OUT $sorted_group[$j]{"qend"}, " ";
	print OUT $sorted_group[$j]{"tstart"}, " ";
	print OUT $sorted_group[$j]{"tend"}, "\n";
	print OUT $sorted_group[$j]{"qname"}, "\n";
	print OUT $sorted_group[$j]{"qseq"}, "\n";
	print OUT $sorted_group[$j]{"tname"}, "\n";
	print OUT $sorted_group[$j]{"tseq"}, "\n";
}
close OUT; 




