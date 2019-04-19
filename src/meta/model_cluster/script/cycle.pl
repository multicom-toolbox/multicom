#!/usr/bin/perl -w
#######################################################################
#Cluster a banch of models ranked by model_check or model_energy
#get closet model to the centroid of each cluster
#use closet model as start point to build a combined model using
#global and local alignments
#Input: spicker program, psi-pred dir, model dir file, model rank file
#FASTA sequence, output dir
#Date: 3/24/2008.
#Author: Jianlin Cheng
#######################################################################

if (@ARGV != 6)
{
	die "need six parameters: model cluster script dir, spicker program, model dir file, model rank file (ave ranking score file), FASTA sequence, and output file.\n";
}

$cluster_dir = shift @ARGV;
use Cwd 'abs_path';
$cluster_dir = abs_path($cluster_dir);

$spicker = shift @ARGV;
$model_dir = shift @ARGV;
$model_rank_file = shift @ARGV;
$fasta_file = shift @ARGV;
$out_file = shift @ARGV;

$out_file = abs_path($out_file);

$out_dir = "$out_file-dir";
mkdir $out_dir;

-d $cluster_dir || die "can't open $cluster_dir.\n";
-f $spicker || die "$spicker is not found.\n";
-d $model_dir || die "can't find $model_dir.\n";

-f $model_rank_file || die "can't find $model_rank_file.\n";
-f $fasta_file || die "can't find $fasta_file.\n";
-d $out_dir || die "can't find $out_dir.\n";

$pulchar = "$cluster_dir/pulchar";
-f $pulchar || die "can't find $pulchar.\n";
$modeller = "$cluster_dir/pir2ts_energy.pl";
-f $modeller || die "can't find $modeller.\n";
#$clash = "$cluster_dir/clash_check.pl ";

#change to absoluate path
use Cwd 'abs_path';
$spicker = abs_path($spicker);
$model_dir = abs_path($model_dir);
$model_rank_file = abs_path($model_rank_file);
$fasta_file = abs_path($fasta_file);

@rank_list = ();
$i = 1;
while (1)
{
	print "round $i\n";
	system("$cluster_dir/cyclone.pl $cluster_dir $spicker $model_dir $model_rank_file $fasta_file $out_file");
	open(ROUND, "$out_file.round") || die "can't read round file.\n";
	@list = <ROUND>;
	close ROUND;
	open(RANK, $out_file) || die "can't read $out_file.\n";
	@rank = <RANK>;
	close RANK;

	push @rank_list, @list;
	$a = @rank_list;
	$b = @rank;
	print "ranked num = $a; not ranked num = $b\n";

	if (@rank_list > @rank)
	{
		last;
	}
	`rm $out_file.round`;
	$i++;
	$model_rank_file = $out_file;
}

open(OUT, ">$out_file");
print OUT shift @rank;
print OUT shift @rank;
print OUT shift @rank;
print OUT shift @rank;
print OUT join("", @rank_list);
print OUT join("", @rank);
close OUT;

#combine energy file
system("$cluster_dir/combine_eva_energy.pl $model_rank_file $out_file $out_file");



