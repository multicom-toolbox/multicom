#!/usr/bin/perl
#########################################################
#Preprocess the models for q_score.cpp. This program
#remove all the illegal lines besides PDB format needed
#ones.
#
#Zheng Wang, Feb 9th, 2010.
#########################################################

use strict;

my $list_file = $ARGV[0];    #model list file
my $output_dir = $ARGV[1];

open(LIST, "<$list_file");
while(<LIST>){
	my $line = $_;
	if($line =~ /#/){
		next;
	}
	$line =~ s/\n//;
	my $index = rindex($line, "/");
	my $name = substr($line, ($index + 1));
	#print $name."\n";
	open(OUT, ">$output_dir/$name");
	open(IN, "<$line");
	while(<IN>){
		my $line_model = $_;
		if(substr($line_model, 0, 4) ne "ATOM"){
			next;
		}
		print OUT $line_model;	
	}
	close(IN);
	close(OUT);
}
close(LIST);
