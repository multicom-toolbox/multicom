#!/usr/bin/perl -w
#####################################################################
#Combine cm, fr, and ab
#input: script dir, modeller dir, min cover size, query fasta, ab dir, cm_fr dir
#output: output files (if exist): cm_fr_ab.pdb, cm_ab.pdb, frcom_ab.pdb
#fr1_ab.pdb are generated in cm_fr dir.
#Assumption: query name in fasta file is used to identify the ab models
#Author: Jianlin Cheng
#Date: 1/30/2006
#####################################################################
if (@ARGV != 7)
{
	die "need 7 parameters: script dir, modeller dir, minimum cover size(15), query fasta file, ab-initio dir, cm_fr_dir, number of model to simulate\n";
}
$script_dir = shift @ARGV;
$modeller_dir = shift @ARGV;
$min_cover_size = shift @ARGV;
$fasta_file = shift @ARGV;
$ab_dir = shift @ARGV;
$cm_fr_dir = shift @ARGV;
$model_num = shift @ARGV;

-d $script_dir || die "can't find $script_dir\n";
-d $modeller_dir || die "can't find $modeller_dir\n";
$min_cover_size >= 5 || die "minimum cover size must be greater than 5.\n";
-d $ab_dir || die "can't find $ab_dir\n";
-d $cm_fr_dir || die "can't find $cm_fr_dir\n";
$model_num > 0 || die "model number must be greater than 0\n";

open(FASTA, $fasta_file) || die "can't read $fasta_file\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$seq = <FASTA>;
chomp $seq; 
close FASTA;

#check consistency of ab-initio models
$ab1 = "$ab_dir/$name.1.pdb";
$ab2 = "$ab_dir/$name.2.pdb";
$res = `$script_dir/comp_pdb_fasta.pl $fasta_file $ab1`;  
if ($res ne "same")
{
	die "ab initio model 1 has different sequence as query fasta file. stop.\n";
}
$res = `$script_dir/comp_pdb_fasta.pl $fasta_file $ab2`;  
if ($res ne "same")
{
	die "ab initio model 2 has different sequence as query fasta file. stop.\n";
}

#copy ab-initio models
`cp $ab1 $cm_fr_dir/ab1.pdb`; 
`cp $ab1 $cm_fr_dir/ab1.atm`; 
`cp $ab2 $cm_fr_dir/ab2.pdb`; 

$len = length($seq);
#generate self alignment for ab-initio model
open(PIR, ">$cm_fr_dir/ab1.pir") || die "can't create pir alignment for ab1\n"; 
print PIR "C;self pir alignment for ab-initio model 1\n";
print PIR ">P1;ab1\n";
print PIR "structureM:ab1: 1: : $len: : : : : \n";
print PIR "$seq*\n";
print PIR "\n";

print PIR "C;query\n";
print PIR ">P1;$name\n";
print PIR " : : : : : : : : : \n";
print PIR "$seq*\n";
close PIR; 
$ab_pir = "$cm_fr_dir/ab1.pir";

#generate combined alignments
@combs = ("cmfr", "cm", "frcom", "fr1", "fr2", "fr3");
while (@combs)
{
	$prefix = shift @combs;
	$target_pir = "$cm_fr_dir/$prefix.pir";
	if (! -f $target_pir)
	{
		next; 
	}
	print "combine $prefix with ab-initio model\n";
	system("$script_dir/analyze_pir_align.pl $target_pir > $cm_fr_dir/ab.bit1");

	#combine the alignments 
	$out_pir = "$cm_fr_dir/${prefix}_ab.pir";
	system("$script_dir/combine_pir_align_adv_join.pl $script_dir $target_pir $ab_pir $min_cover_size 1 -1 $out_pir");

	system("$script_dir/analyze_pir_align.pl $out_pir > $cm_fr_dir/ab.bit2");

	open(BIT1, "$cm_fr_dir/ab.bit1");
	$bit1 = <BIT1>;
	close BIT1;
	open(BIT2, "$cm_fr_dir/ab.bit2");
	$bit2 = <BIT2>;
	close BIT2;
	if ($bit1 ne $bit2) #means: some new alignment is added.
	{
		print "generate model using $out_pir\n";
		system("$script_dir/pir2ts_simple.pl $modeller_dir $cm_fr_dir $cm_fr_dir $out_pir $model_num > $cm_fr_dir/${prefix}_ab.eng");
		$model_name = "$cm_fr_dir/$name.pdb";
		if (-f $model_name)
		{
			print "a model: ${prefix}_ab.pdb is generated.\n";
			`mv $model_name $cm_fr_dir/${prefix}_ab.pdb`; 
		}
		else
		{
			print "fail to generate a model.\n";
		}
	}
	else
	{
		`rm $out_pir`; 
		print "no new fragments are added. no new model is generated.\n";
	}
}

