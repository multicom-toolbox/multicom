#!/usr/bin/perl -w
#############################################################
#re-model ab initio models if necessary
#Author: Jianlin Cheng
#############################################################

$self = "/home/jh7x3/multicom_beta1.0/src/meta/script/self.pl";
$pdb2casp2 = "/home/jh7x3/multicom_beta1.0/src/meta/script/pdb2casp.pl";

if (@ARGV != 2)
{
	die "need two parameters: target name, output model dir.\n";
}

$target_name = shift @ARGV;

$output_dir = shift @ARGV;
-d $output_dir || die "can't find $output_dir.\n";

@targets = ("mcomb", "cluster", "select");


foreach $target (@targets)
{
	$target_dir = "$output_dir/$target";
	@prefixes = ("/casp", "/con_casp");

	print "process $target... ";

	foreach $prefix (@prefixes)
	{
		print "$prefix...\n";
		for ($i = 1; $i <= 5; $i++)
		{

			$casp_model = $target_dir . $prefix . "$i.pdb";  

			if (! -f $casp_model)
			{
				warn "$casp_model is not found. Skip.\n";
				next;
			}

			open(CASP, $casp_model);
			@casp = <CASP>;
			close CASP; 
			$is_abinitio = 0; 
			foreach $line (@casp)
			{
				if ($line =~ /^ATOM/)
				{
					if ($line =~ /0\.000\s+0\.000\s+0\.000\s+/)
					{
						$is_abinitio = 1; 
					}
					last;
				}		
			}
			if ($is_abinitio == 1)
			{
				print "remodel the ab initio model $casp_model...\n";
				printf "$self $casp_model self$target_name\n";
				system("$self $casp_model self$target_name");
				#$casp_model.self");
				`mv self$target_name.pdb $casp_model.self.pdb`; 
				`mv $casp_model $casp_model.abi`; 
				system("/home/jh7x3/multicom_beta1.0/tools/scwrl4/Scwrl4 -i $casp_model.self.pdb -o $casp_model.self.scw  >/dev/null");
				system("$pdb2casp2 $casp_model.self.scw $i $target_name $casp_model");	
			
			}
			else
			{
				print "not an abinitio model, no re-modeling...\n";
			}
		}
	}
}


