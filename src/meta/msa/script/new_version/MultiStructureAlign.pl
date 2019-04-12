#!/usr/bin/perl -w
########################################################################
#Generate the multiple structural alignment, similarly as multiple
#sequence alignment. Use the TMalign to generate structural alignment
#and then put them together.
#
#Zheng Wang, Feb 22, 2010.
########################################################################

use strict;

my $tm_align_exe = $ARGV[0]; 		#location of tmalign program.
my $model_list = $ARGV[1];		#the file in which each line specifies the full path plus file name of a model file; the first one is the central model being compared by others.
my $dist_threshold = $ARGV[2]; 		#alignment closer than this threshold will be considered and output in the result. for example, 5.
my $length_threshold = $ARGV[3];	#The lenth of the longest segment.  
my $output_dir = $ARGV[4];              #A temp folder will be created under it, and also the final alignment file.

################################################
#Use system time as the temporary folder name
################################################
my $time = time();
my $temp_folder = "$output_dir/work_$time";
`mkdir $temp_folder`;

################################################
#three code and one code amino acid. Used for verification of the three letter code parsed from PDB file and the one letter code parsed from alignment file.
################################################
my %AA;
$AA{"ALA"} = "A";
$AA{"CYS"} = "C";
$AA{"ASP"} = "D";
$AA{"GLU"} = "E";
$AA{"PHE"} = "F";
$AA{"GLY"} = "G";
$AA{"HIS"} = "H";
$AA{"ILE"} = "I";
$AA{"LYS"} = "K";
$AA{"LEU"} = "L";
$AA{"MET"} = "M";
$AA{"ASN"} = "N";
$AA{"PRO"} = "P";
$AA{"GLN"} = "Q";
$AA{"ARG"} = "R";
$AA{"SER"} = "S";
$AA{"THR"} = "T";
$AA{"VAL"} = "V";
$AA{"TRP"} = "W";
$AA{"TYR"} = "Y";

