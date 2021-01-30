#!/usr/bin/perl -w
#######################################################################
#score predicted 3D models (cm, fr, and ab)
#Input: option file, target_fasta_file, input / output_dir
#output will be name.score
#Including the following scores: 
#model_name, method, top_template name, coverage, identity,
#blast-evalue, svm_score, hhs score, compress score, ssm score
#ssa match score, clashes, model check score, model energy score
#Author: Jianlin Cheng
#Date: 1/17/2008
#######################################################################
if (@ARGV != 3)
{
	die "need three parameters: option file, target fasta file, input/output dir.\n";
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV; 

use Cwd 'abs_path';
$fasta_file = abs_path($fasta_file);
$work_dir = abs_path($work_dir);

-d $work_dir || die "can't read $work_dir.\n";

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^model_check_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$model_check_dir = $value; 
	}

	if ($line =~ /^model_energy_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$model_energy_dir = $value; 
	}

	if ($line =~ /^betacon_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$betacon_dir = $value; 
	}

	if ($line =~ /^pspro_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pspro_dir = $value; 
	}

	if ($line =~ /^betapro_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$betapro_dir = $value; 
	}
}
-d $prosys_dir || die "can't find $pspro_dir.\n";
-d $model_check_dir || die "can't find $model_check_dir.\n";
-d $model_energy_dir || die "can't find $model_energy_dir.\n";
-d $betacon_dir || die "can't find $betacon_dir.\n";
-d $pspro_dir || die "can't find $pspro_dir.\n";
-d $betapro_dir || die "can't find $betapro_dir.\n";

#read fasta file
open(FASTA, $fasta_file) || die "can't read $fasta_file\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$seq = <FASTA>;
chomp $seq;
close FASTA;

-d $work_dir || die "can't find $work_dir.\n"; 


opendir(WORK, $work_dir) || die "can't open $work_dir.\n";
@files = readdir WORK;
closedir WORK;

chdir $work_dir;

`cp $fasta_file $name.FASTA`;

print "generate features for model energy...\n";
#system("$model_energy_dir/script/generate_feature.pl $model_energy_dir $pspro_dir $betapro_dir $fasta_file $name.pxml >/dev/null 2>/dev/null");
system("$model_energy_dir/script/generate_feature.pl $model_energy_dir $pspro_dir $betapro_dir $name.FASTA $name.pxml");

print "evaluate models...\n";
@files = sort @files;
while(@files)
{
	$file = shift @files;
	if ($file =~ /\.pdb$/)
	{
		$out = `$model_energy_dir/script/energy_feature.pl $model_energy_dir $name.pxml $file`;
		#$out = `$model_energy_dir/script/energy_feature.pl $model_energy_dir $name.pxml $file 2>/dev/null`;
	}
	else
	{
		next;
	}
	if (!defined $out)
	{
		next;
	}
	
	if ($out !~ /\n/)
	{
		$out .= "\n";
	}

	@lines = split(/\n+/, $out);

	$bfound = 0; 

	while (@lines)
	{
		$line = shift @lines;
	
		if ($line =~ /backbone energy/)
		{
			($title, $value) = split(/: /, $line);
			if ($value ne "nan")
			{
			#	push @eva_models, $model_name;
			#	push @eva_scores, $value;  
			}

		}
	
		if ($line =~ /total energy/)
		{
			($title, $value) = split(/: /, $line);
			if ($value ne "nan")
			{
				print "$file $value\n";   
			}
			$bfound = 1; 
		}

	}

}

