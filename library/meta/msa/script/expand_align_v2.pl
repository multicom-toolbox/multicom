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

if (@ARGV != 4)
{
	die "need 4 parameters: construct dir, pir alignment 1, pir alignment 2, and output alignment file.\n";
}


$construct_dir = shift @ARGV; 
$pir_align1 = shift @ARGV;
$pir_align2 = shift @ARGV;
$out_align = shift @ARGV;

print "combine $pir_align1 with $pir_align2...\n";

$combine_script = $construct_dir . "/" . "combine_pir_align.pl"; 

#read alignment 1
open(PIR1, $pir_align1) || die "can't read $pir_align1\n";
@pir1 = <PIR1>;
close PIR1; 

#get template information
$t_comment1 = shift @pir1; chomp $t_comment1; 
$t_title1 = shift @pir1; chomp $t_title1;  
$t_info1 = shift @pir1;  chomp $t_info1; 
@t_fields1 = split(/:/, $t_info1); 
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
@t_fields2 = split(/:/, $t_info2); 
$t_start2 = $t_fields2[2]; 
$t_end2 = $t_fields2[4]; 
$t_align2 = shift @pir2;
chomp $t_align2; #remove newline
chop $t_align2; #remove *

#get query alignment information 
shift @pir2; #remove blank line
shift @pir2; #remove comment
$q_title2 = shift @pir2; chomp $q_title2; 
$q_info2 = shift @pir2; chomp $q_info2; 
$q_align2 = shift @pir2; chomp $q_align2; chop $q_align2; 

#check consistency
$t_title1 eq $t_title2 || die "The templates in the two alignments are different, so no expansion can be done.\n";

#($t_start1 >= $t_start2 && $t_end1 <= $t_end2) || die "The second alignment does not have a range to expand the first alignment.\n";
if ($t_start1 <= $t_start2 && $t_end1 >= $t_end2) 
{
	`cp $pir_align1 $out_align 2>/dev/null`; 
	die "The second alignment does not have a range to expand the first alignment.\n";
}


#Step 1: try to combine two alignments into one pir aignment first using global alignment combination
system("$combine_script $pir_align1 $pir_align2 $out_align.tmp"); 

open(PIR, "$out_align.tmp") || die "can't read $out_align.tmp.\n";
@pir = <PIR>;
close PIR; 
`rm $out_align.tmp`; 

shift @pir; 
shift @pir; 
shift @pir; 
$new_talign1 = shift @pir; 
chomp $new_talign1;
chop $new_talign1; 
shift @pir; 

shift @pir;
shift @pir;
shift @pir;
$new_talign2 = shift @pir; 
chomp $new_talign2;
chop $new_talign2; 
shift @pir; 

shift @pir; 
shift @pir;
shift @pir;
$new_qalign = shift @pir; 
chomp $new_qalign;
chop $new_qalign;

#Step 2: take the cores of the first template and query and count the number of template residues in the two ends
$length = length($new_talign1); 

for ($i = 0; $i < $length && substr($new_talign1, $i, 1) eq "-"; $i++)
{
	; 
} 
$left = $i; 

for ($i = $length - 1; $i >= 0 && substr($new_talign1, $i, 1) eq "-"; $i--)
{
	; 	
}
$right = $i; 
$left <= $right || die "no amino acids in $pir_align1\n";
$t_core = substr($new_talign1, $left, $right - $left + 1);  
$q_core = substr($new_qalign, $left, $right - $left + 1); 

#Step 3: take the front / back expansion of the second one, and count the number of template residues in the two ends
$t_front2 = ""; 
$q_front = "";
if ($left > 0)
{
	$t_front2 = substr($new_talign2, 0, $left);  
	$q_front = substr($new_qalign, 0, $left); 
}
else
{
	$t_front2 = "";
	$q_front = "";
}

$t_back2 = "";
if ($right < $length - 1)
{
	$t_back2 = substr($new_talign2, $right + 1); 
	$q_back = substr($new_qalign, $right + 1); 
}
else
{
	$t_back2 = "";
	$q_back = "";
}

#Step 4: decide if need to chop off some extra residues in front/back expansion or need to append some extra residues in front/back expansion

#count the number of residues in the front end 
$left_count = 0; 
for ($i = 0; $i < length($t_front2); $i++)
{
	if (substr($t_front2, $i, 1) ne "-")
	{
		$left_count++; 
	}	
}

