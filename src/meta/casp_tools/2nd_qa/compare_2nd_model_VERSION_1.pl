#######################################################
#Compare the secondary structure predicted by SSPRO or
#PSIPRED, with the secondary structure parsed from a 
#model PDB file.
#
#Zheng Wang, Feb 26, 2010.
#######################################################

use strict;

my $dssp_exe = $ARGV[0];	#The executable file of DSSP.
my $ss_file = $ARGV[1];		#The secondary structure prediction file, the first line is name and title, second line is amino acid sequence, and the third line is the secondary strucutures.
my $model_file = $ARGV[2];	#The PDB file of the model.
my $output_dir = $ARGV[3];	#The output result directory.
my $output_file = "2nd_model_compare.out";

########################################
#Get the system time as job ID
########################################
my $time = time();
my $temp_folder = "$output_dir/work_$time";
`mkdir $temp_folder`;

########################################
#execute DSSP
########################################
`$dssp_exe $model_file $temp_folder/dssp.out`;

########################################
#Parse secondary structure
#from DSSP output.
########################################
my $ss_model = "";
open(DSSP, "<$temp_folder/dssp.out");
my $start = "false";
while(<DSSP>){
	my $line = $_;
	if(substr($line, 5, 7) eq "RESIDUE"){
		$start = "true";
		next;
	}
	if($start eq "false"){
		next;
	}
	my $ss = substr($line, 16, 1);
	#print "ORIG $ss\n";
	if($ss eq "G" || $ss eq "H" || $ss eq "I"){
		$ss = "H";
	}	
	elsif($ss eq "B" || $ss eq "E"){
		$ss = "E";
	}
	else{
		$ss = "C";
	}
	#print $ss."\n";
	$ss_model .= $ss;
}
close(DSSP);

#######################################
#Parse the ss from ss prediction tools
#######################################
my $aa = "";
my $ss_predicted = "";
my $title = "";
my $counter = 1;
open(SS, "<$ss_file");
while(<SS>){
	my $line = $_;
	$line =~ s/\n//;
	if($counter == 1){
		$title = $line;
	}
	if($counter == 2){
		$aa = $line;
	}
	if($counter == 3){
		$ss_predicted = $line;
	}
	$counter++;
}
close(SS);
#######################################
#Verification
#######################################
if(length($aa) != length($ss_predicted) || length($aa) != length($ss_model) || length($ss_model) != length($ss_predicted)){
	die("The length of amino acid, predicted secondary structure, and model secondary structure are different! Something is wrong!");
}
#######################################
#Ouput and get SOV
#######################################
my $seg_h_pred = "";
my $seg_e_pred = "";
my $seg_h_model = "";
my $seg_e_model = "";

####################Calculate the segment of H on the Predicted structures####################
my $start = "false";
for(my $i = 0; $i < length($ss_predicted); $i++){
	if($start eq "false" && substr($ss_predicted, $i, 1) eq "H"){
		$seg_h_pred .= $i + 1;
		$seg_h_pred .= "-";
		$start = "true";
		next;
	}	
	if($start eq "true" && substr($ss_predicted, $i, 1) ne "H"){
		$seg_h_pred .= $i."; ";
		$start = "false";
	}
}
if(substr($seg_h_pred, -1) eq "-"){     #cases like "1-3, 3-6, 9-", i.e the H lasts to the last charactor;
	$seg_h_pred .= length($ss_predicted);
}
print $seg_h_pred."\n";

####################Calculate the segment of H on the Model structures####################
$start = "false";
for(my $i = 0; $i < length($ss_model); $i++){
        if($start eq "false" && substr($ss_model, $i, 1) eq "H"){
                $seg_h_model .= $i + 1;
		$seg_h_model .= "-";
                $start = "true";
                next;
        }
        if($start eq "true" && substr($ss_model, $i, 1) ne "H"){
                $seg_h_model .= $i."; ";
                $start = "false";
        }
}
if(substr($seg_h_model, -1) eq "-"){     #cases like "1-3, 3-6, 9-", i.e the H lasts to the last charactor;
        $seg_h_model .= length($ss_model);
}
print $seg_h_model."\n";

