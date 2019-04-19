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

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}
	
	$target = "T0$i";

	$score_file = "$eva_dir/score_$target";

	$tdir = "0$i";

	#system("./script/consensus_qa.pl ./script/ $spicker $tdir $score_file $seq_dir/$target consensus_$target"); 	
	system("./script/consensus_qa_top7.pl ./script/ $spicker $tdir $score_file $seq_dir/$target common7_$target"); 	
}

