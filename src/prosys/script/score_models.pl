#!/usr/bin/perl -w
#######################################################################
#score predicted 3D models (cm, fr, and ab)
#Input: option file, target_fasta_file, input / output_dir
#output will be name.score
#Including the following scores: 
#model_name, method, top_template name, coverage, identity,
#blast-evalue, svm_score, hhs score, compress score, ssm score
#ssa match score, clashes, model check score, model energy score
#scores will be saved in a file: name.mch
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
}
-d $prosys_dir || die "can't find $pspro_dir.\n";
-d $model_check_dir || die "can't find $model_check_dir.\n";
-d $model_energy_dir || die "can't find $model_energy_dir.\n";
-d $betacon_dir || die "can't find $betacon_dir.\n";
-d $pspro_dir || die "can't find $pspro_dir.\n";

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

`mkdir model_check`; 
print "generate 1D and 2D features for model check...\n";
system("$betacon_dir/bin/beta_contact_map.sh $fasta_file model_check >/dev/null 2>/dev/null");
print "evaluate models...\n";
@files = sort @files;
open(SCORE, ">$name.mch");
while(@files)
{
	$file = shift @files;
	if ($file =~ /\.pdb$/)
	{
	#	$out = `$model_check_dir/bin/model_eval.sh $fasta_file model_check $file 2>/dev/null`;
		$out = `$model_check_dir/bin/model_eval.sh $fasta_file model_check $file`;
	}
	else
	{
		next;
	}
	if (!defined $out)
	{
		print "no score is generated for $file.\n";
		`rm $file.dssp $file.set 2>/dev/null`; 
		next;
	}
	if ($out !~ /\n/)
	{
		$out .= "\n";
	}
	
	$new_out = $out;
	chomp $new_out;

	
	@fields = split(/:/, $new_out);
	if ($fields[1] !~ /\d+/)
	{
		print "no score is generated for $file.\n";
		`rm $file.dssp $file.set 2>/dev/null`; 
	}
	else
	{
		print "$file $fields[1]\n";
		print SCORE "$file $fields[1]\n";
	}

}
close SCORE;

