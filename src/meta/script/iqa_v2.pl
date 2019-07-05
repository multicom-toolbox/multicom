#!/usr/bin/perl -w
#################################################################
#Given a meta.eva file, a model dir, and an output file
#Generate a new list of ranking of models based on iqa
#################################################################
if (@ARGV != 4)
{
	die "need 4 parameters: meta.eva file, model dir, fasta file, output file\n";
}

$iqa_script = "/home/jh7x3/multicom_beta1.0/src/meta/model_cluster/script/iqa_v2.pl";

$meta_eva = shift @ARGV;
-f $meta_eva || die "can't find $meta_eva file.\n";

$model_dir = shift @ARGV;
-d $model_dir || die "can't find $model_dir.\n";

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find $fasta_file.\n";

$output_file = shift @ARGV;

$spicker = "/home/jh7x3/multicom_beta1.0/tools/spicker/spicker";

open(FASTA, $fasta_file) || die "can't read $fasta_file.\n";
$name = <FASTA>;
$seq = <FASTA>;
close FASTA;
chomp $name;
chomp $seq;
$name = substr($name, 1);

#create a temporary directory
`mkdir $name.tmp`;

open(META, $meta_eva) || die "can't read $meta_eva file.\n";
@meta = <META>;
close META;
shift @meta;

#create a temporary score file
open(SCORE, ">$output_file.evascore") || die "can't create $name.evascore.\n";
print SCORE "PFRMAT QA\n";
print SCORE "TARGET $name\n";
print SCORE "MODEL 1\n";
print SCORE "QMODE 1\n";
foreach $record (@meta)
{
	@fields = split(/\s+/, $record);
	print SCORE $fields[0], " ", $fields[8], "\n";
	`cp $model_dir/$fields[0] $name.tmp`; 
}
print SCORE "END\n";
close SCORE; 

#call iterative qa
print "Generate iterative QA from meta.eva...\n";
$cluster_dir = "/home/jh7x3/multicom_beta1.0/src/meta/model_cluster/script/"; 

use Cwd 'abs_path';
`cp $fasta_file $name.tfasta`;
system("$iqa_script $cluster_dir $spicker $name.tmp $output_file.evascore $name.tfasta $output_file >/dev/null");

`rm $name.tfasta`; 
`rm -r $name.tmp`; 
 





