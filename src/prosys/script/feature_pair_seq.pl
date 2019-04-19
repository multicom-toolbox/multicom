#!/usr/bin/perl -w
##############################################################################
#Generate sequenced-based pair-wise features
#Inputs: query file, query format, template file, template format
#Output to standard output
#features: query_len/100, template_len/100, e^(-dist),cosine,corr of comp1
# e^(-dist), cosine, corr of comp2
#foramt: fasta, nine, ten, cmap, bmap 
#Author: Jianlin Cheng
#Date: 5/1/2005
##############################################################################

if (@ARGV != 5)
{
	die "need five parameters: script dir, query file, query format, template file, template format.\n";
}
#include the syslib package
$script_dir = shift @ARGV;
require "$script_dir/syslib.pl";


$query_file = shift @ARGV;
$qformat = shift @ARGV;
$temp_file = shift @ARGV;
$tformat = shift @ARGV;

$qseq = &read_seq($query_file, $qformat);
$tseq = &read_seq($temp_file, $tformat);

#8-features
#feature vectors: normalized length (2), expdist, corr, cosine for comp1, expdist, corr, coinse for comp2

@feature = (); 
$feature[0]= length($qseq) / 100;
$feature[1]= length($tseq) / 100;

@qcomp = &gen_compo($qseq, 1);
@tcomp = &gen_compo($tseq, 1);
#print "qcomp: @qcomp\n";
#print "tcomp: @tcomp\n";

$feature[2] = &cosine(\@qcomp, \@tcomp);
$feature[3] = &correlation(\@qcomp, \@tcomp);
$feature[4] = &expdist(\@qcomp, \@tcomp);

@qcomp = &gen_compo($qseq, 2);
@tcomp = &gen_compo($tseq, 2);
#print "qcomp: @qcomp\n";
#print "tcomp: @tcomp\n";

$feature[5] = &cosine(\@qcomp, \@tcomp);
$feature[6] = &correlation(\@qcomp, \@tcomp);
$feature[7] = &expdist(\@qcomp, \@tcomp);

$fnum = @feature; 
print "Query: $qseq\n";
print "Target: $tseq\n";
print "feature num: $fnum\n";
print join(" ", @feature), "\n";

