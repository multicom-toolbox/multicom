#!/usr/bin/perl -w
###################################################################
#Evaluate all casp7 models
#Author: Jianlin Cheng
#Date: 10/12/2007
###################################################################

$model_dir = "/home/chengji/casp8/casp7_models";
-d $model_dir || die "can't find $model_dir.\n";

$spicker = "/home/chengji/software/spicker/spicker";

$seq_dir   = "/home/chengji/casp8/casp7_sequences";
-d $seq_dir || die "can't find $seq_dir.\n";

$eva_dir = "../model_eva";
-d $eva_dir || die "can't find $eva_dir.\n";

for ($i = 283; $i <= 386; $i++)
{

	if ($i != 307 && $i != 309 && $i != 314 && $i != 335 && $i != 348 && $i != 351 && $i != 354)
	{
		next;
	}
	
	$target = "T0$i";

	#copy casp7 models for one target and unzip it
	`cp $model_dir/$target.3D.srv.tar.gz .`;
	`tar xzf $target.3D.srv.tar.gz`; 

	`rm $target.3D.srv.tar.gz`; 
	#directory of holding all models for the target
	$tdir = "0$i";

	#run model evaluator on all targets to get scores
	$score_file = "$eva_dir/score_$target";

	`mkdir noclash_$target`;

	system("./script/cluster_casp_model_noclash.pl ./script/ $spicker $tdir $score_file $seq_dir/$target noclash_$target"); 	

}