####################Calculate the segment of E on the Predicted structures####################
$start = "false";
for(my $i = 0; $i < length($ss_predicted); $i++){
        if($start eq "false" && substr($ss_predicted, $i, 1) eq "E"){
                $seg_e_pred .= $i + 1;
		$seg_e_pred .= "-";
                $start = "true";
                next;
        }
        if($start eq "true" && substr($ss_predicted, $i, 1) ne "E"){
                $seg_e_pred .= $i."; ";
                $start = "false";
        }
}
if(substr($seg_e_pred, -1) eq "-"){     #cases like "1-3, 3-6, 9-", i.e the H lasts to the last charactor;
        $seg_e_pred .= length($ss_predicted);
}
print $seg_e_pred."\n";

####################Calculate the segment of E on the Predicted structures####################
$start = "false";
for(my $i = 0; $i < length($ss_model); $i++){
        if($start eq "false" && substr($ss_model, $i, 1) eq "E"){
                $seg_e_model .= $i + 1;
		$seg_e_model .= "-";
                $start = "true";
                next;
        }
        if($start eq "true" && substr($ss_model, $i, 1) ne "E"){
                $seg_e_model .= $i."; ";
                $start = "false";
        }
}
if(substr($seg_e_model, -1) eq "-"){     #cases like "1-3, 3-6, 9-", i.e the H lasts to the last charactor;
        $seg_e_model .= length($ss_model);
}
print $seg_e_model."\n";

#######FOR DEGUGGING###############
####USE THE EXAMPLE OF THE PAPER###
###################################
#$ss_predicted = "CCEEECCCCCCEEEEEECCC";
#$ss_model =     "CCCCCCCEEEEECECEECCC";

my $sov = &calculate_sov($ss_predicted, $ss_model, "E");
open(OUT, ">$output_dir/$output_file");
print OUT "    NAME: $title\n      AA: $aa\n SS_PRED: $ss_predicted\nSS_MODEL: $ss_model\n";
print OUT "  H_PRED: $seg_h_pred\n";
print OUT "  E_PRED: $seg_e_pred\n";
print OUT " H_MODEL: $seg_h_model\n";
print OUT " E_MODEL: $seg_e_model\n";
close(OUT);

