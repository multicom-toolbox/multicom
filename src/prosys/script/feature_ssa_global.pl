#!/usr/bin/perl -w
#################################################################################################
#Compute the matching ratio of SS, H, E, C and solvent acc between query and template
#Using global aligmnet (e.g. clustalw)
#In future, we might support palign local alignment and so on. 
#Inputs: query file(fasta), query cm(conpro format) file, target file (9-line), alignment file
#Outputs: to stdout: ratio of ss, h, e, c, mathing and ratio of exposed or buried
#Date: 5/9/2005
#Author: Jianlin Cheng
#################################################################################################
if (@ARGV != 4)
{
	die "need four parameters: query file(fasta), query cm file(conpro format), target file(9-line, no title), alignment file(right now, only support clustal global alignment from feature_align_prof_clustalw).\n";
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

#read secondary structure
open(CONPRO, $cm_file) || die "can't read cm file.\n"; 
<CONPRO>;
$qseq = <CONPRO>;
chomp $qseq;
$qss = <CONPRO>;
chomp $qss; 
$qsa = <CONPRO>;
chomp $qsa; 
close CONPRO;

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

#count the ratios
#number of helix, strand, coils
$hn = 0; $en = 0; $cn = 0; 
#number of match of helix, strand, and coils
$hm = 0; $em = 0; $cm = 0; 
#number of exposed and buried
$expn = 0; $burn = 0; 
#number of mathed exposed and buried
$expm = 0; $burm = 0; 

$length = length ($qseq); 

$id1 = 0; #residue idx in align1
$id2 = 0; #residue idx in align2

for ($i = 0; $i < length($align1); $i++)
{
	if (substr($align1, $i, 1) ne "-")
	{
		$id1++; 
		#count number of ss and sa
		$sec = substr($qss, $id1-1, 1); 	
		if ($sec eq "H")
		{
			$hn++; 
		}
		elsif ($sec eq "E")
		{
			$en++; 
		}
		else
		{
			$cn++; 
		}
		$acc = substr($qsa, $id1-1, 1);
		if ($acc eq "e")
		{
			$expn++; 
		}
		else
		{
			$burn++; 
		}
	}
	if (substr($align2, $i, 1) ne "-")
	{
		$id2++; 
	}
	if (substr($align1, $i, 1) ne "-" && substr($align2, $i, 1) ne "-")
	{
		#count number of match	
		$sec1 = substr($qss, $id1-1, 1); 	
		$acc1 = substr($qsa, $id1-1, 1);
		$sec2 = substr($tss, $id2-1, 1); 	
		$acc2 = substr($tsa, $id2-1, 1);
		if ($sec1 eq $sec2)
		{
			if ($sec1 eq "H")
			{
				$hm++; 
			}
			elsif ($sec1 eq "E")
			{
				$em++; 
			}
			else
			{
				$cm++; 
			}
		}
		if ($acc1 eq $acc2)
		{
			if ($acc1 eq "e")
			{
				$expm++; 
			}
			else
			{
				$burm++; 
			}
		}
	}
}

if ( ($hn+$en+$cn) != $length || ($expn+$burn) != $length )
{
	die "the length sequence is not equal to number of ss or sa.\n"; 
}

print "feature num: 2\n";
#print $hn==0 ? 0 : $hm/$hn, " ", $en==0 ? 0 : $em/$en, " ", $cn==0 ? 0 : $cm/$cn, " ", ($hm+$em+$cm)/($hn+$en+$cn), " ";
#print $expn==0 || $expm/$expn, " ", $burn==0 || $burm/$burn, " ", ($expm+$burm) / ($expn+$burn), "\n\n"; 
$ss_ratio = ($hm+$em+$cm)/($hn+$en+$cn); 
$acc_ratio = ($expm+$burm)/($expn+$burn); 
print "$ss_ratio $acc_ratio\n\n";
#print "$hm/$hn, $em/$en, $cm/$cn, $expm/$expn, $burm/$burn\n"; 

