#!/usr/bin/perl -w
#filter out identical muster, nnnd, lomets models 
$tm_score = "/home/casp13/MULTICOM_package/software/tm_score2/TMscore"; 
if (@ARGV !=1)
{
	die "need one parameters: muster model dir.\n";
}


$muster_model_dir = shift @ARGV;
-d $muster_model_dir || die "can't find muster model dir.\n";
chdir $muster_model_dir; 

@to_remove = ("nnnd", "lomets"); 

foreach $prefix (@to_remove)
{

for ($i = 1; $i <= 10; $i++)
{
	$model_a = "$prefix$i.pdb";
	#check if the model is similar to previous model of the same group 
	$removed = 0;

	if (! -f $model_a)
	{
		next;
	}

	for ($j = 1; $j <= 10; $j++)
	{
		$model_b = "muster$j.pdb";
		if (-f $model_b)	
		{
			#compare two models
			$fstubname = "musternnd$i$j";
			system("$tm_score $model_a $model_b > $fstubname.out");
			open(RES, "$fstubname.out") || die "can't read $fstubname.out\n";
			@res = <RES>;
			close RES;
			`rm $fstubname.out`; 
			foreach $line (@res)
			{
				if ($line =~ /^GDT-TS-score= ([\d\.]+) /)
				{
					$gdt_score = $1; 
					if ($gdt_score > 0.99)
					{
						$removed = 1; 
						print "Two models ($model_a, $model_b) are similar: score = $gdt_score\n";
						`mv $model_a $model_a.rm`; 
						`mv $prefix$i.pir $prefix$i.pir.rm`; 
						last;
					}	
				}
			}

		}
	}

}

}



