#!/usr/bin/perl -w
#############################################################
#Combine domains to generate a full length model
#Input: multicom output directory
#Author: Jianlin Cheng
#Date: 5/4/2010
#############################################################

if (@ARGV != 5)
{
	die "need 5 parameters: prosys_dir (/home/chengji/software/prosys/), modeller_dir (/home/chengji/software/modeller9v7/),  fasta file, multicom output directory (~/casp_roll/T0663), and number of domains\n";
}

$prosys_dir = shift @ARGV;
-d $prosys_dir || die "can't find $prosys_dir.\n";
$modeller_dir = shift @ARGV;
-d $modeller_dir || die "can't find $modeller_dir.\n";

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find $fasta_file.\n";

open(FASTA, $fasta_file) || die "can't open $fasta_file.\n";
@fasta = <FASTA>;
close FASTA;
$target_name = shift @fasta;
chomp $target_name;
$target_name = substr($target_name, 1); 

$output_dir = shift @ARGV;
-d $output_dir || die "can't find $output_dir.\n";
$domain_num = shift @ARGV;

use Cwd 'abs_path'; 
$prosys_dir = abs_path($prosys_dir);
$modeller_dir = abs_path($modeller_dir);
$output_dir = abs_path($output_dir);

$comb_dir = $output_dir . "/compo_domain/";
`mkdir $comb_dir`; 
$atom_dir = $output_dir . "/compo_domain/atom/";
`mkdir $atom_dir`; 

@servers = ("construct");
#@ranks = ("max", "gdt", "tm");
@ranks = ("compob.eva");

$template_pir = "$output_dir/comb/comb1.pir";
-f $template_pir || die "can't find template pir file: $template_pir.\n";
open(PIR, $template_pir) || die "can't read / open $template_pir.\n";
@pir = <PIR>;
close PIR; 
@pir == ($domain_num * 5 + 4) || die "domain number does not match template pir file.\n";

#construct a pir file for each server based on different ranking criteria
while (@servers)
{
	$server = shift @servers;
	print "process $server domain compo combination...\n";
	$rank = shift @ranks;

	@comb_pir = @pir; 
	for ($i = 0; $i < $domain_num; $i++)
	{
		#$domain_dir = $output_dir . "/domain$i/";	

		$meta_dir = $output_dir . "/domain$i/" . "meta/";

		$rank_file = "$output_dir/domain$i-compo/$rank";
		
		#get the model name		
		open(RANK, $rank_file) || die "can't read rank file: $rank_file.\n";
		@rank = <RANK>;
		close RANK; 	
		shift @rank;
		$info = shift @rank; 
		@fields = split(/\s+/, $info); 
		$model_file = $fields[0]; 
		@fields = split(/\./, $model_file);
		$model_name = $fields[0]; 
		$atom_name = $model_name . "_dom$i";
		#change pir array 
		$stx_name = ">P1;$model_name\n";	
		$comb_pir[$i * 5 + 1] = $stx_name;
		$stx_info = $comb_pir[$i * 5 + 2]; 
		@fields = split(/:/, $stx_info);
		$fields[1] = $atom_name;
		$stx_info = join(":", @fields);
		$comb_pir[$i * 5 + 2] = $stx_info; 
		#copy the model file to atom directory	
		#`cp -f $meta_dir/$model_file $atom_dir/$model_name.atom`; 
		`cp -f $meta_dir/$model_file.pdb $atom_dir/$atom_name.atom`; 
		#`gzip -f $atom_dir/$model_name.atom`; 
		`gzip -f $atom_dir/$atom_name.atom`; 
	}

	#set query name
	$tot = @comb_pir;
	$comb_pir[$tot - 3] = ">P1;$server\n";

	#write pir array into a file 
	$pir_file = "$comb_dir/$server.pir";
	open(PIR, ">$pir_file") || die "can't create $pir_file\n";
	print PIR join("", @comb_pir);
	close PIR; 
	#generate a model from the pir file
	
	print "Use Modeller to generate models to combine multiple domains for $server\n";
	system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $comb_dir $pir_file 5"); 		
	
	if (-f "$comb_dir/$server.pdb")
	{
		print "A combined model $comb_dir/$server.pdb was generated.\n";
	}	
}

print "repack side chain and copy models to cluster, refine, novel and construct...\n";

@models = ("construct");

foreach $model (@models)
{
	$model_file = "$comb_dir/$model.pdb";
	if (!-f $model_file)
	{
		next;
	}
	#call Scwrl4 to refine side chain
	system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
	system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $comb_dir/clash-$model.txt");

	$pdb2casp2 = "/home/chengji/casp8/meta/script/pdb2casp.pl";
	#convert models to pdb format
	system("$pdb2casp2 $model_file.scw 1 $target_name $comb_dir/casp1-$model.pdb");	

	#copy the domains to replace other top models accordingly. 

	if ($model eq "construct")
	{
		`mv $output_dir/compo/caspb1.pdb $output_dir/compo/caspb1.pdb.org`; 	
		`cp $comb_dir/casp1-$model.pdb $output_dir/compo/caspb1.pdb`; 
		`cp $comb_dir/clash-$model.txt $output_dir/compo/caspb1.txt`; 
	}	

}



