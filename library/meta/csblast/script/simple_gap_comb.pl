#!/usr/bin/perl -w
#################################################################################
#Combine two pir alignments according to minimum cover size
#Input: script dir, pir file 1, pir file 2, minimum size(15 or 20), output pir
#Depends on: analyze_pir_align.pl, combine_pir_align.pl
#Author: Jianlin Cheng
#Date: 9/07/2005.
#################################################################################
if (@ARGV != 5)
{
	die "need five parameters: prosys script dir, pir file 1, pir file 2, minimum cover size(15 or 20), output pir file.\n";
}

$script_dir = shift @ARGV; 
$pir_file1 = shift @ARGV;
$pir_file2 = shift @ARGV;
$min_cover_size = shift @ARGV;
$out_file = shift @ARGV;

-d $script_dir || die "can't find prosys script dir.\n";
-f $pir_file1 || die "can't find $pir_file1.\n";
-f $pir_file2 || die "can't find $pir_file2.\n";

#analyze the alignment 1
system("$script_dir/analyze_pir_align.pl $pir_file1 > $pir_file1.ana");
open(ANA, "$pir_file1.ana") || die "can't read analysis results of $pir_file1.\n";
$bit1 = <ANA>;
close ANA;

#analyze the alignment 2
system("$script_dir/analyze_pir_align.pl $pir_file2 > $pir_file2.ana");
open(ANA, "$pir_file2.ana") || die "can't read analysis results of $pir_file2.\n";
$bit2 = <ANA>;
close ANA;

#check the cover size
chomp $bit1;
chomp $bit2; 
$size = length($bit1); 
$size == length($bit2) || die "the query length of $pir_file1 doesn't match with that of $pir_file2.\n";

$new_bit = ""; 
$cover = 0; 
$total_cover = 0; 
for ($i = 0; $i < $size; $i++)
{
	$bita = substr($bit1, $i, 1);
	$bitb = substr($bit2, $i, 1);

	if ($bita eq "0" && $bitb eq "1")
	{
		$cover++; 	
		$new_bit .= $bitb;
	}
	else
	{
		$new_bit .= $bita; 
	}
	if ($bita eq "1" || $bitb eq "1")
	{
		$total_cover++; 
	}
}

if ($cover >= $min_cover_size)
{
	#combine the alignment pir1 with pir2	
	system("$script_dir/combine_pir_align.pl $pir_file1 $pir_file2 $out_file");
	print "Combined. query length = $size, total cover size = $total_cover, new cover size = $cover\n";
	print "$new_bit\n";
}
else
{
	print "The cover size of $pir_file2 is less than $min_cover_size, make a simple copy of $pir_file1.\n";

	#allow to copy to itsel.
	`cp $pir_file1 $out_file 2>/dev/null`; 
}

`rm $pir_file1.ana $pir_file2.ana`; 

