#!/usr/bin/perl -w
#############################################################################
#Inputs: cm_option, fr_option, eva_option, sequence, output dir.
#Ouput: five casp models
#Author: Jianlin Cheng
#Date: 3/3/2007
#############################################################################

if (@ARGV != 5)
{
	die "need five parameters: cm_option, fr_option, eva_option, sequence file, output dir.\n";
}

$cm_option = shift @ARGV;
-f $cm_option || die "can't read $cm_option.\n";
$fr_option = shift @ARGV;
-f $fr_option || die "can't read $fr_option.\n";
$eva_option = shift @ARGV;
-f $eva_option || die "can't read $eva_option.\n";
$seq_file = shift @ARGV;
-f $seq_file || die "can't read $seq_file.\n";

open(SEQ, $seq_file);
@seq = <SEQ>;
close SEQ;
$name = shift @seq;
chomp $name;
$name = substr($name, 1);
$sequence = shift @seq;
chomp $sequence;
$len = length($sequence);

$out_dir = shift @ARGV;
-d $out_dir || die "can't open $out_dir.\n";

#1. call multicom-cm
#system("/home/casp13/MULTICOM_package/software/prosys/script/multicom_cm.pl $cm_option $seq_file $out_dir");
system("/home/jh7x3/multicom_beta1.0/src/prosys/script/multicom_cm.pl $cm_option $seq_file $out_dir");

#2. evaluate multicom-cm
#$cm_sel = `/home/casp13/MULTICOM_package/software/prosys/script/evaluate_cm_ha_models.pl $out_dir $name $out_dir/$name.cm.eva`;
$cm_sel = `/home/jh7x3/multicom_beta1.0/src/prosys/script/evaluate_cm_ha_models.pl $out_dir $name $out_dir/$name.cm.eva`;

@models = ();
@select = split(/\n+/, $cm_sel); 
if (@select > 0)
{
	shift @select;
}
while (@select)
{
	$line = shift @select;
	@fields = split(/\s+/, $line);	
	push @models, $fields[0];
}

#3. decide if multicom-fr should be called

if (@models < 5)
{
	#system("/home/casp13/MULTICOM_package/software/prosys/script/multicom_fr.pl $fr_option $seq_file $out_dir");
	system("/home/jh7x3/multicom_beta1.0/src/prosys/script/multicom_fr.pl $fr_option $seq_file $out_dir");
}

#4. evaluate all models
#system("/home/casp13/MULTICOM_package/software/prosys/script/score_models.pl $eva_option $seq_file $out_dir");
system("/home/jh7x3/multicom_beta1.0/src/prosys/script/score_models.pl $eva_option $seq_file $out_dir");
#system("/home/casp13/MULTICOM_package/software/prosys/script/energy_models_proc.pl $eva_option $seq_file $out_dir");
system("/home/jh7x3/multicom_beta1.0/src/prosys/script/energy_models_proc.pl $eva_option $seq_file $out_dir");
#system("/home/casp13/MULTICOM_package/software/prosys/evaluate_models.pl /home/casp13/MULTICOM_package/software/prosys/ $out_dir $seq_file ./$out_dir/$name.fr.eva");
system("/home/jh7x3/multicom_beta1.0/src/prosys/evaluate_models.pl /home/jh7x3/multicom_beta1.0/src/prosys/ $out_dir $seq_file ./$out_dir/$name.fr.eva");

#5. select more models in addition to selected cm models if available
open(FR, "$name.fr.eva") || die "can't read ./$out_dir/$name.fr.eva\n";
@fr = <FR>;
close FR;

shift @fr;

while (@fr)
{
	$line = shift @fr;
	chomp $line;
	@fields = split(/\s+/, $line);
	$model = $fields[0];

	$rclash = $fields[11];
	$sclash = $fields[12];
	
	if ($rclash > 15 || $sclash > 0 || $rclash > 0.1 * $len)
	{
		next;
	}

	$found = 0;

	foreach $ent (@models)
	{
		if ($ent eq $model)
		{
			$found = 1;
			last;
		}
	}
	if ($found == 0)
	{
		push @models, $model;
	}
}


#use scwrl to convert selected models and convert them into casp format

open(SEL, ">$out_dir/final.sel");

for ($i = 0; $i < 5; $i++)
{
	$idx = $i + 1;
	$model = $models[$i];
	$ridx = rindex($model, ".");
	$prefix = substr($model, 0, $ridx);

	#convert model using scwrl
	#system("/home/casp13/MULTICOM_package/software/scwrl/scwrl3 -i $out_dir/$model -o $out_dir/$name-$idx.pdb >/dev/null");
	system("/home/jh7x3/multicom_beta1.0/tools/scwrl4/Scwrl4-i $out_dir/$model -o $out_dir/$name-$idx.pdb >/dev/null");

	#generate casp model for submission
	#system("/home/casp13/MULTICOM_package/software/prosys/script/pdb2casp.pl $out_dir/$name-$idx.pdb $out_dir/$prefix.pir $idx $out_dir/casp$idx.pdb");
	system("/home/jh7x3/multicom_beta1.0/src/prosys/script/pdb2casp.pl $out_dir/$name-$idx.pdb $out_dir/$prefix.pir $idx $out_dir/casp$idx.pdb");

	print SEL $model, "\n";
}

close SEL;





