#!/usr/bin/perl -w

for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}



	$name = "0$i";
	print "do model combination for $name...\n";
	`mkdir coarse_T$name`;
	
	system("./script/global_local_human_coarse.pl ./$name/ ../casp7_sequences/T$name ../model_eva/T${name}all.ave coarse_T$name");


}




