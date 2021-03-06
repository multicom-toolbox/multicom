#!/usr/bin/perl -w

$GLOBAL_PATH="/home/jhou4/tools/multicom/";


$benchmark_list = "$GLOBAL_PATH/installation/benchmark/casp13_benchmark.txt";
$fasta_dir = "$GLOBAL_PATH/installation/benchmark/fasta/";
$outputdir = "$GLOBAL_PATH/test_out_casp13/";


-d $outputdir || `mkdir $outputdir`;

open(IN,"$benchmark_list") || die "Failed to open $benchmark_list\n";
while(<IN>)
{
	$line = $_;
	chomp $line;
	if(index($line,'Target')>0)
	{
		next;
	}
	@tmp = split(/\t/,$line);
	$targetid = $tmp[1];
	$seq = "$fasta_dir/$targetid.fasta";
	if(!(-e $seq))
	{
		next;
	}
	
	print "Generating $outputdir/$targetid.sh\n";
	open(OUT,">$outputdir/$targetid.sh") || die "Failed to write $outputdir/$targetid.sh\n";
	print OUT "#!/bin/sh\n\n";
	print OUT "sh $GLOBAL_PATH/bin/run_multicom.sh  $targetid  $seq $outputdir/$targetid  &> $outputdir/$targetid.log  & \n\n";
	close OUT;

}
close IN;

