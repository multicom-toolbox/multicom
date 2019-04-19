#!/usr/bin/perl -w
######################################################################
#Classify feature set using Support Vector Machines
#Input: prosys dir, feature dataset, output file, classification model(clustalw or lobster)
#Author: Jianlin Cheng
#Date: 8/22/05
######################################################################
if (@ARGV != 3 && @ARGV != 4)
{
	die "need 3 or 4 parameters: prosys dir, feature set, output file, classification model (clustalw or lobster: optional).\n";
}

$prosys_dir = shift @ARGV;
$feature_set = shift @ARGV;
$out_file = shift @ARGV;
$fr_stx_feature_alignment = "clustalw";
if (@ARGV > 0)
{
	$fr_stx_feature_alignment = shift @ARGV;
}
if ($fr_stx_feature_alignment ne "clustalw" && $fr_stx_feature_alignment ne "lobster" && $fr_stx_feature_alignment ne "lobster_sel" && $fr_stx_feature_alignment ne "muscle" && $fr_stx_feature_alignment ne "lobster_no_clustalw")
{
	die "alignment method for structure feature must be clustalw, lobster, muscle or lobster_sel: $fr_stx_feature_alignment (fold_classify.pl).\n";
}

-d $prosys_dir || die "prosys dir doesn't exist.\n";
-f $feature_set || die "feature set file is not found.\n";
print "Start classification using model of $fr_stx_feature_alignment...\n";

if ($fr_stx_feature_alignment eq "lobster")
{
	#system("$prosys_dir/server/svm_classify $feature_set $prosys_dir/model/fr/model_lobster $out_file");
	system("$prosys_dir/server/svm_classify $feature_set $prosys_dir/model/fr/model_remove_lob $out_file");
}
elsif ($fr_stx_feature_alignment eq "lobster_sel" || $fr_stx_feature_alignment eq "muscle")
{
	system("$prosys_dir/server/svm_classify $feature_set $prosys_dir/model/fr/model_lob_select.015 $out_file");
}
elsif ($fr_stx_feature_alignment eq "lobster_no_clustalw")
{
	system("$prosys_dir/server/svm_classify $feature_set $prosys_dir/model/fr/model_lob_no_clustalw $out_file");
}
else
{
	system("$prosys_dir/server/svm_classify $feature_set $prosys_dir/model/fr/model $out_file");
}
print "Done.\n";


