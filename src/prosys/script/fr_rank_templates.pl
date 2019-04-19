#!/usr/bin/perl -w
##########################################################################################
#Given a fasta query file, a library file, option file to rank all templates for the query
#Input: option_file, query file(fasta), template library(fasta), output file
#Output format: line 1: query name, total templates, others: rank,temp,score
#Author: Jianlin Cheng
#Date: 8/22/05
##########################################################################################
if (@ARGV != 4)
{
	die "need 4 parameters: option file(option_pairwise), query file(fasta), template library(fasta), output rank file.\n";
}
$option_file = shift @ARGV;
$query_file = shift @ARGV;
$lib_file = shift @ARGV;
$out_file = shift @ARGV;

open(OPTION, $option_file) || die "can't read option file.\n";
$fr_stx_feature_alignment = "clustalw";
while(<OPTION>)
{
	$line = $_;
	if ($line =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($line =~ /^fr_stx_feature_alignment\s*=\s*(\S+)/)
	{
		$fr_stx_feature_alignment = $1; 
	}
}
-d $prosys_dir || die "prosys dir doesn't exist.\n";
-f $query_file || die "query file doesn't exist.\n";
-f $lib_file || die "library file doesn't exist.\n";
if ($fr_stx_feature_alignment ne "clustalw" && $fr_stx_feature_alignment ne "lobster" && $fr_stx_feature_alignment ne "lobster_sel" && $fr_stx_feature_alignment ne "muscle" && $fr_stx_feature_alignment ne "lobster_no_clustalw")
{
	die "alignment method for structure feature must be clustalw, lobster, muscle or lobster_sel.\n";
}

#generate pairwise feature set
print "generate pairwise features (alignment method for stx features: $fr_stx_feature_alignment)...\n";
system("$prosys_dir/script/gen_pairwise_feature_proc.pl $option_file $query_file $lib_file $query_file.svm");

#make a copy of svm feature file
`cp $query_file.svm $query_file.fsvm`; 

#decide whether or not remove some features (e.g., length bias) from the dataset
if ($fr_stx_feature_alignment eq "lobster")
{
	system("$prosys_dir/script/svm_remove_features.pl $query_file.svm $query_file.small 1 2 19 25");
	`mv $query_file.small $query_file.svm`; 
}
elsif ($fr_stx_feature_alignment eq "lobster_sel" || $fr_stx_feature_alignment eq "muscle"  )
{
	system("$prosys_dir/script/svm_remove_features.pl $query_file.svm $query_file.small 1 2 19 25 23 24 32 33 37 38 62 63 64 65 66 67 68 69 70 71");
	`mv $query_file.small $query_file.svm`; 
}
elsif ($fr_stx_feature_alignment eq "lobster_no_clustalw")
{
	system("$prosys_dir/script/svm_remove_features.pl $query_file.svm $query_file.small 1 2 17 18 19 25 23 24 32 33 37 38 62 63 64 65 66 67 68 69 70 71");
	`mv $query_file.small $query_file.svm`; 
}

#do classification
print "rank templates...\n";
system("$prosys_dir/script/fold_classify.pl $prosys_dir $query_file.svm $query_file.class $fr_stx_feature_alignment");

#do ranking
#system("$prosys_dir/script/rank_fr_results.pl $query_file.svm $query_file.class $out_file");
system("$prosys_dir/script/rank_fr_results.pl $query_file.fsvm $query_file.class $out_file");

#report statistics
open(LIB, $lib_file) || die "can't read library file.\n";
@lib = <LIB>;
close LIB;
$total = @lib;
$total /= 2; 

open(OUT, $out_file) || die "can't read output file.\n";
@out = <OUT>;
close OUT;
$num = @out - 1;

print "$num out of $total templates are ranked.\n";
#clean up
`rm $query_file.svm`;
`rm $query_file.class`;


