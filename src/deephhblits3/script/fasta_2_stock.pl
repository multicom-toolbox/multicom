#!/usr/bin/perl -w
#################################
#Convert MSA of FASTA to
#Stockholm format.
#
#Zheng Wang, Dec 28th, 2009.
#################################

use strict;
use POSIX;

if (@ARGV != 3)
{
	die "need three parameters: input multiple sequence alignment file (in FASTA format), output file (in stockholm format), and number of amino acids per line (e.g., 100).\n";
}

my $seq_file = $ARGV[0];
my $stock_file = $ARGV[1];
my $width = $ARGV[2];

open(READ, "<$seq_file");
my @seqs;
my $max_header_length = 0;
my $seq_len = 0;
#my $counter = 1;
my $sequence;
my $title;
my $first = "true";
while(<READ>){
        my $line = $_;
        if(substr($line, 0, 1) eq ">"){
                if($first eq "false"){
                        #open(FASTA, ">$output_dir/$counter.fasta");
                        #print FASTA $title."\n";
                        #print FASTA $sequence;
                        #close FASTA;
			push(@seqs, "$title###$sequence");
                        #$counter++;
                        $sequence = "";
                }
                $title = $line;
                $title =~ s/\n//;
		$title =~ s/>//;
		my $len = length($title);
		if($len > $max_header_length){
			$max_header_length = $len;
		}
        }
        if(substr($line, 0, 1) ne ">"){
                $sequence = $sequence.$line;
                $sequence =~ s/\n//g;
                $sequence =~ s/ //g;
                $sequence =~ s/^A-Z//g;
                $sequence =~ s/\*//g;
		$sequence =~ s/-/\./g;
                $first = "false";
        }
}
push(@seqs, "$title###$sequence");
$seq_len = length($sequence);
open(OUT, ">$stock_file");
print OUT '# STOCKHOLM 1.0'."\n\n";
$max_header_length++;

my $item = $width;
my $counter_item = 0;
my $total_item = ceil($seq_len/$item);
while($counter_item < $total_item){
        my $start = $counter_item * $item;
        my $end = $start + $item - 1;
       	foreach my $seq (@seqs){
		my @seq_items = split(/###/, $seq);
		my $para = "%-".$max_header_length."s";
		printf OUT "$para", $seq_items[0];
		print OUT substr($seq_items[1], $start, $item);
		print OUT "\n";
	} 
        $counter_item++;
	print OUT "\n";
}
print OUT '//'."\n";
close(OUT);
