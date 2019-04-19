#!/usr/bin/perl -w

for ($i = 285; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}


	print "do model combination...\n";

	$name = "0$i";
	
	system("./stx_model_comb.pl ~/software/tm_score/TMscore_32 ./$name/ ../model_eva/score_T$name ../casp7_sequences/T$name ./pir/T$name.pir 1.5 40 0.5");

	`mkdir comb_T$name`;

	print "generate model...\n";
	system("./pir2ts_energy.pl ~/software/prosys/modeller7v7/ ~/casp8/model_cluster/$name/ comb_T$name ./pir/T$name.pir  3");
}




