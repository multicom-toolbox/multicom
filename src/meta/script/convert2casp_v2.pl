#!/usr/bin/perl -w
#######################################################
#Convert PDB models to CASP models
#Author: Jianlin Cheng
#Date: 4/17/2010
#######################################################

if (@ARGV != 5)
{
	die "need five parameters: prosys dir, meta dir, model dir, target name, fasta file.\n";
}

$prosys_dir = shift @ARGV;
$meta_dir = shift @ARGV;
$model_dir = shift @ARGV;
$target_name = shift @ARGV;
$fasta_file = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $model_dir || die "can't find $model_dir.\n";
-f $fasta_file || die "can't find $fasta_file.\n";

$count = 5; 
$pdb2casp1 = "$prosys_dir/script/pdb2casp.pl";
$pdb2casp2 = "$meta_dir/script/pdb2casp.pl";

$mdir = "$model_dir/full_length/meta";
$source_dir = $mdir; 
$out_dir = "$model_dir/cluster/";
`mkdir $out_dir`; 
print "Convert models in $mdir...\n"; 
open(EVA, "$mdir/meta.eva") || die "can't read $mdir/meta.eva\n";
@eva = <EVA>;
close EVA;

shift @eva;

`cp $mdir/meta.eva $out_dir`; 
$i = 1;
while ($i <= $count && @eva)
{
	$record = shift @eva;
	@fields = split(/\s+/, $record);
	$model_file = $fields[0];	
	$model_file =~ /(.+)\.pdb$/;
	$model_name = $1; 
	if ($model_name =~ /casp/)
	{
		next;
	}
	$pir_file = "$1.pir";
	$method = $fields[1]; 
	
	$model_file = "$mdir/$model_file";
	$pir_file = "$mdir/$pir_file"; 

	`cp $model_file $out_dir`; 
	if (-f $pir_file)
	{
		`cp $model_file $out_dir`; 
	}

	#repack the side chains 
	system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $out_dir/$model_name.pdb.scw >/dev/null");
	system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $out_dir/$model_name.pdb.scw > $out_dir/clash$i.txt");
	if ($method eq "cm" || $method eq "fr")
	{
		system("$pdb2casp1 $out_dir/$model_name.pdb.scw $pir_file $i $out_dir/casp$i.pdb");	
	}
	else
	{
		system("$pdb2casp2 $out_dir/$model_name.pdb.scw $i $target_name $out_dir/casp$i.pdb");	
	}

	$i++; 
	
}

print "Convert domain combined models to CASP format...\n";
$mdir = "$model_dir/comb/";
for ($i = 1; $i <= $count; $i++)
{
	$model_file = "$mdir/comb$i.pdb";	
	if (-f $model_file)
	{
		system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
		system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
		system("$pdb2casp2 $model_file.scw $i $target_name $mdir/casp$i.pdb");	
	}
} 
	
print "Convert full-length combined models to CASP format...\n";
$mdir = "$model_dir/mcomb/";
for ($i = 1; $i <= $count; $i++)
{
	$model_file = "$mdir/casp$i.pdb";	
	`mv $model_file $model_file.org`; 
	if (-f "$model_file.org")
	{
		system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file.org -o $mdir/casp$i.scw >/dev/null");
		system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $mdir/casp$i.scw > $mdir/clash$i.txt");
		system("$pdb2casp2 $mdir/casp$i.scw $i $target_name $mdir/casp$i.pdb");	
	}
} 

print "Convert refined models to CASP format...\n";
$mdir = "$model_dir/refine/";
$eva_file = "$mdir/$target_name.max";
if (-f $eva_file)
{
	open(EVA, $eva_file);
	@eva = <EVA>;
	close EVA;
	shift @eva;
	shift @eva;
	shift @eva;
	shift @eva;
	
	$i = 1; 
	while (@eva && 	$i <= $count)
	{
		$record = shift @eva;
		@fields = split(/\s+/, $record);
	
		$model_file = $fields[0]; 
		$model_file =~ /(.+)\.(\d+)\.pdb/;
		$model_name = $1; 
		$pir_file = "$source_dir/$model_name.pir";
		$model_file = "$mdir/$model_file";


		if (-f $pir_file && -f $model_file)
		{
			system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
			system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
			system("$pdb2casp1 $model_file.scw $pir_file $i $mdir/casp$i.pdb");	
		}
		elsif (-f $model_file) 
		{
			system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
			system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
			system("$pdb2casp2 $model_file.scw $i $target_name $mdir/casp$i.pdb");	
		}

		$i++; 
	}

}

