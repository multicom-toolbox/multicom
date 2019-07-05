#!/usr/bin/perl -w
#############################################################
#Combine domains to generate a full length model
#Input: multicom output directory
#Author: Jianlin Cheng
#Date: 5/4/2010
#############################################################

if (@ARGV != 5)
{
	die "need 5 parameters: prosys_dir, modeller_dir,  fasta file, multicom output directory, and number of domains\n";
}

$prosys_dir = shift @ARGV;
-d $prosys_dir || die "can't find $prosys_dir.\n";
$modeller_dir = shift @ARGV;
-d $modeller_dir || die "can't find $modeller_dir.\n";

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find $fasta_file.\n";

open(FASTA, $fasta_file) || die "can't read $fasta_file.\n";
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

$comb_dir = $output_dir . "/comb/";
$atom_dir = $output_dir . "/comb/atom/";

@servers = ("refine", "novel", "construct");
#@ranks = ("max", "gdt", "tm");
@ranks = ("gdt", "tm", "max");

$template_pir = $comb_dir . "/comb1.pir";
-f $template_pir || die "can't find template pir file: $template_pir.\n";
open(PIR, $template_pir) || die "can't read $template_pir.\n";
@pir = <PIR>;
close PIR; 

`cp $template_pir $comb_dir/cluster.pir`;
`cp $comb_dir/comb1.pdb $comb_dir/cluster.pdb`; 

@pir == ($domain_num * 5 + 4) || die "domain number does not match template pir file.\n";

#construct a pir file for each server based on different ranking criteria
while (@servers)
{
	$server = shift @servers;
	$rank = shift @ranks;

	@comb_pir = @pir; 
	for ($i = 0; $i < $domain_num; $i++)
	{
		$domain_dir = $output_dir . "/domain$i/";	

		$meta_dir = $domain_dir . "/meta/";
		
		$rank_file = $meta_dir . "domain$i.$rank";	
		#get the model name		
		open(RANK, $rank_file) || die "can't read $rank_file.\n";
		@rank = <RANK>;
		close RANK; 	
		shift @rank;
		shift @rank;
		shift @rank;
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
		`cp -f $meta_dir/$model_file $atom_dir/$atom_name.atom`; 
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

@models = ("cluster", "refine", "novel", "construct");

foreach $model (@models)
{
	$model_file = "$comb_dir/$model.pdb";
	if (!-f $model_file)
	{
		next;
	}
	#call Scwrl4 to refine side chain
	#system("/home/casp13/MULTICOM_package/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
	system("/home/jh7x3/multicom_beta1.0/tools/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
	#system("/home/casp13/MULTICOM_package/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $comb_dir/clash-$model.txt");
	system("/home/jh7x3/multicom_beta1.0/src/meta/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $comb_dir/clash-$model.txt");

	#$pdb2casp2 = "/home/casp13/MULTICOM_package/casp8/meta/script/pdb2casp.pl";
	$pdb2casp2 = "/home/jh7x3/multicom_beta1.0/src/meta/script/pdb2casp.pl";
	#convert models to pdb format
	system("$pdb2casp2 $model_file.scw 1 $target_name $comb_dir/casp1-$model.pdb");	

	#copy the domains to replace other top models accordingly. 

	if ($model eq "cluster")
	{
		`mv $output_dir/cluster/casp1.pdb $output_dir/cluster/casp1.pdb.org`; 	
		`cp $comb_dir/casp1-$model.pdb $output_dir/cluster/casp1.pdb`; 
		`cp $comb_dir/clash-$model.txt $output_dir/cluster/clash1.txt`; 
	}	

	if ($model eq "construct")
	{
		`mv $output_dir/cluster/con_casp1.pdb $output_dir/cluster/con_casp1.pdb.org`; 	
		`cp $comb_dir/casp1-$model.pdb $output_dir/cluster/con_casp1.pdb`; 
		`cp $comb_dir/clash-$model.txt $output_dir/cluster/con_clash1.txt`; 
	}	


	if ($model eq "refine")
	{
		`mv $output_dir/mcomb/casp1.pdb $output_dir/mcomb/casp1.pdb.org`; 	
		`cp $comb_dir/casp1-$model.pdb $output_dir/mcomb/casp1.pdb`; 
		`cp $comb_dir/clash-$model.txt $output_dir/mcomb/clash1.txt`; 
	}	

	if ($model eq "novel")
	{
		`mv $output_dir/select/casp1.pdb $output_dir/select/casp1.pdb.org`; 	
		`cp $comb_dir/casp1-$model.pdb $output_dir/select/casp1.pdb`; 
		`cp $comb_dir/clash-$model.txt $output_dir/select/clash1.txt`; 
	}	

}

#process refined model (may need to copy these models to other servers)
print "copy refined model to construct...\n";
$refined_model = "$output_dir/refine/casp1.pdb";
if (-f "$refined_model")
{
	`mv $output_dir/cluster/con_casp1.pdb $output_dir/cluster/con_casp1.pdb.org2`; 	
	`cp $refined_model $output_dir/cluster/con_casp1.pdb`; 
	`cp $output_dir/refine/clash1.txt $output_dir/cluster/con_clash1.txt`; 
}



