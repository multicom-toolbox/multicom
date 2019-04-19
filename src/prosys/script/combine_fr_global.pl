#!/usr/bin/perl -w
################################################################
#Combine significant template alignments with significant SVM
#FR scores. 
#Input: script_dir, work_dir, rank_file, svm_score_threshold,
#alignment_file_prefix, output_file
#Assumption: template pir files exist in work_dir
#If there are more than one significant tempaltes, a combined
#pir alignment is generated.
#Author: Jianlin Cheng
#Date: 1/10/2006
################################################################

if (@ARGV != 7)
{
	die "need seven parameters: script dir, work dir, rank file, svm score threshold, alignment_file_prefix (spem, mus, lob, hhs, com), max number to combine, output file.\n";
}

$script_dir = shift @ARGV;
$work_dir = shift @ARGV;
$rank_file = shift @ARGV;
$svm_score_threshold = shift @ARGV;
$align_prefix = shift @ARGV;
$max_num = shift @ARGV;
$output_file = shift @ARGV; 

-d $script_dir || die "can't find script dir:$script_dir.\n";
-d $work_dir || die "can't find work dir: $work_dir.\n";
-f $rank_file || die "can't find file $rank_file.\n";
$svm_score_threshold >= 0 || die "svm threshold must be non-negative.\n";
$max_num > 1 || die "max number must be greater than 1.\n";

open(RANK, $rank_file) || die "can't find rank file: $rank_file\n";
@rank = <RANK>;
close RANK;
shift @rank;

@select = ();

$count = 1;
while (@rank)
{
	$record = shift @rank;
	chomp $record; 
	@fields = split(/\s+/, $record);
	if ($fields[2] < $svm_score_threshold)
	{
		last;
	}

	$temp_name = $fields[1];

	open(PIR, "$work_dir/$align_prefix$count.pir") || die "can't find $work_dir/$align_prefix$count.pir.\n";
	@pir = <PIR>;
	close PIR;

	$info = $pir[1];
	chomp $info;
	@fields = split(/;/, $info);
	if ($fields[1] eq $temp_name)
	{
		push @select, "$align_prefix$count.pir";
	}

	$count++;

	if ($count > $max_num)
	{
		last;
	}
}
if (@select < 2)
{
	print "no more than one FR templates with SVM score bigger than $svm_score_threshold. No combination.\n";
	die "";	
}

$first = shift @select;
if (-f "$work_dir/$first")
{
	#`cp $work_dir/$first $output_file`; 
	open(PIR, "$work_dir/$first");
	@pir = <PIR>;
	close PIR;

	$idx = $#pir;

	open(OK, ">$output_file");
	print OK $pir[0];
	print OK $pir[1];
	print OK $pir[2];
	print OK $pir[3];
	print OK $pir[4];
	print OK $pir[$idx-3];
	print OK $pir[$idx-2];
	print OK $pir[$idx-1];
	print OK $pir[$idx];
	close OK;
}
else
{
	die ""; 
}
while (@select)
{
	$pir_temp = shift @select; 
	$pir_file = "$work_dir/$pir_temp";

	if (-f $pir_file)
	{
		open(PIR, $pir_file);
		@pir = <PIR>;
		close PIR;

		$idx = $#pir;

		$pir_file_ok = $pir_file . ".ok";
		open(OK, ">$pir_file_ok");
		print OK $pir[0];
		print OK $pir[1];
		print OK $pir[2];
		print OK $pir[3];
		print OK $pir[4];
		print OK $pir[$idx-3];
		print OK $pir[$idx-2];
		print OK $pir[$idx-1];
		print OK $pir[$idx];
		close OK;
		system("$script_dir/simple_gap_comb.pl $script_dir $output_file $pir_file_ok 0 $output_file > /dev/null");
		`rm $pir_file_ok`;
	}
}

