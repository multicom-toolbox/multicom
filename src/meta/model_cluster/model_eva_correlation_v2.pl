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

#correlation array
@corr = ();
@pre_gdt = ();
@true_gdt = ();

sub correlation
{
	my ($x, $y) = @_;
	my $res = 0; 
	my $x_ave = 0;
	my $y_ave = 0;
	my $xy = 0; 
	my $size = @$x; 
	if ($size != @$y) { die "size of two profiles doesn't equal in correlation.\n"; }; 
	my $x_len = 0;
	my $y_len = 0; 
	for (my $i = 0; $i < $size; $i++)
	{
		$x_ave += $x->[$i]; 	
		$y_ave += $y->[$i]; 
	}
	$x_ave /= $size; $y_ave /= $size; 
	for (my $i = 0; $i < $size; $i++)
	{
		$x_len += ($x->[$i] - $x_ave) * ($x->[$i] - $x_ave); 
		$y_len += ($y->[$i] - $y_ave) * ($y->[$i] - $y_ave); 
		$xy += ($x->[$i] - $x_ave) * ($y->[$i] - $y_ave); 
	}
	$x_len = sqrt($x_len); 
	$y_len = sqrt($y_len); 

	$res = $xy / ($x_len * $y_len); 
	if ($res < -1)
	{
		$res = -1; 
	}
	if ($res > 1)
	{
		$res = 1; 
	}
	return $res; 
}

#hard targets
@hard = (287, 296, 300, 304, 307, 309, 314, 316, 319, 321, 347, 348, 350, 353, 356, 361, 382, 386);

$count = 0; 

@easy_pre = ();
@easy_true = ();
@hard_pre = ();
@hard_true = ();

for ($i = 283; $i <= 386; $i++)
{

	if ($i == 294 || $i == 310 || $i == 336 || $i == 337 || $i == 343 || $i == 344 || $i == 352 || $i == 355 || $i == 377)
	{
		next;
	}
	
	$target = "T0$i";

	$score_file = "common_$target";

	open(SCORE, $score_file) || die "can't open $score_file.\n";

	@scores = <SCORE>;
	close SCORE;

	shift @scores; shift @scores; shift @scores; shift @scores;
	
	pop @scores;

	@pgdt = ();
	@tgdt = (); 

	$count = 0;
	while (@scores)
	{

		$model = shift @scores; 
		chomp $model; 

		$value = 0;
#		($name, $value) = split(/\s+/, $model);
	
		@fields = split(/\s+/, $model);
		$name = $fields[0];
		$value = $fields[1];
		$value *= 100; 

		$len = length($name);		

		if ($name =~ /\.pdb$/)
		{
			$group = substr($name, 0, $len - 8);
			$num = substr($name, $len - 5, 1);
		}
		else
		{
			$num = substr($name, $len - 1, 1);
			$group = substr($name, 0, $len - 4);
		}

		if (! defined $gname2id{$group} )
		{
#			warn "group $group is not found.\n";
			next;
		}
		$id = $gname2id{$group}; 
	
		$model_name = $target;
		if ($name =~ /\.pdb$/)
		{
			$model_name .= "AL$id";
		}
		else
		{
			$model_name .= "TS$id"; 
		}
		$model_name .= "_$num";

		#get the gdt ts score of the model
		if (! defined $model2gdt{$model_name})
		{
#			warn "can't find GDT score of $model_name of $group.\n";
			next;
		}

		$count++;
		push @pgdt, $value;
		push @tgdt, $model2gdt{$model_name};
	}

	$cor = &correlation(\@pgdt, \@tgdt);
	push @pre_gdt, @pgdt;
	push @true_gdt, @tgdt;

	#check if the target is hard
	$ishard = 0;
	foreach $abinitio (@hard)
	{
		if ($i == $abinitio)
		{
			$ishard = 1;
		}
	}
	if ($ishard == 1)
	{
		push @hard_pre, @pgdt;
		push @hard_true, @tgdt;
	}
	else
	{
		push @easy_pre, @pgdt;
		push @easy_true, @tgdt;
	}

	push @corr, $cor;

	print "$target: number of model = $count, correlation = $cor\n";

	$count++;
}

$cor = &correlation(\@pre_gdt, \@true_gdt);

print "overall correlation = $cor\n";

$tot = @corr;
$sum = 0;
foreach $cvalue (@corr)
{
	$sum += $cvalue;
}
print "average of correlation: ", $sum / $tot, "\n"; 


$cor = &correlation(\@easy_pre, \@easy_true);
print "correlation of easy targets = $cor\n";
$cor = &correlation(\@hard_pre, \@hard_true);
print "correlation of hard targets = $cor\n";




