#!/usr/bin/perl -w

##########################################################################
#Run Novel to generate ab initio models for protein
##########################################################################

if (@ARGV < 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV;

#make sure work dir is a full path (abosulte path)
$cur_dir = `pwd`;
chomp $cur_dir; 
#change dir to work dir
if ($work_dir !~ /^\//)
{
	if ($work_dir =~ /^\.\/(.+)/)
	{
		$work_dir = $cur_dir . "/" . $1;
	}
	else
	{
		$work_dir = $cur_dir . "/" . $work_dir; 
	}
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

`cp $fasta_file $work_dir`; 
`cp $option_file $work_dir`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
$pos = rindex($option_file, "/");
if ($pos > 0)
{
	$option_file = substr($option_file, $pos+1); 
}
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$deepsf_program = "";
$final_model_number = 5; 
$output_prefix_name = ""; #raptorx main program

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

	if ($line =~ /^output_prefix_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$output_prefix_name = $value; 
	}

	if ($line =~ /^deepsf_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$deepsf_program = $value; 
	}

	if ($line =~ /^final_model_number/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$final_model_number = $value; 
	}

}

#check the options
-d $prosys_dir || die "can't find script dir: $prosys_dir.\n"; 
-f $deepsf_program || die "can't find $deepsf_program.\n";
$final_model_number > 0 && $final_model_number <= 10 || die "model number is out of range.\n";


#check fast file format
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$name = <FASTA>;
chomp $name; 
$seq = <FASTA>;
chomp $seq;
close FASTA;
if ($name =~ /^>/)
{
	$name = substr($name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}

print "Generate models using Novel...\n";
use Cwd 'abs_path';
$fasta_file = abs_path($fasta_file);
system("$deepsf_program $name $fasta_file $work_dir"); 

for ($i = 1; $i <= $final_model_number; $i++)
{
	$model_file = "$work_dir/TOP5/DeepSF$i.pdb";
	if (-f "$model_file")
	{
		`cp $model_file $output_prefix_name$i.pdb`; 
		print "Model ${output_prefix_name}$i.pdb is generated.\n";
	}
}


print "DeepSF prediction is done.\n";

