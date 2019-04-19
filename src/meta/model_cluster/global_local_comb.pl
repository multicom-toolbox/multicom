#!/usr/bin/perl -w

#for ($i = 285; $i <= 386; $i++)
for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}



	$name = "0$i";
	print "do global model combination for $name...\n";
	
	system("./stx_model_comb_global.pl ~/software/tm_score/TMscore_32 ./$name/ ../model_eva/T${name}all.ave ../casp7_sequences/T$name ./pir_global_local/T$name.pir 2.5 0.8 0.5");

	#check if at least two templates are in pir file
	open(PIR, "./pir_global_local/T$name.pir") || die "can't read ./pir_global_local/T$name.pir\n";
	@pir = <PIR>;
	close PIR;
	$length = 80;
	$gdt = 0.5;
	
	while (@pir < 10)
	{
		print "less than two templates, do local model combination...\n";
		system("./stx_model_comb.pl ~/software/tm_score/TMscore_32 ./$name/ ../model_eva/T${name}all.ave ../casp7_sequences/T$name ./pir_global_local/T$name.pir 2.5 $length $gdt");

		open(PIR, "./pir_global_local/T$name.pir") || die "can't read ./pir_global_local/T$name.pir\n";
		@pir = <PIR>;
		close PIR;

		$length -= 5;
		$gdt -= 0.02;
		if ($length <= 0 || $gdt <= 0)
		{
			print "not able to get a local alignment.\n";
			last;
		}
	}

	`mkdir global_local_T$name`;

	print "generate model...\n";
	system("./pir2ts_energy.pl ~/software/prosys/modeller7v7/ ~/casp8/model_cluster/$name/ global_local_T$name ./pir_global_local/T$name.pir  3");
}




