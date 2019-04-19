#!/usr/bin/perl -w

#for ($i = 285; $i <= 386; $i++)
for ($i = 385; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}



	$name = "0$i";
	print "do model combination for $name...\n";
	
	system("./stx_model_comb_global.pl ~/software/tm_score/TMscore_32 ./$name/ ../model_eva/T${name}all.ave ../casp7_sequences/T$name ./pir_global_ee/T$name.pir 2.5 0.8 0.5");

	`mkdir globalee_T$name`;

	print "generate model...\n";
	system("./pir2ts_energy.pl ~/software/prosys/modeller7v7/ ~/casp8/model_cluster/$name/ globalee_T$name ./pir_global_ee/T$name.pir  3");
}




