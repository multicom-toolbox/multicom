#!/usr/bin/perl -w
#################################################################################################
#Compute normalized sum of contacting probability using alignment between query and template 
#Using global aligmnet (e.g. clustalw)
#In future, we might support palign local alignment and so on. 
#Inputs: query file(fasta), query cm(conpro format) file, target file (9-line), alignment file
#Outputs: the sum of contact probabilities of aligned regions / length of query 
#Date: 5/10/2005
#Author: Jianlin Cheng
#################################################################################################
if (@ARGV != 6)
{
	die "need six parameters: script dir, query file(fasta), query cm file(conpro format), target file(9-line, no title), alignment file(right now, only support clustal global alignment from feature_align_prof_clustalw), contact threshold (8a or 12a).\n";
}
$script_dir = shift @ARGV;
require "$script_dir/syslib.pl";
$query_file = shift @ARGV;
$cm_file = shift @ARGV;
$target_file = shift @ARGV;
$align_file = shift @ARGV;
$con_thresh = shift @ARGV; 

open(QUERY, $query_file) || die "can't read query file.\n";
$name1 = <QUERY>;
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY; 
chomp $name1; 
if ($name1 =~ /^>(.+)/)
{
	$name1 = $1; 
}
else
{
	die "query format error.\n"; 
}

#read secondary structure and coordinates
open(CONPRO, $cm_file) || die "can't read cm file.\n"; 
<CONPRO>;
$qseq = <CONPRO>;
chomp $qseq;
$qss = <CONPRO>;
chomp $qss; 
$qsa = <CONPRO>;
@cmap = <CONPRO>;
chomp $qsa; 
close CONPRO;
$query_length = length($qseq); 
if ($query_length != @cmap)
{
	die "the number of lines of contact doesn't match with sequence length.\n"; 
}

#convert the lines into a contact probability matrix 
@con_matrix = (); 
for ($i = 0; $i < $query_length; $i++)
{
	$line = $cmap[$i]; 
	chomp $line; 
	@probs = split(/\s+/, $line); 
	if (@probs != $query_length)
	{
		die "number of contacts doesn't match.\n"; 
	}
	for ($j = 0; $j < $query_length; $j++)
	{
		$con_matrix[$i][$j] = $probs[$j]; 
	}
}

if ($seq1 ne $qseq)
{
	die "query sequence doesn't match with sequence in conpro.\n"; 
}

open(TARGET, $target_file) || die "can't read target file.\n"; 
$tname = <TARGET>;
chomp $tname;
$tlen = <TARGET>;
chomp $tlen; 
$tseq = <TARGET>;
$tseq =~ s/\s//g;

$tss = <TARGET>;
$tss =~ s/[GI]/H/g; 
$tss =~ s/B/E/g;
$tss =~ s/\./C/g;
$tss =~ s/\s//g; 
<TARGET>; <TARGET>;
$tsa = <TARGET>;
$txyz = <TARGET>;
chomp $txyz;  
@coor = split(/\s+/, $txyz); 
for ($i = 0; $i < length($tseq); $i++)
{
	$tx[$i] = $coor[3*$i]; 
	$ty[$i] = $coor[3*$i + 1]; 
	$tz[$i] = $coor[3*$i + 2]; 
}
@sa = split(/\s+/, $tsa); 
$tsa = ""; 
foreach $value (@sa)
{
	if ($value > 25)
	{
		$tsa .= "e";
	}
	else
	{
		$tsa .= "-"; 
	}
}
chomp $tsa; 
close TARGET; 

#read alignments
open(ALIGN, $align_file) || die "can't read alignment file.\n"; 
<ALIGN>;<ALIGN>;
<ALIGN>;
$align1 = <ALIGN>;
chomp $align1; 
$aseq1 = $align1; 
<ALIGN>;
$align2 = <ALIGN>;
chomp $align2;
$aseq2 = $align2; 
close ALIGN; 

#check the consistency with the alignments.
$aseq1 =~ s/-//g;
$aseq2 =~ s/-//g;
if ($qseq ne $aseq1)
{
	die "query sequence doesn't match with query in alignment\n";
}
if ($tseq ne $aseq2)
{
	die "target sequence doesn't match with target in alignment\n";
}

$id1 = 0; #residue idx in align1
$id2 = 0; #residue idx in align2