$right_count = 0; 
for ($i = 0; $i < length($t_back2); $i++)
{
	if (substr($t_back2, $i, 1) ne "-")
	{
		$right_count++; 
	}
}

#expected number of residues on the left
$exp_left_count = $t_start1 - $t_start2; 
$exp_right_count = $t_end2 - $t_end1; 

if ($left_count < $exp_left_count)
{
	#add residues into left end	
	print "add residues into left end ($left_count, $exp_left_count)\n";
	$tseq2 = $new_talign2; 	
	$tseq2 =~ s/-//g; 
	$left_append = substr($tseq2, $left_count, $exp_left_count - $left_count);  		
	$left_gap = "";
	for ($i = 0; $i < $exp_left_count - $left_count; $i++)
	{
		$left_gap .= "-"; 
	}
	
#	print "add $left_append\n";

	$t_front2 .= $left_append; 
	$q_front .= $left_gap; 
}
else
{
	print "chop off left end residues ($left_count, $exp_left_count).\n";
	for ($i = length($t_front2) - 1, $count = $left_count - $exp_left_count; $i >= 0 && $count > 0; $i--)
	{
		#chop off the amino acid at $i 
		if ( substr($t_front2, $i, 1) ne "-" )
		{
			$t_front2 = substr($t_front2, 0, $i) . "-" . substr($t_front2, $i+1); 	 $count--; 	
		}	
	}	
}

#print "$t_back2\n$q_back\n";

if ($right_count < $exp_right_count)
{
	#add residues into right end	
	print "add residues into right end ($right_count, $exp_right_count)\n";
	$tseq2 = $new_talign2; 	
	$tseq2 =~ s/-//g; 
	
	$tseq2_len = length($tseq2); 	
	$right_append = substr($tseq2, $tseq2_len - $exp_right_count, $exp_right_count - $right_count);    

	$right_gap = "";
	for ($i = 0; $i < $exp_right_count - $right_count; $i++)
	{
		$right_gap .= "-"; 
	}

	$t_back2 = $right_append . $t_back2;  
	$q_back = $right_gap . $q_back; 
}
else
{
	#chop off residues in right end	
	print "chop off right end residues ($right_count, $exp_right_count).\n";
	for ($i = 0, $count = $right_count - $exp_right_count; $i < length($t_back2) && $count > 0; $i++)
	{
		#chop off the amino acid at $i 
		if ( substr($t_back2, $i, 1) ne "-" )
		{
			#print substr($t_back2, $i, 1); 
			$t_back2 = substr($t_back2, 0, $i) . "-" . substr($t_back2, $i+1); 			
			$count--; 
		}	
		
	}
#	print "\n";
}

#construct the new alignment

$final_talign = $t_front2 . $t_core . $t_back2; 

$final_qalign = $q_front . $q_core . $q_back; 

#print "$t_front2\n$q_front\n";
#print "$t_back2\n$q_back\n";
#Step 5: combine them into one alignment (if not all of template residues are chopped off or if not all template residues are aligned with gaps)

#print "$final_talign\n$final_qalign\n";

#check the consistency
length($final_talign) == length($final_qalign) || die "the lengths of final template alignment and query alignment do not match.\n";

$tseq1 = $new_talign2;
$tseq1 =~ s/-//g; 
$tseq2 = $final_talign;
$tseq2 =~ s/-//g; 
$tseq2 =~ /$tseq1/ || die "template sequences: \n$tseq1\n does not match \n$tseq2\n";

$qseq1 = $new_qalign;
$qseq1 =~ s/-//g; 
$qseq2 = $final_qalign;
$qseq2 =~ s/-//g; 
$qseq1 eq $qseq2 || die "query sequences: $qseq1 does not match $qseq2\n";

open(OUT, ">$out_align"); 
print OUT "$t_comment1 | $t_comment2\n";
print OUT "$t_title2\n";
@fields = split(/:/, $t_info2); 
#print OUT "$t_info2\n";
$fields[2] = $t_start2 <= $t_start1 ? $t_start2 : $t_start1;
$fields[4] = $t_end2 >= $t_end1 ? $t_end2 : $t_end1;  
print OUT join(":", @fields), "\n"; 
print OUT "$final_talign*\n";
print OUT "\n";

print OUT "C; local-global alignment expansion.\n";
print OUT "$q_title2\n"; 
print OUT "$q_info2\n";
print OUT "$final_qalign*\n";
close OUT; 







