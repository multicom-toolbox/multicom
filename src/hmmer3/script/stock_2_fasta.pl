#!/usr/bin/perl -w
#########################################
#Convert stockholk file format to FASTA 
#format.
#
#Zheng Wang, Dec 28th, 2009.
#########################################

use strict;
use POSIX;

if (@ARGV != 3)
{
	die "need three parameters: stock file, output file, width.\n";
}

my $stock_file = $ARGV[0];
my $fasta_file = $ARGV[1];
my $width = $ARGV[2];

my @seqs;
my %seqs;
open(IN, "<$stock_file");
while(<IN>){
	my $line = $_;
	if($line =~ /#/){
		next;
	}
	if($line =~ /\/\//){
		last;
	}
	if(length($line) >= 2){
		my @items = split(/\s+/, $line);
		if(!exists $seqs{$items[0]} ){
			push(@seqs, $items[0]);
		}
		my $seq = $items[1];
		$seq =~ s/\n//;
		$seq =~ s/\./-/g;
		$seqs{$items[0]} .= $seq;
	}
}
close(IN);

open(OUT, ">$fasta_file");
foreach my $title (@seqs){
	print OUT ">$title\n";
	my $seq = $seqs{$title};
	my $seq_len = length($seq);
	my $item = $width;
	my $counter_item = 0;
	my $total_item = ceil($seq_len/$item);
	while($counter_item < $total_item){
        	my $start = $counter_item * $item;
        	my $end = $start + $item - 1;
		print OUT substr($seq, $start, $item);
		print OUT "\n";
        	$counter_item++;
	}
}
close(OUT);
