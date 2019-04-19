#!/usr/bin/perl -w
##############################################################################
#Generate family-based pair-wise features
#Inputs: query file, query format, template file, template format, query msa, template msa
#Output to standard output
#features: query_len/100, template_len/100, e^(-dist),cosine,corr of comp1
# e^(-dist), cosine, corr of comp2
#foramt: fasta, nine, ten, cmap, bmap 
#Author: Jianlin Cheng
#Date: 5/1/2005
##############################################################################

if (@ARGV != 7)
{
	die "need seven parameters: script dir, query file, query format, template file, template format, query msa, template msa.\n";
}
#include the syslib package
$script_dir = shift @ARGV;
require "$script_dir/syslib.pl";


$query_file = shift @ARGV;
$qformat = shift @ARGV;
$temp_file = shift @ARGV;
$tformat = shift @ARGV;
$qmsa_file = shift @ARGV;
$tmsa_file = shift @ARGV;

$qseq = &read_seq($query_file, $qformat);
$tseq = &read_seq($temp_file, $tformat);

#read qmsa, tmsa
@qmsa = &read_msa($qseq, $qmsa_file);
@tmsa = &read_msa($tseq, $tmsa_file); 


#6-features
#feature vectors: expdist, corr, cosine for comp1, expdist, corr, coinse for comp2

@feature = (); 

@qcomp = &gen_fam_compo(\@qmsa, 1);
@tcomp = &gen_fam_compo(\@tmsa, 1);
#print "qcomp: @qcomp\n";
#print "tcomp: @tcomp\n";

$feature[0] = &cosine(\@qcomp, \@tcomp);
$feature[1] = &correlation(\@qcomp, \@tcomp);
$feature[2] = &expdist(\@qcomp, \@tcomp);

@qcomp = &gen_fam_compo(\@qmsa, 2);
@tcomp = &gen_fam_compo(\@tmsa, 2);
#print "qcomp: @qcomp\n";
#print "tcomp: @tcomp\n";

$feature[3] = &cosine(\@qcomp, \@tcomp);
$feature[4] = &correlation(\@qcomp, \@tcomp);
$feature[5] = &expdist(\@qcomp, \@tcomp);

$fnum = @feature; 
print "Query: $qseq\n";
print "Target: $tseq\n";
print "feature num: $fnum\n";
print join(" ", @feature), "\n";