@qmatch = ();
@tmatch = (); 
for ($i = 0; $i < length($align1); $i++)
{
	if (substr($align1, $i, 1) ne "-")
	{
		$id1++; 
	}
	if (substr($align2, $i, 1) ne "-")
	{
		$id2++; 
	}
	if (substr($align1, $i, 1) ne "-" && substr($align2, $i, 1) ne "-")
	{
		push @qmatch, $id1;
		push @tmatch, $id2; 
	}
}

$norm_contact = 0; 
$size = @qmatch;
if ($size <= 0)
{
	print "feature num: 1\n";
	print "0\n\n"; 
}

$con_num = 0; 

#also compute the residue-wise contact number and contact order 
@qcontact_num = ();
@qcontact_ord = (); 
@tcontact_num = ();
@tcontact_ord = (); 
for ($i = 0; $i < $size; $i++)
{
	$qcontact_num[$i] = 0;
	$qcontact_ord[$i] = 0; 
	$tcontact_num[$i] = 0;
	$tcontact_ord[$i] = 0; 
}
$qcon_ord_all = 0;
$qcon_num_all = 0;
$tcon_ord_all = 0; 
$tcon_num_all = 0; 

for ($i = 0; $i < $size; $i++)
{
	$tid1 = $tmatch[$i]; 
	$qid1 = $qmatch[$i]; 
	$x1 = $tx[$tid1-1]; 
	$y1 = $ty[$tid1-1]; 
	$z1 = $tz[$tid1-1]; 
	for ($j = 0; $j < $size; $j++)
	{
		$tid2 = $tmatch[$j]; 
		$qid2 = $qmatch[$j]; 
		$x2 = $tx[$tid2-1]; 
		$y2 = $ty[$tid2-1]; 
		$z2 = $tz[$tid2-1]; 
		#print "$x1, $y1, $z1, $x2, $y2, $z2\n";
		#<STDIN>;

		$dist = sqrt( ($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2) + ($z1-$z2)*($z1-$z2) );  
		#sequence separation is very important. 
		if ($qid1 - $qid2 >= 6)
		{
			$qcontact_num[$i] += $con_matrix[$qid1-1][$qid2-1];
			$qcontact_ord[$i] += $con_matrix[$qid1-1][$qid2-1] * ($qid1-$qid2);
			$qcon_num_all += $con_matrix[$qid1-1][$qid2-1];
			$qcon_ord_all += $con_matrix[$qid1-1][$qid2-1] * ($qid1-$qid2); 
		}
		if ($dist < $con_thresh && $qid1 - $qid2 >= 6)
		{
			$norm_contact += $con_matrix[$qid1-1][$qid2-1]; 
			#print " prob = $con_matrix[$qid1-1][$qid2-1]\n";
			#<STDIN>;
			$con_num++; 

			$tcontact_num[$i] += 1; 
			#here we use distance in query instead of template to check the fitness
			$tcontact_ord[$i] += ($qid1-$qid2); 
			$tcon_num_all += 1; 
			$tcon_ord_all += ($qid1-$qid2);
		}
	}
}

#normalize by length is not a good choice, because it will favor proteins 
#having more contacts, so we normalize by number of contacts
#number of contacts normalized by query length and average prob. 
if ($con_num != 0)
{
	$norm_contact /= $con_num; 
}
else
{
	$norm_contact = 0; 
}
#$norm_contact /= $query_length; 

#@qall = ($qcon_num_all, $qcon_ord_all);
#@tall = ($tcon_num_all, $tcon_ord_all);

$feature[0] = &cosine(\@qcontact_num, \@tcontact_num);
$feature[1] = &correlation(\@qcontact_num, \@tcontact_num);
#$feature[2] = &expdist(\@qcontact_num, \@tcontact_num);
$feature[2] = &cosine(\@qcontact_ord, \@tcontact_ord);
$feature[3] = &correlation(\@qcontact_ord, \@tcontact_ord);
#$feature[5] = &expdist(\@qcontact_ord, \@tcontact_ord);
if ( ($qcon_num_all == 0 && $qcon_ord_all == 0) || ($tcon_num_all == 0 && $tcon_ord_all == 0) )
{
#	$feature[6] = $feature[7] = $feature[8] = 0; 
}
else
{
#	$feature[6] = &cosine(\@qall, \@tall);
#	$feature[7] = &correlation(\@qall, \@tall);
#	$feature[8] = &expdist(\@qall, \@tall);
}

print "feature num: 5\n";
print "$norm_contact ", join(" ", @feature), "\n\n"; 


