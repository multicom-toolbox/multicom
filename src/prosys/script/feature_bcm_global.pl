#!/usr/bin/perl -w
#################################################################################################
#Compute normalized sum of contacting probability of beta residues using alignment between query and template 
#Using global aligmnet (e.g. clustalw)
#In future, we might support palign local alignment and so on. 
#Inputs: query file(fasta), query cm(beta map format) file, target file (9-line), alignment file
#Outputs: the sum of contact probabilities of aligned regions / number of pairs 
#Date: 5/11/2005
#Author: Jianlin Cheng
#################################################################################################
if (@ARGV != 4)
{
	die "need four parameters: query file(fasta), query beta residue pairing file(beta map format), target file(9-line, no title), alignment file(right now, only support clustal global alignment from feature_align_prof_clustalw).\n";
}

$query_file = shift @ARGV;
$cm_file = shift @ARGV;
$target_file = shift @ARGV;
$align_file = shift @ARGV;

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
open(BETA, $cm_file) || die "can't read cm file.\n"; 
<BETA>;
$qseq = <BETA>;
chomp $qseq;
$qss = <BETA>;
chomp $qss; 

#check if there are more than two strands in secondary structure
$more_strand = 0;
if ($qss =~ /[BE]+[^BE]+[BE]+/)
{
	$more_strand = 1;
}
if ($more_strand == 0)
{
	#the protein doesn't have more than two predicted beta-strands. 
	close BETA;
	print "feature num: 1\n";
	print "0\n\n"; 
	goto END;
}
#count the total number of beta-residues
$beta_num = 0; 
$query_length = length($qseq); 
for ($i = 0; $i < $query_length; $i++)
{
	if ( substr($qss, $i, 1) eq "B" || substr($qss, $i, 1) eq "E"  )
	{
		$beta_num++; 	
	}
}

<BETA>; <BETA>;
#read beta residue pairing map
@beta_map = <BETA>;
close BETA;
if ($beta_num != @beta_map)
{
	die "the number of lines of beta contacts doesn't match with number of beta residues.\n"; 
}

#convert the lines into a contact probability matrix 
@beta_matrix = (); 
for ($i = 0; $i < $beta_num; $i++)
{
	$line = $beta_map[$i]; 
	chomp $line; 
	@probs = split(/\s+/, $line); 
	if (@probs != $beta_num)
	{
		die "the number of beta residues doesn't match.\n"; 
	}
	for ($j = 0; $j < $beta_num; $j++)
	{
		$beta_matrix[$i][$j] = $probs[$j]; 
	}
}

if ($seq1 ne $qseq)
{
	die "query sequence doesn't match with sequence in beta map.\n"; 
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
$tbp1 = <TARGET>; 
chomp $tbp1; 
@bp1 = split(/\s+/, $tbp1); 
$tbp2 = <TARGET>;
@bp2 = split(/\s+/, $tbp2); 
chomp $tbp2; 
<TARGET>;
<TARGET>;
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

#store the indices of beta residues
@qindice = (); 
$bidx1 = 0;

for ($i = 0; $i < length($align1); $i++)
{
	if (substr($align1, $i, 1) ne "-")
	{
		$id1++; 
		$ss1 = substr($qss, $id1-1, 1); 
		if ($ss1 eq "E" || $ss1 eq "B")
		{
			$bidx1++; 
		}
	}
	if (substr($align2, $i, 1) ne "-")
	{
		$id2++; 
	}
	if (substr($align1, $i, 1) ne "-" && substr($align2, $i, 1) ne "-")
	{
		#check if both are beta-residues
		$ss1 = substr($qss, $id1-1, 1); 
		$ss2 = substr($tss, $id2-1, 1); 
		if ( ($ss1 eq "E" || $ss1 eq "B") && ($ss2 eq "E" || $ss2 eq "B") )
		{
			push @qmatch, $id1;
			push @tmatch, $id2; 
			push @qindice, $bidx1; 
		}
	}
}


$size = @qmatch;
if ($size <= 1)
{
	print "feature num: 1\n";
	print "0\n\n"; 
	goto END;
}

$norm_contact = 0; 
$con_num = 0; 
for ($i = 0; $i < $size; $i++)
{
	$tid1 = $tmatch[$i]; 
	$bidx1 = $qindice[$i]; 
	#$qid1 = $qmatch[$i]; 
	for ($j = 0; $j < $size; $j++)
	{
		$tid2 = $tmatch[$j]; 
		#$qid2 = $qmatch[$j]; 
		$bidx2 = $qindice[$j]; 

		#check if two beta residues are paired in the target
		if ( ($bp1[$tid1-1] != 0 && $bp1[$tid1-1] == $tid2) || 
			($bp2[$tid1-1] != 0 && $bp2[$tid1-1] == $tid2) )
		{
			$norm_contact += $beta_matrix[$bidx1-1][$bidx2-1]; 
			$con_num++; 
		}
	}
}

#normalize by length is not a good choice, because it will favor proteins 
#having more contacts, so we normalize by number of contacts
#number of contacts normalized by query length and average prob. 
if ($con_num > 0)
{
	$norm_contact /= $con_num; 
}
#$norm_contact /= $query_length; 

print "feature num: 1\n";
print "$norm_contact\n\n"; 

END:
