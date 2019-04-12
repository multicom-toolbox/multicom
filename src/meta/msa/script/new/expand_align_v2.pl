#!/usr/bin/perl -w
###############################################################################################
#Expand one pir alignment betwee a template and a query with the other pir aignment between
#the same template and the query. The expansion is restricted to the two ends of the template 
#This program can be recursively called to expand to the first and the last residues of 
#the template
#Inputs: pir aligment 1, pir alignment 2, left limit, and right limit
#Author: Jianlin Cheng
#Start date: 2/23/2010
###############################################################################################

if (@ARGV != 3)
{
	die "need 3 parameters: pir alignment 1, pir alignment 2, and output alignment file.\n";
}

$pir_align1 = shift @ARGV;
$pir_align2 = shift @ARGV;
#$left_limit = shift @ARGV;
#$right_limit = shift @ARGV;
$out_align = shift @ARGV;

$left < $right && $right > 0 || die "illegal left or right limits.\n";


#read alignment 1
open(PIR1, $pir_align1) || die "can't read $pir_align1\n";
@pir1 = <PIR1>;
close PIR1; 

#get template information
$t_comment1 = shift @pir1; chomp $t_comment1; 
$t_title1 = shift @pir1; chomp $t_title1;  
$t_info1 = shift @pir1;  chomp $t_info1; 
@t_fields1 = split(/:/, $info1); 
$t_start1 = $t_fields1[2]; 
$t_end1 = $t_fields1[4]; 
$t_align1 = shift @pir1;
chomp $t_align1; #remove newline
chop $t_align1; #remove *

#get query alignment information
shift @pir1; #remove blank line
shift @pir; #remove comment
$q_title1 = shift @pir1; chomp $q_title1; 
$q_info1 = shift @pir1; chomp $q_info1; 
$q_align1 = shift @pir1; chomp $q_align1; chop $q_align1; 


#read alignment 2
open(PIR2, $pir_align2) || die "can't read $pir_align2\n";
@pir2 = <PIR2>;
close PIR2; 

#get template information
$t_comment2 = shift @pir2; chomp $t_comment2; 
$t_title2 = shift @pir2; chomp $t_title2;  
$t_info2 = shift @pir2;  chomp $t_info2; 
@t_fields2 = split(/:/, $info2); 
$t_start2 = $t_fields2[2]; 
$t_end2 = $t_fields2[4]; 
$t_align2 = shift @pir2;
chomp $t_align2; #remove newline
chop $t_align2; #remove *

#get query alignment information 
shift @pir2; #remove blank line
shift @pi2; #remove comment
$q_title2 = shift @pir2; chomp $q_title2; 
$q_info2 = shift @pir2; chomp $q_info2; 
$q_align2 = shift @pir2; chomp $q_align2; chop $q_align2; 


#check consistency
$t_title1 eq $t_title2 || die "The templates in the two alignments are different, so no expansion can be done.\n";
($t_start1 > $t_start2 || $t_end1 < $t_end2) || die "The second alignment does not have a range to expand the first alignment.\n";


#Step 1: try to combine two alignments into one pir aignment first using global alignment combination


#Step 2: take the cores of the first template and query and count the number of template residues in the two ends


#Step 3: take the front / back expansion of the second one, and count the number of template residues in the two ends


#Step 4: decide if need to chop off some extra residues in front/back expansion or need to append some extra residues in front/back expansion


#Step 5: combine them into one alignment (if not all of template residues are chopped off or if not all template residues are aligned with gaps)