sub calculate_sov{
	my $ss1 = $_[0];	#experimental secondary structure
	print "$ss1\n";
	my $ss2 = $_[1];	#predicted secondary structure
	print "$ss2\n";
	my $type = $_[2];	#the intested structure type, for example, E.
	print $type."\n";
	if(length($ss1) != length($ss2)){
		die("The length of two secondary structure sequences are different, someting is badly wrong!");
	}
	###########Calculate N(i)##################
	my $n = 0;
	##############Get the segments in ss1#######################################
	my $start = "false";
	my @begin;
	my @end;
	for(my $i = 0; $i < length($ss1); $i++){
        	if($start eq "false" && substr($ss1, $i, 1) eq $type){
			push(@begin, ($i + 1));
			print "Start $i\n";
                	$start = "true";
                	next;
        	}
        	if($start eq "true" && substr($ss1, $i, 1) ne $type){
                	push(@end, $i);
			print "end $i\n";
			$start = "false";
        	}
	}
	my $size_begin = $#begin + 1;
	my $size_end = $#end + 1;
	if(($size_begin - $size_end) == 1){     #cases like "1-3, 3-6, 9-", i.e the H lasts to the last charactor;
        	push(@end, length($ss1));
	}
	###########Get the segments in the ss2, codes copied from above###############
        $start = "false";
        my @begin_2;
        my @end_2;
        for(my $i = 0; $i < length($ss2); $i++){
                if($start eq "false" && substr($ss2, $i, 1) eq $type){
                        push(@begin_2, ($i + 1));
                        print "Start $i\n";
                        $start = "true";
                        next;
                }
                if($start eq "true" && substr($ss2, $i, 1) ne $type){
                        push(@end_2, $i);
                        print "end $i\n";
                        $start = "false";
                }
        }
        my $size_begin_2 = $#begin_2 + 1;
        my $size_end_2 = $#end_2 + 1;
        if(($size_begin_2 - $size_end_2) == 1){     #cases like "1-3, 3-6, 9-", i.e the H lasts to the last charactor;
                push(@end_2, length($ss2));
        }
	###########End of getting segments in ss2###########################
	###########Get the sum part ########################################
	my $sum = 0;   				#The SUM part of the equation in the paper.
	for(my $i = 0; $i < $size_begin; $i++){    #loop through each segment in ss1
		my $seg_2 = substr($ss2, ($begin[$i] - 1), ($end[$i] - $begin[$i] + 1));   #It is the corresponding sub sequence in Sec Structure 2.
		print "corresponding segment is $seg_2\n";
		##########Calcuate how many continous segmnet this sub sequence has#############
	        my $start = "false";
		my $num_type = 0;   #The number of segments in the second secondary structures, which has the same type as $type
        	for(my $m = 0; $m < length($seg_2); $m++){
                	if($start eq "false" && substr($seg_2, $m, 1) eq $type){
                        	$start = "true";
                        	next;
                	}
                	if($start eq "true" && substr($seg_2, $m, 1) ne $type){
                        	$start = "false";
                        	$num_type++;
                	}
        	}
		if($start eq "true"){   #in the case such as "EEEEHHHHEEEEE", the last segment last to the end
			$num_type++;
		}
		#################Calculate "maxov(s1, s2)"##################
		if($num_type > 0){	#i.e. this segment has corresponding segment in the second 2ndery structures
			for(my $p = 0; $p < $size_begin_2; $p++){   #Loop each segment in ss2
				my $maxov = 0;
				my $minov = 0;
				my $delta = 0;
				if(($begin[$i] >= $begin_2[$p] && $begin[$i] <= $end_2[$p]) || ($end[$i] >= $begin_2[$p] && $end[$i] <= $end_2[$p]) || ($begin[$i] <= $begin_2[$p] && $end[$i] >= $end_2[$p])){   #i.e. two segments has overlaps, three cases, overlapped beginning, overlapped ss2, and overalpped tail part. 
					my $max_begin = $begin[$i];
					if($begin[$i] > $begin_2[$p]){
						$max_begin = $begin_2[$p];
					}
                                        my $max_end = $end[$i];
                                        if($end[$i] < $end_2[$p]){
                                                $max_end = $end_2[$p];
                                        }
					$maxov = $max_end - $max_begin + 1;
					print "Maxov".$maxov."\n";
					###########The min overlap, ie both ss has type#########
					for(my $q = ($max_begin - 1); $q <= ($max_end - 1); $q++){
						if((($q >= ($begin_2[$p] - 1)) && ($q <= ($end_2[$p] - 1))) && ( ($q >= ($begin[$i] - 1)) && ($q <= ($end[$i] - 1)) ) ){    #i.e. the overlapped regions (both ss2 ss1 have type) must within the current segment in ss1 and current segment in ss2;
                                                	if((substr($ss1, $q, 1) eq $type) && (substr($ss2, $q, 1) eq $type)){
                                                        	$minov++;
                                                	}
						}
						print "Q is $q\n";
					}
					print "Minov: $minov\n";
					###########Calculate the "Delta" in the paper#########
					$delta = int(($end[$i] - $begin[$i] + 1)/2);
					print "delta 1 $delta\n";
					if($delta > int(($end_2[$i] - $begin_2[$i] + 1)/2)){
						$delta = int(($end_2[$p] - $begin_2[$p] + 1)/2);
						print "delta 2 $delta\n";
					}
					if($delta > $minov){
						$delta = $minov;
						print "delta 3 $delta\n";
					}
					if($delta > ($maxov - $minov)){
						$delta = ($maxov - $minov);
						print "delta 4 $delta\n";
					}
					print "delta $delta\n";
					############Calculate the sum##############
					$sum += ($end[$i] - $begin[$i] + 1) * ($minov + $delta) / $maxov;					
				}
			}
		}
		#################END########################################
		if($num_type == 0){     #I.E. no corresponding E exist in the second secondary structure segment, CCC, in this case, the segment in the first secondary structure should also be counted 
			$num_type++;
		}
		print "numer of Es is $num_type\n";
		$n += $num_type * ($end[$i] - $begin[$i] + 1);
	}
	my $sov = 100 * $sum / $n; 
	print "The norminitor n: ".$n."\n";
	print "SOV is $sov\n";
	return $sov;
}