print "Convert multi-level selected models to CASP format...\n";
$mdir = "$model_dir/select/";
for ($i = 1; $i <= $count; $i++)
{
	$model_file = "$mdir/select$i.pdb";	
	$pir_file = "$mdir/select$i.pir";
	if (-f $model_file)
	{

		if (-f $pir_file)
		{
			system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
			system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
			system("$pdb2casp1 $model_file.scw $pir_file $i $mdir/casp$i.pdb");	
		}
		elsif (-f $model_file) 
		{
			system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
			system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
			system("$pdb2casp2 $model_file.scw $i $target_name $mdir/casp$i.pdb");	
		}
#		system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
#		system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
#		system("$pdb2casp2 $model_file.scw $i $target_name $mdir/casp$i.pdb");	
	}
} 


print "Convert models for construction and center method ...\n"; 
$mdir = "$model_dir/full_length/meta";
$source_dir = $mdir; 
$out_dir = "$model_dir/cluster/";

open(EVA, "$mdir/$target_name.gdt") || die "can't read $mdir/$target_name.gdt\n";
@eva = <EVA>;
close EVA;

shift @eva;
shift @eva;
shift @eva;
shift @eva;


@layer1_model = ();
@layer1_pir = ();
@layer2_model = ();
@layer2_pir = ();
while (@eva)
{
	$record = shift @eva;
	@fields = split(/\s+/, $record);
	$model_file = $fields[0];	
	$model_file =~ /(.+)\.pdb$/;
	$model_name = $1; 
	$pir_file = "$1.pir";
	$method = $fields[1]; 
	
	$model_file = "$mdir/$model_file";
	$pir_file = "$mdir/$pir_file"; 
	
	if ($model_file =~ /construct0/)
	{
		push @layer1_model, $model_file;
		push @layer1_pir, $pir_file;
	}
	elsif ($model_file =~ /construct1/)
	{
		push @layer2_model, $model_file;
		push @layer2_pir, $pir_file;
	}
	elsif ($model_file =~ /construct2/)
	{
		push @layer2_model, $model_file;
		push @layer2_pir, $pir_file;
	}
	
	if ($model_file =~ /star0/)
	{
		push @layer1_model, $model_file;
		push @layer1_pir, $pir_file;
	}
	elsif ($model_file =~ /star1/)
	{
		push @layer2_model, $model_file;
		push @layer2_pir, $pir_file;
	}
	elsif ($model_file =~ /star2/)
	{
		push @layer2_model, $model_file;
		push @layer2_pir, $pir_file;
	}
	
	if ($model_file =~ /center0/)
	{
		push @layer1_model, $model_file;
		push @layer1_pir, $pir_file;
	}
	elsif ($model_file =~ /center1/)
	{
		push @layer2_model, $model_file;
		push @layer2_pir, $pir_file;
	}
	elsif ($model_file =~ /center2/)
	{
		push @layer2_model, $model_file;
		push @layer2_pir, $pir_file;
	}
	
	#consider hhserach models generated by CASP8 hhsearch program 
	if ($model_file =~ /hs1/ || $model_file =~ /hh1/ || $model_file =~ /com1/ || $model_file =~/multicom1/ || $model_file =~ /sam1/ || $model_file =~ /prc1/ || $model_file =~ /csiblast1/ || $model_file =~ /hmmer1/ || $model_file =~ /sp3_spem-comb/ || $model_file =~/ss1/ || $model_file =~ /psiblast1/ || $model_file =~ /csblast1/)
	{
		push @layer1_model, $model_file;
		push @layer1_pir, $pir_file;
	}



#	elsif ($model_file =~ /hs2/)
#	{
#		push @layer2_model, $model_file;
#		push @layer2_pir, $pir_file;
#	}

}


open(CONSTRUCT, ">$out_dir/construt.txt");
$i = 1; 
while (@layer1_model && $i <= 5)
{
	$model_file = shift @layer1_model;
	$pir_file = shift @layer1_pir; 
	print CONSTRUCT "$model_file\n";
	#repack the side chains 
	system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
	system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $out_dir/con_clash$i.txt");
	system("$pdb2casp1 $model_file.scw $pir_file $i $out_dir/con_casp$i.pdb");	
	$i++;
}
while (@layer2_model && $i <= 5)
{
	$model_file = shift @layer2_model;
	$pir_file = shift @layer2_pir; 
	print CONSTRUCT "$model_file\n";
	#repack the side chains 
	system("/home/chengji/software/scwrl4/Scwrl4 -i $model_file -o $model_file.scw >/dev/null");
	system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $model_file.scw > $out_dir/con_clash$i.txt");
	system("$pdb2casp1 $model_file.scw $pir_file $i $out_dir/con_casp$i.pdb");	
	$i++; 
}

close CONSTRUCT; 

