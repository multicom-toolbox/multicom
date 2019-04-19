#!/usr/bin/perl -w
###################################################################
#Evaluate all casp7 models
#Author: Jianlin Cheng
#Date: 10/12/2007
###################################################################

$cur_dir = "~/casp8/model_cluster/";

$num = 0;
for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}
	
	$dir = "oT0$i";


	chdir $dir;
	if (! -f "closc1.pdb")
	{
		print "$dir\n";
		`~/software/spicker/spicker`;
		
	}

	$num++;

	chdir $cur_dir;
}

print "num = $num\n";





