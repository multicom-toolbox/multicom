#!/usr/bin/perl -w
#######################################################
#Convert PDB models to CASP models
#Author: Jianlin Cheng
#Date: 2/5/2020
#######################################################

if (@ARGV != 7)
{
	die "need 7 parameters: option file, prosys dir, meta dir, model dir, target name, fasta file, full length dir.\n";
}
$option_file = shift @ARGV;
-f $option_file || die "can't find option file: $option_file.\n";

open(OPTION, $option_file) || die "can't read option file.\n";
$other = ""; 
while (<OPTION>)
{
        $line = $_;
        chomp $line;
        if ($line =~ /^scwrl_program/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $scwrl_program = $value;
        }
}
close OPTION; 

-f $scwrl_program || die "can't find $scwrl_program.\n";

$prosys_dir = shift @ARGV;
$meta_dir = shift @ARGV;
$model_dir = shift @ARGV;
$target_name = shift @ARGV;
$fasta_file = shift @ARGV;
$full_length_dir = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $model_dir || die "can't find $model_dir.\n";
-f $fasta_file || die "can't find $fasta_file.\n";

$count = 5; 
$pdb2casp2 = "$meta_dir/script/pdb2casp.pl";

$mdir = "$full_length_dir/meta";

-d $mdir || die "can't find model dir: $mdir\n";

print "Convert domain combined models to CASP format...\n";
$mdir = "$model_dir/comb/";
for ($i = 1; $i <= $count; $i++)
{
	$model_file = "$mdir/comb$i.pdb";	
	if (-f $model_file)
	{
		system("$scwrl_program -i $model_file -o $model_file.scw >/dev/null");
		system("$prosys_dir/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
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
        #print("$scwrl_program -i $model_file.org -o $mdir/casp$i.scw \n");
		#print("$prosys_dir/script/clash_check.pl $fasta_file $mdir/casp$i.scw \n");
		#print("$pdb2casp2 $mdir/casp$i.scw $i $target_name $mdir/casp$i.pdb \n");
		system("$scwrl_program -i $model_file.org -o $mdir/casp$i.scw >/dev/null");
		system("$prosys_dir/script/clash_check.pl $fasta_file $mdir/casp$i.scw > $mdir/clash$i.txt");
		system("$pdb2casp2 $mdir/casp$i.scw $i $target_name $mdir/casp$i.pdb");
	}
} 

print "Convert domain combined models according to the average ranking to CASP format...\n";
$mdir = "$model_dir/top_domain_comb/";
for ($i = 1; $i <= $count; $i++)
{
	$model_file = "$mdir/comb$i.pdb";	
	if (-f $model_file)
	{
		system("$scwrl_program -i $model_file -o $model_file.scw >/dev/null");
		system("$prosys_dir/script/clash_check.pl $fasta_file $model_file.scw > $mdir/clash$i.txt");
		system("$pdb2casp2 $model_file.scw $i $target_name $mdir/casp$i.pdb");	
	}
} 


