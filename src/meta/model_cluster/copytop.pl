#!/usr/bin/perl -w
###################################################################
#Evaluate all casp7 models
#Author: Jianlin Cheng
#Date: 10/12/2007
###################################################################

$model_dir = "/home/chengji/casp8/casp7_models";
-d $model_dir || die "can't find $model_dir.\n";

$eva_dir = "../model_eva";
-d $eva_dir || die "can't find $eva_dir.\n";

for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}
	
	$target = "T0$i";

	#copy casp7 models for one target and unzip it
	#`cp $model_dir/$target.3D.srv.tar.gz .`;
	#`tar xzf $target.3D.srv.tar.gz`; 

	#`rm $target.3D.srv.tar.gz`; 
	#directory of holding all models for the target
	$tdir = "0$i";

	#run model evaluator on all targets to get scores
	$score_file = "$eva_dir/score_$target";

	open(SCORE, $score_file) || die "can't read $score_file.\n";;
	@score = <SCORE>;
	close SCORE;	
	shift @score;
	shift @score;
	shift @score;
	shift @score;
	while (@score)
	{
		$top = shift @score;
		if ($top =~ /ABIpro/ || $top =~ /3Dpro/)
		{
			next;
		}
		chomp $top;
		@fields = split(/\s+/, $top);
		system("cp $tdir/$fields[0] ./top_models/${target}_TS1"); 	
		last;
	}

}

