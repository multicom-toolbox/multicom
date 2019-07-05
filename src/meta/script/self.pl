#!/usr/bin/perl -w
########################################################
#self modeling 
#Input: pdb file
#Output: a new pdb file
########################################################

if (@ARGV != 2)
{
	die "need a pdb file, and output name.\n";
}
$in_pdb = shift @ARGV;
$name = shift @ARGV;
-f $in_pdb || die "can't find $in_pdb\n";

$seq = `/home/jh7x3/multicom_beta1.0/tools/model_eva1.0/script/pdb2seq.pl $in_pdb`;

chomp $seq;

$length = length($seq);

#create a pir file

open(SELF, ">selftmp.pir");
print SELF "C;comment\n";
print SELF ">P1;selftmp\n";
print SELF "structureN:selftmp: 1: : $length: : : :6.0: \n";
print SELF "$seq*\n";
print SELF "\n";
print SELF "C;comment\n";
print SELF ">P1;$name\n";
print SELF " : : : : : : : : : \n";
print SELF "$seq*\n";
close SELF;


#prepare atom file
`mkdir atomtmp`;
`cp $in_pdb ./atomtmp/selftmp.atom`;
`gzip -f ./atomtmp/selftmp.atom`;

`mkdir outtmp`;

$cur_dir = `pwd`;
chomp $cur_dir;

#do modeling
#system("/home/casp13/MULTICOM_package/software/prosys/script/pir2ts_energy.pl /home/casp13/MULTICOM_package/software/modeller9v7 $cur_dir/atomtmp $cur_dir/outtmp selftmp.pir 3");
system("/home/jh7x3/multicom_beta1.0/src/prosys/script/pir2ts_energy.pl /home/jh7x3/multicom_beta1.0/tools/modeller-9.16 $cur_dir/atomtmp $cur_dir/outtmp selftmp.pir 8");

`cp $cur_dir/outtmp/$name.pdb $name.pdb`;

#clean up
`rm -r atomtmp outtmp`;
`rm selftmp.pir`;



