#!/usr/bin/perl -w
##############################################################
#combine two pir alignments for the same query into one.
#Extend: combine_pir_align_adv.pl to handle multiple alignments in pir2.
#Input: script dir, alignment file 1, alignment file 2, 
# minimum cover size, linker size, output file
#NOTICE: alignment file 2 contains at most 1 alignment.
#Author: Jianlin Cheng
#Date: 9/18/2005
###############################################################
if (@ARGV != 6)
{
	die "need 6 parameters: script dir, input pir file1, input pir file 2, min cover size(20), max linker size(10), output file\n";
}
$script_dir = shift @ARGV;
-d $script_dir || die "can't read script dir.\n";

$pir_file1 = shift @ARGV;
open(PIR, $pir_file1) || die "can't read pir file:$pir_file1.\n";
@pir1 = <PIR>;
close PIR; 

$pir_file2 = shift @ARGV;
open(PIR, $pir_file2) || die "can't read pir file:$pir_file2.\n";
@pir2 = <PIR>;
close PIR; 

$min_cover_size = shift @ARGV;
$min_cover_size > 0 || die "minimum cover size must be bigger than 0.\n";

$max_linker_size = shift @ARGV; 
$max_linker_size >= 0 || die "max linker size can't be negative.\n"; 

$out_file = shift @ARGV;


#the last four lines are query
$qseq1 = pop @pir1;
pop @pir1;
$qtitle1 = pop @pir1;
chomp $qtitle1;
pop @pir1; 

$qseq2 = pop @pir2;
$qstx2 = pop @pir2;
$qtitle2 = pop @pir2;
$qcom2 = pop @pir2; 

chomp $qtitle2; 

#consistency checking.
$qtitle1  eq $qtitle2 || die "two alignment files belong to two different queries.$qtitle1 vs. $qtitle2,  stop.\n";

#strip the last \n and *
chomp $qseq1; 
chop $qseq1; 
chomp $qseq2; 
chop $qseq2; 

#consistence checking
$chk_seq1 = $qseq1;
$chk_seq1 =~ s/-//g;
$chk_seq2 = $qseq2;
$chk_seq2 =~ s/-//g;
$chk_seq1 eq $chk_seq2 || die "two query sequence is not equal.\n";

#comine templates in pir2 file with pir1 one by one.
`cp $pir_file1 $out_file 2>/dev/null`; 
while (@pir2)
{
	$tcom2 = shift @pir2;
	$ttitle2 = shift @pir2;
	$tstx2 = shift @pir2;
	$tseq2 = shift @pir2; 
	shift @pir2;

	#create a temporary file
	open(ALIGN, ">$out_file.alg") || die "can't create a temporary file for advanced combination.\n";
	print ALIGN "$tcom2$ttitle2$tstx2$tseq2\n";

	print ALIGN "$qcom2$qtitle2\n$qstx2$qseq2*\n";
	close ALIGN;

	#print "process $ttitle2\n";
	#<STDIN>;


	#do combination
	system("$script_dir/combine_pir_align_adv.pl $script_dir $out_file $out_file.alg $min_cover_size $max_linker_size $out_file"); 
}
`rm $out_file.alg 2>/dev/null`; 
