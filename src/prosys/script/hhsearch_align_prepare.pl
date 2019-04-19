#!/usr/bin/perl -w
#############################################################################
#Prepare hhsearch alignment files
#Input: prosys_dir, hhsearch_dir(new version), psipred_dir, msa file, 
#output shhm file
#Output: output shhm file
#Start date: 12/08/2007
#Author: Jianlin Cheng
#############################################################################

if (@ARGV != 5)
{
	die "need five parameters: prosys dir, hhsearch_dir (new version) (/home/casp13/MULTICOM_package/software/hhsearch1.2/linux32/, psipred_dir (/home/casp13/MULTICOM_package/software/psipred/), msa file in fasta format, output shhm file.\n";
}

$prosys_dir = shift @ARGV;
$new_hhsearch_dir = shift @ARGV;
$psipred_dir = shift @ARGV;
$msa_file = shift @ARGV;
$out_shhm_file = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $new_hhsearch_dir || die "can't find $new_hhsearch_dir.\n";
-d $psipred_dir || die "can't find $psipred_dir.\n";
-f $msa_file || die "can't find $msa_file.\n";

print "covert alignment to hhserach HMM...\n";
system("$new_hhsearch_dir/hhmake -i $msa_file -o $msa_file.thhm");

open(MSA, $msa_file);
$name = <MSA>;
chomp $name;
$name = substr($name, 1);
$seq = <MSA>;
close MSA;

open(OUT, ">$name.fasta");
print OUT ">$name\n";
print OUT $seq;
close OUT;

#$idx = rindex($fasta_file, ".");
#if ($idx > 0)
#{
#	$prefix = substr($fasta_file, 0, $idx);
#}
#else
#{
#	$prefix = $fasta_file;
#}
print "predict secondary structure using PSI-PRED...\n";

#this version occasionally fail (may be due to old version of blast)
#system("$psipred_dir/runpsipred $name.fasta");

#use this version now with new blast-2.2.17
system("$psipred_dir/runpsipred_new $name.fasta");

#combine ss with hhm
print "add secondary structure into HMM...\n";
#add a input box to let people to add their comments and questions.
if (-f "$name.horiz")
{
	system("$prosys_dir/script/addpsipred2hhm.pl $name.horiz $msa_file.thhm > $out_shhm_file");
}
else
{
	warn "psi-pred fails to predict secondary structure; use the hidden markove model without secondary structure information.\n";
	`cp $msa_file.thhm $out_shhm_file`;
}



