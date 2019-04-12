#!/usr/bin/perl -w
########################################################################################
#Convert a global alignment (currently clustalw) to a pir format for modeller
#Input: global alignment file, pir output file
#Input file format: line1,2(ignore), line3: query name, line 4: aligned query seq
#	line 5: target name(should be the stx file name prefix, usually pdb_code+chain id
#Output: pir format file
#Author: Jianlin Cheng
#Date: 7/13/2005
########################################################################################

if (@ARGV != 2)
{
	die "need two parameters: global alignment file, pir output file.\n";
}

$global_file = shift @ARGV;
$pir_file = shift @ARGV;

open(GLOBAL, $global_file) || die "can't read global alignment file.\n";
<GLOBAL>;
<GLOBAL>;
$qname = <GLOBAL>;
chomp $qname;
$qseq = <GLOBAL>;
chomp $qseq;
$tname = <GLOBAL>;
chomp $tname;
$tseq = <GLOBAL>;
chomp $tseq;
close GLOBAL;

if (length($tseq) != length($qseq))
{
	die "the alignment length doesn't match.\n";
}
#check the target name format (should be pdb_code + chain id)
#if (length($tname) != 5)
#{
#	die "the target id (name) format is not correct.\n";
#}

#calculate the target sequence length
$tlen = 0;
for ($i = 0; $i < length($tseq); $i++)
{
	if (substr($tseq, $i, 1) ne "-")
	{
		$tlen++; 
	}
}

open(PIR, ">$pir_file") || die "can't create pir file.\n";
print PIR "C;template; converted from global alignment\n";
print PIR ">P1;$tname\n";
print PIR "structureX:$tname";
print PIR ": 1: :";
print PIR " $tlen: :";
print PIR " : : : \n";
print PIR "$tseq*\n\n";

print PIR "C;query; converted from global alignment\n";
print PIR ">P1;$qname\n";
print PIR " : : : : : : : : : \n";
print PIR "$qseq*\n";
close PIR;




