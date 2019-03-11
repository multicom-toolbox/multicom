#!/usr/bin/perl -w
####################################################################
#Evaluate models using pairwise approach
#Author: Jianlin Cheng
#Start date: 1/17/2010
#################################################################### 

if (@ARGV != 6)
{
	die "need six parameters: input model dir, fasta sequence file, pairwise_QA path, tm_score path, target name (output name), output dir.\n";
}

$model_dir = shift @ARGV;
use Cwd 'abs_path';
$model_dir = abs_path($model_dir);
-d $model_dir || die "can't find $model_dir.\n";
$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find $fasta_file.\n";
$pairwiseQA = shift @ARGV;
-f $pairwiseQA || die "can't find $pairwiseQA.\n";
$tm_score = shift @ARGV;
-f $tm_score || die "can't find $tm_score.\n";
$output_name = shift @ARGV;
$output_dir = shift @ARGV; 
-d $output_dir || die "can't find $output_dir.\n"; 

opendir(MDIR, $model_dir) || die "can't read $model_dir.\n";
@models =  readdir(MDIR);
close MDIR; 
open(LIST, ">$output_name.list") || die "can't create file $output_name.list.\n"; 
while (@models)
{
	$model = shift @models;
	if ($model =~ /\.pdb$/)
	{
		$model = "$model_dir/$model";
		print LIST "$model\n";
	}
}
close LIST; 

#call the pairwise QA program
system("$pairwiseQA $output_name.list $fasta_file $tm_score $output_dir $output_name >/dev/null");












