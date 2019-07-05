#!/usr/bin/perl -w
####################################################################
#Run model check 2 on the models in the model
#Inputs: query file, model dir, output dir, output file
#Author: Jianlin Cheng
####################################################################
use Cwd 'abs_path'; 
if (@ARGV != 5)
{
	die "need four parameters: query file in fasta foramt, input model dir, temporary feature dir, output model dir, output file.\n";  
}

$query_file = shift @ARGV; 
$model_dir = shift @ARGV;
$feature_dir = shift @ARGV; 
$output_dir = shift @ARGV; 
$output_file = shift @ARGV; 

$query_file = abs_path($query_file); 
$model_dir = abs_path($model_dir); 
$feature_dir = abs_path($feature_dir); 
$output_dir = abs_path($output_dir); 
$output_file = abs_path($output_file); 

opendir(MODEL, $model_dir) || die "can't read $model_dir.\n";
@models = readdir MODEL;
closedir MODEL; 
foreach $model (@models)
{
	if ($model =~ /\.pdb$/)
	{
		`ln $model_dir/$model $output_dir`; 
	}	
}

#generate features
system("/home/jh7x3/multicom_beta1.0/tools/model_check2/script/generate_input_v2.pl /home/jh7x3/multicom_beta1.0/tools/betacon/ /home/jh7x3/multicom_beta1.0/tools/pspro2/ /home/jh7x3/multicom_beta1.0/tools/disorder_new/ $query_file $feature_dir");

system("/home/jh7x3/multicom_beta1.0/tools/model_check2/script/casp_model_eva_full.pl /home/jh7x3/multicom_beta1.0/tools/betacon/ /home/jh7x3/multicom_beta1.0/tools/model_check2/ $query_file $feature_dir $output_dir $output_file");

`mv $feature_dir $output_dir`; 

