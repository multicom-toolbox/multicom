#!/usr/bin/perl -w
#combine domains based on compro ranking

if (@ARGV != 2)
{
	die "need two parameters: casp meta script dir (e.g. ~/casp8/meta/script/, casp prediction directory (e.g. ~/casp_roll/T0663) .\n";	
}

$script_dir = shift @ARGV;
-d $script_dir || die "can't read $script_dir.\n";
$model_dir = shift@ARGV;
-d $model_dir || die "can't read $model_dir.\n";

chdir $model_dir; 

@domain_dirs = (); 
@compo_dirs = (); 
for ($i = 0; $i < 6; $i++)
{
	$domain_dir = "$model_dir/domain$i";
	if (-d $domain_dir)
	{
		push @domain_dirs, $domain_dir; 
		$compo_dir = "$model_dir/domain$i-compo"; 
		`mkdir $compo_dir`; 
		push @compo_dirs, $compo_dir; 

		system("$script_dir/analyze_alignments_v2.pl $domain_dir/meta/ $domain_dir/meta/domain$i.align");
		system("$script_dir/gen_dashboard.pl $domain_dir/meta/ domain$i domain$i.dash");
		system("$script_dir/composite_eva_v2.pl $domain_dir/meta/ domain$i.dash $compo_dir");
	}
}
die "";
#combine domains
