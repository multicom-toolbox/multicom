#!/usr/bin/perl -w
###################################################################
#evaluate the performance of ModelEvalutor on CASP7 models
#Author: Jianlin Cheng
#Date: 11/09/2007
###################################################################

$gdt_file = "casp7_gdt.txt";

open(GDT, $gdt_file) || die "can't open $gdt_file.\n";
@gdt = <GDT>;
close GDT;

@model2gdt = ();
while (@gdt)
{
	$line = shift @gdt;
	chomp $line;
	($model, $score) = split(/\s+/, $line);
	$model2gdt{$model} = $score;
}

$group_id_name = "casp7_group_name_id";

open(GROUP, $group_id_name) || die "can't read group file.\n"; 
@gname2id = ();
while (<GROUP>)
{
	$line = $_;
	chomp $line;	
	if ($line =~ /^(\d+)\s+(\S+)\s*/)
	{
#		print "$1 $2\n";
		$gname2id{$2} = $1; 
	}	
}

$total = 0;
$count = 0; 
for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}
	
	$target = "T0$i";

	$score_file = "consensus_$target";

	open(SCORE, $score_file) || die "can't open $score_file.\n";

	@scores = <SCORE>;
	close SCORE;

	$sel = 4;
	while (1)
	{ 
		$model1 = $scores[$sel]; 
		#if ($model1 =~ /3Dpro/ || $model1 =~ /ABIpro/ || $model1 =~ /Zhang-Server/)
		if ($model1 =~ /3Dpro/ || $model1 =~ /ABIpro/ )
		{
	#		$sel++;
	#		next;
		}
		chomp $model1; 
		$value = 0;
		($name, $value) = split(/\s+/, $model1);
		$len = length($name);		
		$num = substr($name, $len - 1, 1);
		$group = substr($name, 0, $len - 4);
		last;
	}

	if (! defined $gname2id{$group} )
	{
		die "group $group is not found.\n";
	}
	$id = $gname2id{$group}; 
	
	$model_name = $target;
	$model_name .= "TS$id"; 
	$model_name .= "_$num";

	#get the gdt ts score of the model
	if (! defined $model2gdt{$model_name})
	{
		die "can't find GDT score of $model_name of $group.\n";
	}

	$count++;
	$total += $model2gdt{$model_name}; 	
	print "GDT of $target: $model2gdt{$model_name}\n";
}

print "total number of targets: $count.\n";
print "total GDT-TS score: $total\n";