################################################
#Begin tm align between each model and the central model
################################################
open(LIST, "<$model_list");
open(OUT, ">$output_dir/output.msa");
my $central_model;
my $first_line = "true";
my $central_model_coord_stored = "false";   #This and the next make the program only read it onece for the central model's coordinates;
my @atoms_central;
my @alignments; #This stores the final forms of alignments;
my $central_done = "false";   #Whether the central model has been analyzed or outputed.
while(<LIST>){
	my $model = $_;
	$model =~ s/\n//;
	$model =~ s/\s+$//;
	if($first_line eq "true"){
		$central_model = $model;
		$first_line = "false";
		next;
	}
	my $central_model_id = substr($central_model, (rindex($central_model, '/') + 1));
	my $model_id = substr($model, (rindex($model, '/') + 1));
	print $model_id."\n";
	################################################
	#TMalign and parse the aligned sequences 
	################################################
	`$tm_align_exe $model $central_model -o $temp_folder/$model_id-$central_model_id.sup > $temp_folder/$model_id-$central_model_id.screen`;
	open(SCREEN, "<$temp_folder/$model_id-$central_model_id.screen");
	my $start_align = "false";
	my $align_central;
	my $align_model;
	my $counter_align = 0;
	while(<SCREEN>){
		my $screen = $_;
		if($screen =~ /denotes the residue pairs of distance/){
			$start_align = "true";
			$counter_align++;
			next;
		}
		if($start_align eq "true"){
			$screen =~ s/\n//;
			if($counter_align == 1){
				$align_model = $screen;
			}
			if($counter_align == 3){
				$align_central = $screen;
			}
			$counter_align++;
		}
	}
	close(SCREEN);
	print "$align_model\n$align_central\n";
	################################################
	#Parse the PDB atoms of the superimposed models
	################################################
	my @atoms_model;
	#my @atoms_central;
	open(SUP, "<$temp_folder/$model_id-$central_model_id.sup_all");
	my $first_model = "true";
	while(<SUP>){
		my $sup = $_;
		if($first_model eq "true"){
			if(substr($sup, 0, 4) eq "ATOM"){
				my @atoms;
		                my $x = substr($sup, 30, 8);
                		my $y = substr($sup, 38, 8);
               			my $z = substr($sup, 46, 8);
				my $aa = substr($sup, 17, 3);
                		$x =~ s/ //;
                		$y =~ s/ //;
                		$z =~ s/ //;
                		push(@atoms, "$x");
                		push(@atoms, "$y");
                		push(@atoms, "$z");
				push(@atoms, "$aa");
                		push(@atoms_model, \@atoms);
			}
			if(substr($sup, 0, 3) eq "TER"){
				$first_model = "false";
				next;
			}
		}
		if($first_model eq "false"){
			if($central_model_coord_stored eq "false"){
                        	if(substr($sup, 0, 4) eq "ATOM"){
                                	my @atoms;
                                	my $x = substr($sup, 30, 8);
                                	my $y = substr($sup, 38, 8);
                                	my $z = substr($sup, 46, 8);
					my $aa = substr($sup, 17, 3);
                                	$x =~ s/ //;
                                	$y =~ s/ //;
                                	$z =~ s/ //;
                                	push(@atoms, "$x");
                                	push(@atoms, "$y");
                                	push(@atoms, "$z");
					push(@atoms, "$aa");
                                	push(@atoms_central, \@atoms);
                        	}
				if(substr($sup, 0, 3) eq "TER"){
					$central_model_coord_stored = "true";
				}
			}
			if($central_model_coord_stored eq "true"){
				last;
			}
		}
	}
	close(SUP);
	#print "$atoms_central[0][0] $atoms_central[0][1] $atoms_central[0][2] $atoms_central[0][3]\n";
	#print "$atoms_model[0][0] $atoms_model[0][1] $atoms_model[0][2] $atoms_model[0][3]\n";
        ################################################
        #Filtered out the pairs that far away than the
        #threshold distance.
        ################################################
	my @filtered_central;  #The filtered central model string, containing no gap, but only AAs;
	my @filtered_model;    #The filtered template model string, no gap, only AAs;
	for(my $i = 0; $i < length($align_central); $i++){       #For the central model, just ouptut the orignal sequence, without any gaps or so.
		if(substr($align_central, $i, 1) ne "-"){
			push(@filtered_central, substr($align_central, $i, 1)); #If its not gap, just include it in the final output.
			push(@filtered_model, "-");    #Let it contain only gaps, purpose is to get the position, can change it later.
		}
		
	}
	if(length($align_central) != length($align_model)){     #They should have the same lengths
		die("The two alignments do not have the same length, something is wrong!");
	}
	my $order_central = -1; #the xth AA in the sequence, the same of the one below. Because the array storing atoms starts from 0, so this varaibale starts from -1, which makes the first one 0.
	my $order_model = -1;
	my $regions = "";  #The format like "0-5, 9-23";
	my $started = "false";  #Whether the counting has started
	for(my $i = 0; $i < length($align_model); $i++){       #For the template model, begin to exchange the gaps into proper AAs, that is shorter than the threshold.
		my $dist = 10000;
		if(substr($align_central, $i, 1) ne "-"){    #get the order of the AA, then can get the pdb coordinates
			$order_central++;
		}
                if(substr($align_model, $i, 1) ne "-"){    #get the order of the AA, then can get the pdb coordinates
                        $order_model++;
                }
		if(substr($align_central, $i, 1) ne "-" && substr($align_model, $i, 1) ne "-"){
			#print "$AA{$atoms_central[$order_central][3]}\n";
			#my $temp = substr($align_central, $i, 1);
			#print $temp."\n";
			if($AA{$atoms_central[$order_central][3]} ne substr($align_central, $i, 1)){
				die("The order of the PDB coordinates does not corresponds to the alignment sequence, wrong!");
			}
                        if($AA{$atoms_model[$order_model][3]} ne substr($align_model, $i, 1)){
                                die("The order of the PDB coordinates does not corresponds to the alignment sequence, wrong!");
                        }
			$dist = sqrt( ( ($atoms_central[$order_central][0] - $atoms_model[$order_model][0]) * ($atoms_central[$order_central][0] - $atoms_model[$order_model][0]) + ($atoms_central[$order_central][1] - $atoms_model[$order_model][1]) * ($atoms_central[$order_central][1] - $atoms_model[$order_model][1]) + ($atoms_central[$order_central][2] - $atoms_model[$order_model][2]) * ($atoms_central[$order_central][2] - $atoms_model[$order_model][2]) ) );	
			#print "$rmsd\n";
			if($dist <= $dist_threshold){
				$filtered_model[$order_central] = substr($align_model, $i, 1);
			}
		}
		#####Start counting regions###############
                if(substr($align_model, $i, 1) ne "-"){    #get 
                        if($started eq "false" && ($dist <= $dist_threshold)){
				my $order_model_plus = $order_model + 1;    #the regions starts from 1.
				$regions .= "$order_model_plus-";
				$started = "true";
			}
			if($started eq "true" && ( ($dist > $dist_threshold) && (substr($align_model, $i, 1) ne "-") ) ){     #time to stop counting the regions
				$regions .= "$order_model; ";
				$started = "false";
			}
                }
	}
	if(substr($regions, -1) eq "-"){    #The regions is like "3-5, 6-123, 153-"; missing the last one, i.e. the last AA it has.
		my $order_model_plus = $order_model + 1; 
		$regions .= $order_model_plus;
	}
	#######Begin to check whether the longest segment is longer than the threshold length########
	my @regs = split(/;/, $regions);
	print "regions: $regions\n";
	my $max_len = 0;
	foreach my $reg (@regs){
		my @ranges = split(/-/, $reg);
		my $length = $ranges[1] - $ranges[0] + 1;
		if($length > $max_len){
			$max_len = $length;
		}
	}
	if($max_len < $length_threshold){	#If not, don't include this model, go to the next one;
		next; 
	}
	my $central_final = "";
	foreach my $temp (@filtered_central){
		print $temp;
		$central_final .= $temp;
	}
	print "\n";
	my $model_final = "";
        foreach my $temp (@filtered_model){
                print $temp;
		$model_final .= $temp;
        }
        print "\n";
	print "$regions\n";	

	###########OUPUT to the output file#############
	if($central_done eq "false"){
		print OUT ">$central_model_id | dist_threshold: $dist_threshold | continously close regions: N/A\n";	
		print OUT $central_final."\n";
	}
	if($order_model > -1){   #I.E. consider the case that none of the AAs in the template mapped with the central model, i.e. all gaps in the template alignment, just don't print
		print OUT ">$model_id | dist_threshold: $dist_threshold | continously close regions: $regions|\n";
		print OUT $model_final."\n";
	}
	#sleep 1;
	$central_done = "true";
}
close(LIST);
close(OUT);
