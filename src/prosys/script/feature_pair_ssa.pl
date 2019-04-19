#!/usr/bin/perl -w
#################################################################################################
#Compute the composition of SS and SA for (query,target) pair and also the correlation,cosine, exp(-dist) value. 
#Inputs: script dir, query file(fasta), query cm(conpro format) file, target file (9-line)
#Outputs: to stdout: ratio of ss, h, e, c, mathing and ratio of exposed or buried
#Date: 5/11/2005
#Author: Jianlin Cheng
#################################################################################################
if (@ARGV != 4)
{
	die "need four parameters: script_dir, query file(fasta), query cm file(conpro format), target file(9-line, no title).\n";
}
$script_dir = shift @ARGV;
require "$script_dir/syslib.pl";

$query_file = shift @ARGV;
$cm_file = shift @ARGV;
$target_file = shift @ARGV;

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
$qss =~ s/[GI]/H/g; 
$qss =~ s/B/E/g;
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
$tss =~ s/[TS\.]/C/g;
$tss =~ s/\s//g; 
<TARGET>; <TARGET>;
$tsa = <TARGET>;
@sa = split(/\s+/, $tsa); 
$tsa = ""; 

#number of exposed and buried residues in the target
$tem = 0;
$tbm = 0; 
foreach $value (@sa)
{
	if ($value > 25)
	{
		$tsa .= "e";
		$tem++; 
	}
	else
	{
		$tsa .= "-"; 
		$tbm++; 
	}
}
chomp $tsa; 
close TARGET; 

#count the number of helix, strand, coil in query
$qhn = 0; $qen = 0; $qcn = 0; 

#count the number of exposed or buried.
$qem = 0;
$qbm = 0; 
#count the number of helix, strand, coil in target 
$thn = 0; $ten = 0; $tcn = 0; 

$query_length = length ($qseq); 

for ($i = 0; $i < $query_length; $i++)
{
	if ( substr($qss, $i, 1) eq "H")
	{
		$qhn++; 
	}
	elsif ( substr($qss, $i, 1) eq "E" )
	{
		$qen++; 
	}
	else
	{
		$qcn++; 
	}
	if ( substr($qsa, $i, 1) eq "e" )
	{
		$qem++; 
	}
	else
	{
		$qbm++; 
	}
}
$target_length = length($tseq);
for ($i = 0; $i < $target_length; $i++)
{
	if ( substr($tss, $i, 1) eq "H")
	{
		$thn++; 
	}
	elsif ( substr($tss, $i, 1) eq "E" )
	{
		$ten++; 
	}
	else
	{
		$tcn++; 
	}
}
@qcomp = ($qhn/$query_length, $qen/$query_length, $qcn/$query_length, $qem/$query_length, $qbm/$query_length);
@tcomp = ($thn/$target_length, $ten/$target_length, $tcn/$target_length, $tem/$target_length, $tbm/$target_length);
$fea_cos = &cosine(\@qcomp, \@tcomp);
$fea_corr = &correlation(\@qcomp, \@tcomp);
$fea_exp = &expdist(\@qcomp, \@tcomp); 
$dotp = &dotproduct(\@qcomp, \@tcomp); 

print "feature num: 14\n"; 
print join(" ", @qcomp), " ", join(" ", @tcomp), " ", $fea_cos, " ", $fea_corr, " ", $fea_exp, " ", $dotp, "\n\n"; 
