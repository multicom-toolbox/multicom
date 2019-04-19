#!/usr/bin/perl -w

for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}


	$name = "T0$i";
	print "do structure prediction for $name...\n";
	`cp /home/chengji/software/prosys/eval/casp7_sequences/$name .`;
	mkdir $i;
	
	system("./casp8_refine.cluster.pl /home/chengji/casp8/model_cluster/ $name $i");
	print "done.\n";

}

