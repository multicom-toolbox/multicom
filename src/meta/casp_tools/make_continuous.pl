#!/usr/bin/perl -w
############################################################
#This program make a not continuous pdb file continous.
#i.e. the position number of atom and residue are continous.
#
#INPUT: The input PDB file, and the output PDB file;
#
#Author: Zheng Wang, June 25th, 2008.
############################################################

use strict;
if(@ARGV != 2){
	die "Two parameters: the input PDB file and the output PDB file;\n";
}

my $input_file = $ARGV[0];
my $output_file = $ARGV[1];

open(READ, "<$input_file");
open(WRITE, ">$output_file");
my $counter_atom = 1;
my $new_counter_resid = 1;
my $pre_resid;
my $first_line = "true";
while(<READ>){
	my $line = $_;
	if($line =~ /END/){
		print WRITE "END\n";
		last;
	}
	if ($line !~/^ATOM/)
	{
		next;
	}
	#print "ORIG: ".$line;
	my $new_line;
	my $atom_no;
	if(length($counter_atom) == 1){
		$atom_no = "      $counter_atom";
	}
	if(length($counter_atom) == 2){
		$atom_no = "     $counter_atom";
	}
        if(length($counter_atom) == 3){
                $atom_no = "    $counter_atom";
        }
        if(length($counter_atom) == 4){
                $atom_no = "   $counter_atom";
        }
        if(length($counter_atom) == 5){
                $atom_no = "  $counter_atom";
        }
        if(length($counter_atom) == 6){
                $atom_no = " $counter_atom";
        }
        if(length($counter_atom) == 7){
                $atom_no = "$counter_atom";
		print "WARNING: the digit of atom number exceed 7!\n";
        }
	
	my $curr_counter_resid = substr($line, 20, 6);
	$curr_counter_resid =~ s/ //g;
	if($first_line eq "true"){
		$pre_resid = $curr_counter_resid;
		$first_line = "false";
	}
	else{
		if($curr_counter_resid != $pre_resid){
			$new_counter_resid++;
			$pre_resid = $curr_counter_resid;
		}	
	}
	$new_counter_resid =~ s/ //g;	

	#print "ITIS:::".$new_counter_resid.":::\n";
	#print "Lenth is: ".length($new_counter_resid)."\n";	

	if(length($new_counter_resid) == 1){
			$new_counter_resid = "     $new_counter_resid";
	}
        elsif(length($new_counter_resid) == 2){
                        $new_counter_resid = "    $new_counter_resid";
        }
        elsif(length($new_counter_resid) == 3){
                        $new_counter_resid = "   $new_counter_resid";
        }
        elsif(length($new_counter_resid) == 4){
                        $new_counter_resid = "  $new_counter_resid";
        }
        elsif(length($new_counter_resid) == 5){
                        $new_counter_resid = " $new_counter_resid";
        }
        elsif(length($new_counter_resid) == 6){
                        $new_counter_resid = "$new_counter_resid";
		        print "WARNING: the digit of residue number exceed 6!\n";
        }

	$new_line = substr($line, 0, 4).$atom_no.substr($line, 11, 9).$new_counter_resid.substr($line, 26);
	print WRITE $new_line;
	$counter_atom++;
	#print "AFTE: ".$new_line."\n";
	
}
close(READ);
close(WRITE);
