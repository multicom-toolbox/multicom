#!/usr/bin/perl -w
########################################################
#self modeling 
#Input: pdb file
#Output: a new pdb file
########################################################

if (@ARGV != 3)
{
	die "need three parameters: pdb file 1, pdb file 2, and output name.\n";
}
$in_pdb = shift @ARGV;
$in_pdb2 = shift @ARGV;
$name = shift @ARGV;
-f $in_pdb || die "can't find $in_pdb\n";
-f $in_pdb2 || die "can't find $in_pdb2\n";

$seq = `/home/chengji/software/model_eva1.0/script/pdb2seq.pl $in_pdb`;
$seq2 = `/home/chengji/software/model_eva1.0/script/pdb2seq.pl $in_pdb2`;

chomp $seq;
chomp $seq2;

$org1 = $seq;
$org2 = $seq2;

$length = length($seq);
$length2 = length($seq2);

#create a pir file

open(SELF, ">selftmp.pir");

print SELF "C;comment\n";
print SELF ">P1;selftmp\n";
print SELF "structureN:selftmp: 1: : $length: : : :6.0: \n";
for ($i = 0; $i < $length2; $i++)
{
	$seq .= "-";
}
print SELF "$seq*\n\n";

print SELF "C;comment\n";
print SELF ">P1;selftmp2\n";
print SELF "structureN:selftmp2: 1: : $length2: : : :6.0: \n";
$seq = "";
for ($i = 0; $i < $length; $i++)
{
	$seq .= "-";
}
$seq .= $seq2;
print SELF "$seq*\n";

print SELF "\n";
print SELF "C;comment\n";
print SELF ">P1;$name\n";
print SELF " : : : : : : : : : \n";
print SELF "$org1$org2*\n";
close SELF;


#prepare atom file
`mkdir atomtmp`;
`cp $in_pdb ./atomtmp/selftmp.atom`;
`gzip ./atomtmp/selftmp.atom`;

#`cp $in_pdb2 ./atomtmp/selftmp2.atom`;
#make the pdb file continuous
`/home/chengji/software/prosys_small/script/make_continuous.pl $in_pdb2 ./atomtmp/selftmp2.atom`;

`gzip ./atomtmp/selftmp2.atom`;

`mkdir outtmp`;

$cur_dir = `pwd`;
chomp $cur_dir;

#do modeling
system("/home/chengji/software/prosys/script/pir2ts_energy.pl /home/chengji/software/prosys/modeller7v7 $cur_dir/atomtmp $cur_dir/outtmp selftmp.pir 3");

`cp $cur_dir/outtmp/$name.pdb $name.pdb`;

#clean up
`rm -r atomtmp outtmp`;
`rm selftmp.pir`;



