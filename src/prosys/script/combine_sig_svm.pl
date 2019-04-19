#!/usr/bin/perl -w
################################################################
#Combine significant template alignments with significant SVM
#FR scores. 
#Input: script_dir, work_dir, rank_file, svm_score_threshold,
#output_file
#Assumption: template pir files exist in work_dir
#If there are more than one significant tempaltes, a combined
#pir alignment is generated.
#Author: Jianlin Cheng
#Date: 1/10/2006
################################################################

if (@ARGV != 5)
{
	die "need five parameters: script dir, work dir, rank file, svm score threshold, output file.\n";
}

$script_dir = shift @ARGV;
$work_dir = shift @ARGV;
$rank_file = shift @ARGV;
$svm_score_threshold = shift @ARGV;
$output_file = shift @ARGV; 

-d $script_dir || die "can't find script dir:$script_dir.\n";
-d $work_dir || die "can't find work dir: $work_dir.\n";
-f $rank_file || die "can't find file $rank_file.\n";
$svm_score_threshold >= 0 || die "svm threshold must be non-negative.\n";

open(RANK, $rank_file) || die "can't find rank file: $rank_file\n";
@rank = <RANK>;
close RANK;
shift @rank;

$positive_threshold = 0;
@select = ();
@backup = (); 
while (@rank)
{
	$record = shift @rank;
	chomp $record; 
	@fields = split(/\s+/, $record);
	if ($fields[2] > $svm_score_threshold)
	{
		push @select, $fields[1];
	}
	elsif ($fields[2] > $positive_threshold)
	{
		push @backup, $fields[1]; 
	}


}
if (@select < 2)
{
	print "no more than one FR templates with SVM score bigger than $svm_score_threshold. No combination.\n";
	die "";	
}

$first = shift @select;
if (-f "$work_dir/$first.pir")
{
	`cp $work_dir/$first.pir $output_file`; 
}
else
{
	die ""; 
}
while (@select)
{
	$pir_temp = shift @select; 
	$pir_file = "$work_dir/$pir_temp.pir";
	if (-f $pir_file)
	{
		system("$script_dir/simple_gap_comb.pl $script_dir $output_file $pir_file 0 $output_file > /dev/null");
	}
}

$min_cover_size = 15; 
while (@backup)
{
	$pir_temp = shift @backup; 
	$pir_file = "$work_dir/$pir_temp.pir";
	if (-f $pir_file)
	{
		system("$script_dir/simple_gap_comb.pl $script_dir $output_file $pir_file $min_cover_size $output_file > /dev/null");
	}
}
