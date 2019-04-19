#!/usr/bin/perl -w
###################################################################
#Evaluate all casp7 models
#Author: Jianlin Cheng
#Date: 10/12/2007
###################################################################

#copy models
`mkdir cluster`;
$num =0;
for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}
	
	$dir = "oT0$i";


	for ($j = 1; $j <= 10; $j++)
	{

		if (-f "$dir/closc$j.pdb")
		{
			`cp $dir/closc$j.pdb ./cluster/T0$i-closc$j.pdb`;
			`cp $dir/combo$j.pdb ./cluster/T0$i-combo$j.pdb`;
		}
	}	

	if (-f "$dir/closc1.pdb")
	{
		$num++;
	}
	else
	{
		print "model 1 is not found for $dir.\n";
	}
}

print "number of target 1 = $num\n";

#conver predicted models into zhang format
`mkdir clusterz`;
system("./pre2zhang_dir.pl ~/work/zhang_targets_full/ cluster clusterz");

print "evaluate models....\n";
system("./eval_zhang_pre_fullname.pl ~/work/zhang_targets_full/ clusterz");




