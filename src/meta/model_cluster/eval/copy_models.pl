#!/usr/bin/perl -w

for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}


	system("cp ./$i/refine/casp1.pdb refine/T0$i.pdb");
	system("cp ./$i/con/casp1.pdb con/T0$i.pdb");
	system("cp ./$i/cluster/casp1.pdb cluster/T0$i.pdb");

}

