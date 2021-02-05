#!/usr/bin/perl -w
#########################################################################
#
#               MULTICOM Protein Structure Prediction System
#                         Author: Jianlin Cheng
#                         2020 Version
#
##########################################################################################
#                       Overall Strategy
# 1. model generation using diverse techniques
# 2. domain-based model generation
# 3. model evaluation (full length and domain based)
# 4. model combination
# New additions to Version 5 (March 12, 2020)
#    (1) Apply hard modeling modeling to all the proteins
#    (2) Add SBROD and distance-based rankings into dash file
#    (3) Generate an average ranking based on ranking of clustering, SBROD, and distance
# New additoins to Version 8 (April 17, 2020)
#    (1) Allow users to provide user-specified domain information to make prediction
#    (2) The domain information is defined in a file whose name is passed in as a parameter
#         Domain definition file format:
#              Each line represents the range of a domain
#              Multiple lines (at least two lines) are required
#              The format of a line is: domain #: range1 range2 ... domain_type(easy or hard) 
#              A range is defined as: start_#:end_#
#         An two-domain definition example as follows: 
#         domain 0:1-136 easy
#         domain 1:137-178 hard
##########################################################################################

$DEBUG = 0; #0: non-debug runtime model; set DEBUG 1 will enter into debug mode and will not generate models 

$manual_domain = 0; #use manual domain information or not
$model_comb_only = 0; #do model combination only, assuming all the models and model ranking information have been generated

if (@ARGV != 3 && @ARGV != 4)
{
	die "need three or four parameters: multicom system option file, query file(fasta), output dir, domain definition file\n";
}

if (@ARGV == 4)
{
	print "The user-defined domain information is provided. Only domain-based predictions will be made.\n";
	$manual_domain = 1; 
}

######################Process Inputs####################################
$system_option = shift @ARGV;
$query_file = shift @ARGV;
$output_dir = shift @ARGV;

if ($manual_domain == 1)
{
	$manual_domain_file = shift @ARGV;
	-f $manual_domain_file || die "The domain definition file: $manual_domain_file does not exist.\n";
}



#convert output_dir to absolute path if necessary
-d $output_dir || die "output dir doesn't exist.\n";

use Cwd 'abs_path';
$output_dir = abs_path($output_dir);
$query_file = abs_path($query_file);
$system_option = abs_path($system_option); 

$domain_insertion = 0;

if ($manual_domain == 1)
{
	$manual_domain_file = abs_path($manual_domain_file);
	@domain_start = ();
	@domain_end   = (); 
	@domain_level = (); 

	open(DOMAIN, $manual_domain_file) || die "can't read $manual_domain_file\n";
	@domain_defs = <DOMAIN>;
	close DOMAIN;
	if (@domain_defs < 2)
	{
		die "There are fewer than two domains. Run the system without the user-defined informmation.\n";
	}	
	
	foreach $domain_line (@domain_defs)
	{
		chomp $domain_line; 

		$start_pos = "";
		$end_pos = "";
		$domain_type = "";

		@domain_fields = split(/:/, $domain_line);
		@domain_fields == 2 || die "The formation of domain definition is incorrect: $domain_line\n";
		$right_part = $domain_fields[1];
		@domain_range_type = split(/\s+/, $right_part);
		@domain_range_type >= 2 || die "The formation of domain definition is incorrect: $domain_line\n"; 
		$domain_type = pop @domain_range_type;
		if ($domain_type ne "easy" && $domain_type ne "hard")
		{
			die "The formation of domain definition is incorrect: $domain_line\n";
		}
		push @domain_level, $domain_type;

		if (@domain_range_type > 1)
		{
			$domain_insertion = 1;
		}
		
		foreach $dom_range (@domain_range_type)
		{
			@dom_positions = split(/-/, $dom_range);
			@dom_positions == 2 || die "The formation of domain range: $dom_range is not correct.\n";
			if ($start_pos eq "")
			{
				$start_pos = $dom_positions[0]; 
				$end_pos = $dom_positions[1];
			}		
			else
			{

				$start_pos .= ":$dom_positions[0]"; 
				$end_pos .= ":$dom_positions[1]";
			}
		}

		push @domain_start, $start_pos;
		push @domain_end, $end_pos;

	}
	@domain_start >= 2 || die "There are few than two domain start positions.\n";
}

$multicom_dir = ""; 
$meta_option_full_length = "";
$meta_option_easy_domain = "";
$meta_option_hard_domain = "";
$main_dir = ""; 

$final_model_num = 5; 

$cm_model_num = 5; 

$prosys_dir = "";
$modeller_dir = "";
$human_qa_program = "/home/casp13/Human_QA_package/HUMAN/run_CASP13_HumanQA.sh";

#$alignment_for_domain = "hhsuite";
$alignment_for_domain = "hhblits3";

$cluster_ranking = 0;

#read option file
open(OPTION, $system_option) || die "can't read option file.\n";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^multicom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$multicom_dir = $value; 
	}

	if ($line =~ /^main_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$main_dir = $value; 
	}

	if ($line =~ /^meta_option_full_length/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_option_full_length = $value; 
	}

	if ($line =~ /^meta_option_easy_domain/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_option_easy_domain = $value; 
	}

	if ($line =~ /^meta_option_hard_domain/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_option_hard_domain = $value; 
	}

	if ($line =~ /^human_qa_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$human_qa_program = $value; 
	}

	if ($line =~ /^final_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$final_model_num = $value; 
	}

	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}

        if ($line =~ /^cluster_ranking/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $cluster_ranking = $value;
        }

        if ($line =~ /^model_comb_only/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $model_comb_only = $value;
        }

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}

        if ($line =~ /^trrosetta_dir/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $trrosetta_dir = $value;
        }

        if ($line =~ /^self_model/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $self_model = $value;
        }

	if ($line =~ /^tr_lower_threshold/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_lower_threshold = $value; 
	}

	if ($line =~ /^tr_upper_threshold/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_upper_threshold = $value; 
	}

	if ($line =~ /^tr_interval_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_interval_size = $value; 
	}

	if ($line =~ /^tr_process_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tr_process_num = $value; 
	}

	if ($line =~ /^alignment_for_domain/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$alignment_for_domain = $value; 
	}

}
close OPTION; 

#check the options
-d $multicom_dir || die "can't find multicom dir: $multicom_dir.\n";
-d $main_dir || die "can't find main dir: $main_dir.\n";
-f $meta_option_full_length || die "can't find meta full length option: $meta_option_full_length.\n";
-f $meta_option_easy_domain || die "can't find meta easy domain option: $meta_option_easy_domain.\n";
-f $meta_option_hard_domain || die "can't find meta hard domain option: $meta_option_hard_domain.\n";
-d $trrosetta_dir || die "can't find trRosetta dir: $trrosetta_dir.\n";
-f $self_model || die "can't find $self_model.\n";

$tr_lower_threshold >= 0 && $tr_lower_threshold <= 1 || die "The lower threshold of trRosetta is out of range.\n";
$tr_upper_threshold >= 0 && $tr_upper_threshold <= 1 || die "The upper threshold of trRosetta is out of range.\n";
$tr_lower_threshold <= $tr_upper_threshold || die "The lower threshold is greater than the upper threshold.\n";
$tr_interval_size >= 0 && $tr_interval_size <= 1 || die "The threshold interval size of trRosetta is out of range.\n";
$tr_process_num >= 1 && $tr_process_num <= 50 || die "The number of processes is out of range.\n";

if ($model_comb_only == 1)
{
	print "Only modeling combination will be performed, assuming that models and  model rankings have been generated in the output directory.\n";
}


###############################DeepRank QA will be added later###########################
#-f $human_qa_program || die "can't find $human_qa_program.\n";
#########################################################################################

#get query name and sequence 
open(FASTA, $query_file) || die "can't read fasta file.\n";
$query_name = <FASTA>;
chomp $query_name; 
$qseq = <FASTA>;
chomp $qseq;
close FASTA;
$query_length = length($qseq); 

$qlen = length($qseq); 

#rewrite fasta file if it contains lower-case letter
if ($qseq =~ /[a-z]/)
{
	print "There are lower case letters in the input file. Convert them to upper case.\n";
	$qseq = uc($qseq);
	open(FASTA, ">$query_file") || die "can't rewrite fasta file.\n";
	print FASTA "$query_name\n$qseq\n";
	close FASTA;
}

if ($query_name =~ /^>/)
{
	$query_name = substr($query_name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}
####################################End of Process Inputs#################
#enter into the output directory
chdir $output_dir; 


#get query file name
$pos = rindex($query_file, "/");
$query_file_name = $query_file;
if ($pos >= 0)
{
	$query_filename = substr($query_file_name, $pos + 1); 
}

$full_length_dir = $output_dir . "/full_length";

if ($manual_domain == 1)
{
	goto DOMAIN_PREDICTION;
}

#Generate full length model
`mkdir $full_length_dir`; 

print "Step1: generate full length models...\n";

if ($alignment_for_domain eq "hhblits3")
{
	$hhsearch_local_alignment = "$full_length_dir/hhblits3/$query_filename.local.org";
	if (! -f $hhsearch_local_alignment)
	{
		$hhsearch_local_alignment = "$full_length_dir/hhblits3/$query_filename.local";
	}
}
else
{
	$hhsearch_local_alignment = "$full_length_dir/hhsuite/$query_filename.local";
}



#if ($DEBUG == 0 && ! -f $hhsearch_local_alignment)
if ($DEBUG == 0)
{
	#generate full-length model
#	if (length($qseq) <= 650)
#	{
		if ($model_comb_only != 1)
		{
			system("$main_dir/script/multicom_server_va.pl $meta_option_hard_domain $query_file $full_length_dir");
		}
#	}
#	else
#	{
#		if ($model_comb_only != 1)
#		{
#			system("$main_dir/script/multicom_server_v6.pl $meta_option_full_length $query_file $full_length_dir");
#		}
#	}

}
#########################################################################################################


##############################################################################

#get query file name
$pos = rindex($query_file, "/");
$query_file_name = $query_file;
if ($pos >= 0)
{
	$query_filename = substr($query_file_name, $pos + 1); 
}


print "Step 2: identify domains of the protein...\n";

#################################################################################
#   A simple domain identification algorithm
#  (1) hit left part, right is a missing domain
#  (2) hit righ part, left is a missing domain
#  (3) hit a little left, missing an insertion, hit right
#  (4) hit left, missing an in sertioin, hit a little right
#  (5) both left and right are missing. if the length of left and right
#################################################################################

#hhsuite local alignment is used to identify domains
if ($alignment_for_domain eq "hhblits3")
{
	
	$hhsearch_local_alignment = "$full_length_dir/hhblits3/$query_filename.local.org";
	if (! -f $hhsearch_local_alignment)
	{
		$hhsearch_local_alignment = "$full_length_dir/hhblits3/$query_filename.local";
	}
}
else
{
	$hhsearch_local_alignment = "$full_length_dir/hhsuite/$query_filename.local";
}

@local = (); 
$domain_split_comb = 0; 
if (! -f $hhsearch_local_alignment)
{
	print "No local alignment file is found in $alignment_for_domain. Go to model evaluation\n";

	#no significant template is found, run in hard mode
#	if ($DEBUG == 0 && length($qseq) > 650)
#	{
#		$bHard = 1; 
#		$full_length_dir_hard = $output_dir . "/full_length_hard";
#		`mkdir $full_length_dir_hard`; 
#		if ($model_comb_only != 1)
#		{
#			system("$main_dir/script/multicom_server_v6.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
#		}
#		$full_length_dir = $full_length_dir_hard; 
#	}

	`rm $query_file.tmp *.tmp 2>/dev/null`; 

	goto MODEL_EVA; 
}
else
{
	print "Read $alignment_for_domain local alignment file:$hhsearch_local_alignment.\n";
	open(LOCAL, $hhsearch_local_alignment) || die "can't read $hhsearch_local_alignment.\n";
	@local = <LOCAL>;
	close LOCAL; 

	#if the protein is very short, skip domain analysis
	if (length($qseq) < 100)
	{
		`rm $query_file.tmp *.tmp 2>/dev/null`; 
		goto MODEL_EVA; 
	}

}

#return: -1: less; 0: equal; 1: more 
sub comp_evalue
{
	my ($a, $b) = @_;
	#get format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		$formata = "num";
	}
	elsif ($a =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formata = "exp";
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
	}
	else
	{
		die "evalue format error: $a";	
	}

	if ( $b =~ /^[\d\.]+$/ )
	{
		$formatb = "num";
	}
	elsif ($b =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formatb = "exp";
		$b_prev = $1;
		$b_next = $2;  
		if ($1 eq "")
		{
			$b_prev = 1; 
		}
	}
	else
	{
		die "evalue format error: $b";	
	}
	if ($formata eq "num")
	{
		if ($formatb eq "num")
		{
			return $a <=> $b
		}
		else  #bug here
		{
			#a is bigger
			#return 1; 	
			#return $a <=> $b_prev * (10**$b_next); 
			return $a <=> $b_prev * (2.72**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			#return -1; 
			#return $a_prev * (10 ** $a_next) <=> $b; 
			return $a_prev * (2.72 ** $a_next) <=> $b; 
		}
		else
		{
			if ($a_next < $b_next)
			{
				#a is smaller
				return -1; 
			}
			elsif ($a_next > $b_next)
			{
				return 1; 
			}
			else
			{
				return $a_prev <=> $b_prev; 
			}
		}
	}
}
########################End of compare evalue################################


#analyze local alignments to get domain information

$min_domain_length = 40; #used to judge if a domain is missing
$align_id = 0; 

###############################################
#Decide if we need to restart hard from scrach for full length even if there are some short alignments
$hard_coverage = 0.5;
$hard_length = 40; 
$bHard = 1; 

#read local alignments
shift @local; 
while (@local)
{
	shift @local;
	$info = shift @local;
	@fields = split(/\s+/, $info);
	$tname = $fields[0];
	print "Analyze the local alignment of template $tname...";
	$tlen = $fields[1];
	$score = $fields[2]; 
	$evalue = $fields[3];
#	$align_len = $fields[4]; 

	$range = shift @local;
	chomp $range; 
	@fields = split(/\s+/, $range);
	$qstart = $fields[0];
	$qend = $fields[1];
	$tstart = $fields[2];
	$tend = $fields[3]; 
	
	$qalign = shift @local;
	chomp $qalign; 
	$talign = shift @local;
	chomp $talign; 

	$align_id++; 
	$l_len = $qstart - 1; 
	$r_len = $qlen - $qend; 
	
	### this is added on 2018/05/02 to avoid low evalue but low coverage
	if(  &comp_evalue($evalue, 1) > 0  || $tend - $tstart < $hard_length )
	{
		print "Done.\n";
		next;
	}
	
	push @local_list, {
			align_id => $align_id, 		
			idx => -1, 
			qname => $query_name,
			qlen => $qlen,
			tname => $tname,
			tlen => $tlen,
			score => $score, 
			evalue => $evalue,
			qstart => $qstart,
			qend => $qend,
			tstart => $tstart,
			tend => $tend,
			qalign => $qalign,
			talign => $talign,
			ltail_len => $l_len, 
			rtail_len => $r_len, 
			anchor => 0, #whether or not it is an anchor of a scalfold
			inscalfold => 0 #when or not it is within a scalfold
	};

	#check if there is any reasonable template (long enough or cover enough range)
	if ( $tend - $tstart >= $hard_length || ($qend - $qstart) / $query_length >= $hard_coverage )
	{
		$bHard = 0; 
	}
	print "Done.\n";
				
}


if ($bHard == 1)
{
	print "This is a hard target.\n";
}

if (@local_list == 0)
{
	warn "No signficant local alignment information is available to make domain prediction.\n";
        `rm $query_file.tmp *.tmp 2>/dev/null`;
        $domain_def = "$output_dir/domain_info";
        open(DOM_DEF, ">$domain_def");
        print DOM_DEF "domain 0:1-".$qlen." hard\n";
        close DOM_DEF;

#	if ($DEBUG == 0 && length($qseq) > 650)
#	{
#		$bHard = 1; 
#		$full_length_dir_hard = $output_dir . "/full_length_hard";
#		`mkdir $full_length_dir_hard`; 
#		if ($model_comb_only != 1)
#		{
#			system("$main_dir/script/multicom_server_v6.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
#		}
#		$full_length_dir = $full_length_dir_hard; 
#	}
        `rm $query_file.tmp *.tmp 2>/dev/null`;
        goto MODEL_EVA;
}


print "Check if front or end domains are missing...\n";
$left_domain_missing = 10000;
$right_domain_missing = 10000; 

$first_left_len = 0;
$first_right_len = 0; 
for ($i = 0; $i < @local_list; $i++)
{
	$local = $local_list[$i]; 	
	if ( ($i == 0 || &comp_evalue($local->{"evalue"}, 1) < 0 ) && $local->{"ltail_len"} < $left_domain_missing && ($local->{"qend"} - $local->{"qstart"} + 1 >= $min_domain_length) )
	{
		$left_domain_missing = $local->{"ltail_len"}; 
		if ($i == 0)
		{
			$first_left_len = $left_domain_missing; 
		}
	}
	if ( ($i == 0 || &comp_evalue($local->{"evalue"}, 1) < 0 ) && $local->{"rtail_len"} < $right_domain_missing && ($local->{"qend"} - $local->{"qstart"} + 1 >= $min_domain_length) )
	{
		$right_domain_missing = $local->{"rtail_len"}; 
		if ($i == 0)
		{
			$first_right_len = $right_domain_missing; 
		}
	}
}

if ($left_domain_missing >= $min_domain_length)
{
		print "The left domain of $left_domain_missing residues is not covered. Suggested left domain size for domain splitting is $first_left_len.\n";
}
else
{
	#recheck  if left is msising based on pir alignment
	#recheck if left of right is missing based on pir alignment
	if ($alignment_for_domain eq "hhblits3")
	{
		$hhsearch_pir_file = "$full_length_dir/hhblits3/hhbl1.pir";
	}
	else
	{
		$hhsearch_pir_file = "$full_length_dir/hhsuite/hhsuite1.pir";
	}

	if (-f $hhsearch_pir_file)
	{

	open(HHPIR, $hhsearch_pir_file) || die "can't open $hhsearch_pir_file.\n";
	@hhsearch_pir_con = <HHPIR>;
	close HHPIR; 

	$query_align_seq =  pop @hhsearch_pir_con;
	chomp $query_align_seq;
	chop $query_align_seq;
	pop @hhsearch_pir_con; 
	pop @hhsearch_pir_con; 
	pop @hhsearch_pir_con; 

	$min_left_miss_region = 1000000; 
	while (@hhsearch_pir_con)
	{
		$left_miss_region = 0; 	
		$hh_title = shift @hhsearch_pir_con;
		chomp $hh_title;
		shift @hhsearch_pir_con;
		shift @hhsearch_pir_con;
		$temp_align = shift @hhsearch_pir_con;
		chomp $temp_align;
		chop $temp_align;
		shift @hhsearch_pir_con;
		@hh_fields = split(/\s+/, $hh_title);
		pop @hh_fields;
		$hh_evalue = pop @hh_fields;
		if ( &comp_evalue($hh_evalue, 0.1) > 0 )
		{
			next;
		}
		
		#check the length covered by the template
		$cover_length = 0; 
		for ($i = 0; $i < length($query_align_seq); $i++)
		{
			if (substr($query_align_seq, $i, 1) ne "-" && substr($temp_align, $i, 1) ne "-")
			{
				$cover_length++; 
			}
		} 
		if ($cover_length < 30)
		{
			next;
		} 

		#count how many left residues are missing
		for ($i = 0; $i <= length($query_align_seq)-1; $i++)
		{
			if (substr($query_align_seq, $i, 1) ne "-" && substr($temp_align, $i, 1) ne "-")
			{
				last;
			}
			
			if (substr($query_align_seq, $i, 1) ne "-" && substr($temp_align, $i, 1) eq "-")
			{
				$left_miss_region++; 	
			}
		} 
		
		if ($left_miss_region < $min_left_miss_region)
		{
			$min_left_miss_region = $left_miss_region; 
		}

	}
	if ($min_left_miss_region >= $min_domain_length)
	{
		$left_domain_missing = $min_left_miss_region; 

		print "the number of residues missed in the left domain: $left_domain_missing\n";
	}


	}
	



}

if ($right_domain_missing >= $min_domain_length)
{
		print "The right domain of $right_domain_missing residues is not covered. Suggested right domain size for domain splitting is $first_right_len.\n";
}
else
{
	#recheck if left of right is missing based on pir alignment
	if ($alignment_for_domain eq "hhblits3")
	{
		$hhsearch_pir_file = "$full_length_dir/hhblits3/hhbl1.pir";
	}
	else
	{
		$hhsearch_pir_file = "$full_length_dir/hhsuite/hhsuite1.pir";
	}

	if (-f $hhsearch_pir_file)
	{



	open(HHPIR, $hhsearch_pir_file) || die "can't open $hhsearch_pir_file.\n";
	@hhsearch_pir_con = <HHPIR>;
	close HHPIR; 

	$query_align_seq =  pop @hhsearch_pir_con;
	chomp $query_align_seq;
	chop $query_align_seq;
	pop @hhsearch_pir_con; 
	pop @hhsearch_pir_con; 
	pop @hhsearch_pir_con; 

	$min_right_miss_region = 1000000; 
	while (@hhsearch_pir_con)
	{
		$right_miss_region = 0; 	
		$hh_title = shift @hhsearch_pir_con;
		chomp $hh_title;
		shift @hhsearch_pir_con;
		shift @hhsearch_pir_con;
		$temp_align = shift @hhsearch_pir_con;
		chomp $temp_align;
		chop $temp_align;
		shift @hhsearch_pir_con;
		@hh_fields = split(/\s+/, $hh_title);
		pop @hh_fields;
		$hh_evalue = pop @hh_fields;
		if ( &comp_evalue($hh_evalue, 0.1) > 0 )
		{
			next;
		}
		
		#check the length covered by the template
		$cover_length = 0; 
		for ($i = 0; $i < length($query_align_seq); $i++)
		{
			if (substr($query_align_seq, $i, 1) ne "-" && substr($temp_align, $i, 1) ne "-")
			{
				$cover_length++; 
			}
		} 
		if ($cover_length < 30)
		{
			next;
		} 

		#count how many right residues are missing
		for ($i = length($query_align_seq) -1 ; $i >= 0; $i--)
		{
			if (substr($query_align_seq, $i, 1) ne "-" && substr($temp_align, $i, 1) ne "-")
			{
				last;
			}
			
			if (substr($query_align_seq, $i, 1) ne "-" && substr($temp_align, $i, 1) eq "-")
			{
				$right_miss_region++; 	
			}
		} 
		
		if ($right_miss_region < $min_right_miss_region)
		{
			$min_right_miss_region = $right_miss_region; 
		}

	}
	if ($min_right_miss_region >= $min_domain_length)
	{
		$right_domain_missing = $min_right_miss_region; 

		print "the number of residues missed in the right domain: $right_domain_missing\n";
	}


	}


}

#check if there is domain insertion based on the longest gaps
$longest_gap_len = 0;
$longest_gap_start = -1; 
$longest_gap_end = -1; 
$domain_insertion = 0;
if (@local_list > 0)
{
	#insertion is based on the most significant local alignment (top 1)
	$local = $local_list[0];  
	$talign = $local->{"talign"}; 
	$tstart = $local->{"tstart"};
	$tend   = $local->{"tend"}; 
	$qalign = $local->{"qalign"}; 
	$qstart = $local->{"qstart"};
	$qend   = $local->{"qend"};
	

	$gap_state = 0; 
	$gap_len = 0; 
	#the index of the current amino acid in sequence, starting from 1 
	$qindex =  $qstart - 1; 
	$gap_start = -1;
	$gap_end = -1; 

	$align_len = length($talign);
	for ($i = 0; $i < $align_len; $i++)
	{
		$qaa = substr($qalign, $i, 1); 
		if ($qaa ne "-")
		{
			++$qindex; 
		}
		$aa = substr($talign, $i, 1); 		
		if ($aa eq "-")
		{
			if ($gap_state == 0)
			{
				$gap_state = 1;
				$gap_len = 1; 
				$gap_start = $qindex; 
			}			
			else
			{
				++$gap_len;
			}
		}	
		else
		{
			if ($gap_state == 1)
			{
				$gap_end = $qindex - 1; 	
				if ($gap_len > $longest_gap_len)
				{
					$longest_gap_len = $gap_len; 
					$longest_gap_start = $gap_start;
					$longest_gap_end = $gap_end; 
				}
				
				
			}
			
			$gap_state = 0; 
			$gap_len = 0; 
			$gap_start = $gap_end = -1; 
		}
	} 

	if ($longest_gap_len >= $min_domain_length)
	{
		print "Find an inserted domain of $longest_gap_len residues in range ($longest_gap_start, $longest_gap_end).\n";
		$domain_insertion = 1;
	}
}

#assign domain information

#check the left side first
@domain_start = ();
@domain_end   = (); 
@domain_level = (); 

if ( $left_domain_missing >= $min_domain_length )
{
	print "Add left missing domain.\n";
	#@start = (1); 		
	#@end = ($first_left_len); 
	push @domain_start, "1"; 
	push @domain_end, "$first_left_len"; 
	push @domain_level, "hard";
}	

$hard_case = 0; 
$local_case = $local_list[0]; 
if ( &comp_evalue($local_case->{"evalue"}, 1) > 0 )
{
	$hard_case = 1; 
}

#check middle (domain insertion) 
if ($longest_gap_len >= $min_domain_length)
{
	#get the dis-continuous domain first		
	#the first fragment
	if ($left_domain_missing < $min_domain_length)
	{
		#extend left front to the beginning 
		$start = "1"; 	
	}			
	else
	{
		$value = $first_left_len + 1;  
		$start = "$value"; 
	}
	$end = $longest_gap_start - 1;
	#the second fragment
	$value = $longest_gap_end + 1;
	$start = "$start:$value";  
	if ($right_domain_missing < $min_domain_length)
	{
		$end = "$end:$qlen"; 
	}
	else
	{
		$value = $qlen - $first_right_len; 
		$end = "$end:$value"; 
	}

	push @domain_start, $start;
	push @domain_end, $end; 
	if ($hard_case == 0)
	{
		push @domain_level, "easy"; 
	}
	else
	{
		push @domain_level, "hard"; 
	}

	#get the inserted domain
	$start = "$longest_gap_start";
	$end = "$longest_gap_end";
	push @domain_start, $start;
	push @domain_end, $end; 
	push @domain_level, "hard";
} 
else #no inserted domain
{
	if ($left_domain_missing < $min_domain_length)
	{
		#extend left front to the beginning 
		$start = "1"; 	
	}			
	else
	{
		$value = $first_left_len + 1;
		$start = "$value"; 
	}
	if ($right_domain_missing < $min_domain_length)
	{
		$end = "$qlen"; 
	}
	else
	{
		$value = $qlen - $first_right_len;
		$end = "$value"; 
	}

	push @domain_start, $start;
	push @domain_end, $end; 
	if ($hard_case == 0)
	{
		push @domain_level, "easy"; 
	}
	else
	{
		push @domain_level, "hard"; 
	}
}

#check the right end
if ( $right_domain_missing >= $min_domain_length )
{
	print "Add right missing domain.\n";
	$value = $qlen - $first_right_len + 1;
	$start = "$value"; 		
	$end = "$qlen"; 
	push @domain_start, $start; 
	push @domain_end, $end; 
	push @domain_level, "hard"; 
}	

#############################################################
#check if domain information is correct
#this is a temporary bug fix to avoid running the program
#on the wrong domain information
##############################################################
$wrong = 0; 
for ($i = 0; $i < @domain_start; $i++)
{
        $start = $domain_start[$i];
        @astart = split(/:/, $start);
        $end = $domain_end[$i];
        @aend = split(/:/, $end);
        $domain_length_check = 0;
        for ($j = 0; $j < @astart; $j++)
        {
                $domain_length_check += ($aend[$j] - $astart[$j] + 1) ;
        }
        if ($domain_length_check < $min_domain_length)
        {
                $wrong = 1;
        }
}
if ($wrong == 1)
{
	warn "domain information is wrong. skip domain prediction.\n";
	@domain_start = ();
	@domain_end = (); 

	######################################################################################
	$local = $local_list[0]; 	
#	if (&comp_evalue($local->{"evalue"}, 1) > 0 && length($qseq) > 650)
#	{
		#hard case, not domain prediction. call hard. 
#		print "This is a hard, long target, recall MULTICOM with hard options on the full target.\n";
#		$full_length_dir_hard = $output_dir . "/full_length_hard";
#		`mkdir $full_length_dir_hard`; 
#		if ($DEBUG == 0)
#		{
#			if ($model_comb_only != 1)
#			{
#				system("$main_dir/script/multicom_server_v6.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
#			}
#		}
#		$full_length_dir = $full_length_dir_hard;
#		`rm $query_file.tmp *.tmp 2>/dev/null`; 
#	}
	goto MODEL_EVA;
	######################################
}
#####################################################################
#

DOMAIN_PREDICTION:

#print out domain information
$domain_def = "$output_dir/domain_info"; 
open(DOM_DEF, ">$domain_def");
for ($i = 0; $i < @domain_start; $i++)
{
	print "domain ", $i, ":"; 				
	print DOM_DEF "domain ", $i, ":"; 				
	$start = $domain_start[$i]; 
	@astart = split(/:/, $start); 
	$end = $domain_end[$i]; 
	@aend = split(/:/, $end);  
	for ($j = 0; $j < @astart; $j++)
	{
		print "$astart[$j]-$aend[$j] "; 
		print DOM_DEF "$astart[$j]-$aend[$j] "; 
	}  

	print $domain_level[$i]; 
	print DOM_DEF $domain_level[$i]; 
	print "\n";
	print DOM_DEF "\n";
}
close DOM_DEF; 
#################################################################################
#
#


####################  added by jie to use disorder information to correct domain information 2018/04/28 
if(@domain_start > 1  && length($qseq) > 500 && $domain_insertion == 0 && $manual_domain == 0)
{
	$sequence = $qseq;
	chomp $sequence;

	$disorder_seq="";
	$disorder_file = "$full_length_dir/hhsuite/$query_name.fasta.disorder";
	$domain_file = "$domain_def";
	## get disorder information
	if(!(-e $disorder_file))
	{
		print "Failed to find disorder file $disorder_file, ignore it\n\n";
		for($i=0;$i<length($sequence);$i++)
		{
			$disorder_seq .="N";
		}
	}else{
		open(IN,"$disorder_file");
		@content = <IN>;
		close IN;	
		$disorder_seq_tmp = shift @content;
		$disorder_tmp = shift @content;
		chomp $disorder_seq_tmp;
		chomp $disorder_tmp;
		if($disorder_seq_tmp ne $sequence)
		{
			print "Warning: disorder sequence not match the fasta sequence, ignore it\n$sequence\n$disorder_seq_tmp\n\n";
			for($i=0;$i<length($sequence);$i++)
			{
				$disorder_seq .="N";
			}
		}else{
			$disorder_seq = $disorder_tmp;
		}
	}

	open(IN,"$domain_file");
	@content = <IN>;
	close IN;

	$domain_num = @content;
	print "\n\nTotal $domain_num domains\n\n";

	## correct the domain region if need using disorder information
	@domain_disorder_info=();
	@domain_range_info=();
	foreach $info (@content)
	{
		chomp $info;
		@tmp = split(/\s/,$info);
		$range = $tmp[1];
		@tmp2 = split(':',$range);
		$range2 = $tmp2[1];
		@tmp3 = split('-',$range2);
		$start = $tmp3[0];
		$end = $tmp3[1];
		
		$disorder_region = substr($disorder_seq,$start-1,$end-$start+1);
		$disorder_num=0;
		for($i=0;$i<length($disorder_region);$i++)
		{
			if(substr($disorder_region,$i,1) eq 'T')
			{
				$disorder_num++;
			}
		}
		$ratio = sprintf("%.3f",$disorder_num/length($disorder_region));
		if($ratio > 0.7)
		{
				push @domain_disorder_info,'Disorder';
		}else{
				push @domain_disorder_info,'Normal';
		}
		
		push @domain_range_info,"$start-$end";
	}
	@domain_range_info_corrected = @domain_range_info;
	@domain_disorder_info_corrected = @domain_disorder_info;

	$correct_check=0;
	### check left region 
	$type_cur = $domain_disorder_info_corrected[0];
	$type_next = $domain_disorder_info_corrected[1];
	if($type_cur eq 'Disorder' and ($type_next eq 'Disorder' or $type_next eq 'Normal'))
	{
		## merge two region
		$range_cur = $domain_range_info_corrected[0];
		$range_next = $domain_range_info_corrected[1];
		@range_cur_tmp = split('-',$range_cur);
		$range_cur_start = $range_cur_tmp[0];
		
		@range_next_tmp = split('-',$range_next);
		$range_next_end = $range_next_tmp[1];
		shift @domain_range_info_corrected;
		shift @domain_range_info_corrected;
		shift @domain_disorder_info_corrected;
		shift @domain_disorder_info_corrected;
		
		print "Merging [$range_cur]:$type_cur and [$range_next]$type_next into [$range_cur_start-$range_next_end]\n\n";
		unshift @domain_range_info_corrected,"$range_cur_start-$range_next_end";
		unshift @domain_disorder_info_corrected,"Normal";
		
		$correct_check = 1;
	}
	### check right region 
	$type_cur = $domain_disorder_info_corrected[@domain_disorder_info_corrected-1];
	$type_prev = $domain_disorder_info_corrected[@domain_disorder_info_corrected-2];
	if($type_cur eq 'Disorder' and ($type_prev eq 'Disorder' or $type_prev eq 'Normal'))
	{
		## merge two region
		$range_cur = $domain_range_info_corrected[@domain_disorder_info_corrected-1];
		$range_prev = $domain_range_info_corrected[@domain_disorder_info_corrected-2];
		@range_prev_tmp = split('-',$range_prev);
		$range_prev_start = $range_prev_tmp[0];
		
		@range_cur_tmp = split('-',$range_cur);
		$range_cur_end = $range_cur_tmp[1];
		pop @domain_range_info_corrected;
		pop @domain_range_info_corrected;
		pop @domain_disorder_info_corrected;
		pop @domain_disorder_info_corrected;
		
		print "Merging [$range_cur]:$type_cur and [$range_prev]:$type_prev into [$range_prev_start-$range_cur_end]\n\n";
		push @domain_range_info_corrected,"$range_prev_start-$range_cur_end";
		push @domain_disorder_info_corrected,"Normal";
		
		$correct_check = 1;
	}
	@domain_start = ();
	@domain_end = (); 
	#print out domain information
	$domain_def = "$output_dir/domain_info_withdisorder";
	open(DOM_DEF, ">$domain_def");
	print "\nCorrected domain regions:\n";
	for($i=0;$i<@domain_range_info_corrected;$i++)
	{
		print "domain $i:".$domain_range_info_corrected[$i]." ".$domain_disorder_info_corrected[$i]."\n";
		print DOM_DEF "domain $i:".$domain_range_info_corrected[$i]." ".$domain_disorder_info_corrected[$i]."\n";
		
		@tmp = split('-',$domain_range_info_corrected[$i]);
		
		push @domain_start, $tmp[0] ; 
		push @domain_end, $tmp[1]; 
	}
	close DOM_DEF;


	if($correct_check ==1 and length($qseq)>500)
	{
		`mv $output_dir/domain_info $output_dir/domain_info_original`;
		`cp $output_dir/domain_info_withdisorder $output_dir/domain_info`;
	}
}
#################################################################################




#predict structures of each domain if the query has more than one domain
chdir $output_dir; 

@pir_seq = (); #record pir self alignment between domains and the query sequence
@domain_len = (); 

#generate a gap sequence with with gnum of -. 
sub generate_gaps
{
	my $gnum = $_[0]; 	
	my $gaps = "";
	my $i;
	for ($i = 0; $i < $gnum; $i++)
	{
		$gaps .= "-"; 
	}
	return $gaps; 
}

if (@domain_start > 1) #multiple domain case
{
	$domain_split_comb = 1; 
	for ($i = 0; $i < @domain_start; $i++)
	{
		#create a directory 
		$domain_dir = "$output_dir/domain$i";
		`mkdir $domain_dir`; 

		$start = $domain_start[$i]; 
		@astart = split(/:/, $start); 
		$end = $domain_end[$i]; 
		@aend = split(/:/, $end);  
		
		#create a fasta sequence
		$dom_seq = ""; 

		$prev_idx = 0; 
		$align_seq = "";
		$dlen = 0; 
		for ($j = 0; $j < @astart; $j++)
		{
			$x = $astart[$j]; 
			$y  = $aend[$j]; 

			##########for non-first domain, extend the front size a little
			$FRONT_EXTENT = 5; 
			if ($i > 0 && $j == 0)
			{
				$x -= $FRONT_EXTENT; 
				$x >= 1 || die "domain index error.\n";
			}

			$dom_seq .= substr($qseq, $x - 1, $y - $x + 1); 
			#num of gaps
			$n_gaps = $x - $prev_idx - 1;
			$align_seq .= &generate_gaps($n_gaps);  

			#$align_seq .= $dom_seq; 
			$align_seq .= substr($qseq, $x - 1, $y - $x + 1); 

			$prev_idx = $y; 
			$dlen += ($y - $x + 1); 
		}
		#add end gaps
		$align_seq .= &generate_gaps($qlen - $prev_idx); 			
		push @pir_seq, $align_seq; 
		push @domain_len, $dlen; 

		#create a sequence
		open(DOM, ">domain$i.fasta") || die "can't create file domain$i.\n";	
		print DOM ">domain$i\n";
		print DOM "$dom_seq\n";
		close DOM; 

		#predict the structure of the domain
		#here we need distinguish easy and hard domains
		#we may need to call ab inito appraoches

		print "Generate models for domain $i\n";
		if ($DEBUG == 0)
		{
			if ($model_comb_only != 1)
			{
				system("$main_dir/script/multicom_server_va.pl $meta_option_hard_domain domain$i.fasta $domain_dir"); 
			}
		}
	}	
	`rm $query_file.tmp *.tmp 2>/dev/null`; 

	##############################################################################
	#Combine domain-based distance maps with full-length distance maps and then
	#use trRosetta to generate full-length models from the combined distance maps
	##############################################################################
	#
	# 1. make an output directory for the models
	$full_abinitio_dir = "$output_dir/abinitio";
	`mkdir $full_abinitio_dir`; 
	
	# 2. copy the full length disthond direcotry to the output directory. If full_length directory
	# does not exist, skip all the following steps. 
	$full_disthbond_dir = "$full_length_dir/disthbond";
	if (-d $full_disthbond_dir && $model_comb_only != 1 && ! -f "$full_abinitio_dir/trRosetta1.pdb")
	{
		`cp -r $full_disthbond_dir $full_abinitio_dir`; 
		$full_disthbond_dir = "$full_abinitio_dir/disthbond";
		# 3. combine the domain map with the full length map in the copied disthbond directory
		for ($i = 0; $i < @domain_start; $i++)
		{
			$domain_disthbond_dir = "$output_dir/domain$i/disthbond";
			$start = $domain_start[$i]; 
			@astart = split(/:/, $start); 
			$end = $domain_end[$i]; 
			@aend = split(/:/, $end);  
			if (@astart > 1 || @aend > 1)
			{
				#the domain has multiple segments, too complicated,  do not do combination 
				print "Skip discontinuous domains from combination.\n";
				next;
			}
			
			$domain_start_pos = $astart[0];
			$domain_end_pos = $aend[0]; 
			if ($i > 0)
			{
				#not the first domain, adjust start position
				$domain_start_pos -= $FRONT_EXTENT; 
			}

			$domain_fasta_file = "$output_dir/domain$i.fasta";
			
			#check if the length is consistent
			open(FASTA, $domain_fasta_file) || die "can't read $domain_fasta_file\n";
			<FASTA>;
			$domain_sequence = <FASTA>;
			close FASTA;
			chomp $domain_sequence;
			$domain_end_pos - $domain_start_pos + 1 == length($domain_sequence) || die "the domain sequence length does not match.\n";
			
			print("python $multicom_dir/script/combine_domain.py $full_disthbond_dir $domain_disthbond_dir $domain_start_pos $domain_end_pos\n");
			system("python $multicom_dir/script/combine_domain.py $full_disthbond_dir $domain_disthbond_dir $domain_start_pos $domain_end_pos");
		
		}
		# 4. Use trRosetta to generate models using multiple thresholds and multiple processes
		#   (one threshold per process to speed it up?)
		#
		#print("$trrosetta_dir/run_trRosetta_v2.sh $query_name $query_file $full_disthbond_dir $full_abinitio_dir >$full_abinitio_dir/log.txt 2>&1\n");
		#system("$trrosetta_dir/run_trRosetta_v2.sh $query_name $query_file $full_disthbond_dir $full_abinitio_dir >$full_abinitio_dir/log.txt 2>&1");
		print("$trrosetta_dir/run_trRosetta_v3.sh $query_name $query_file $tr_lower_threshold $tr_upper_threshold $tr_interval_size $tr_process_num $full_disthbond_dir $full_abinitio_dir >$full_abinitio_dir/log.txt 2>&1\n");
		system("$trrosetta_dir/run_trRosetta_v3.sh $query_name $query_file $tr_lower_threshold $tr_upper_threshold $tr_interval_size $tr_process_num $full_disthbond_dir $full_abinitio_dir >>$full_abinitio_dir/log.txt 2>&1");

		# 5. copy the top 10 models into full_length_dir/meta/ to be ranked
		opendir(TRROSETTA, $full_abinitio_dir);
		@files = readdir TRROSETTA;
		closedir TRROSETTA; 	
		while (@files)
		{
			$abinitio_file = shift @files;
			if ($abinitio_file =~ /^trRosetta\d+\.pdb$/)
			{
                                system("$multicom_dir/script/process_trrosetta_chain_id.pl $full_abinitio_dir/$abinitio_file");

				#do self modeling
				use Cwd; 
				$cwd = getcwd;
				chdir $full_abinitio_dir;
				system("$self_model $abinitio_file self$1");
				if (-f "self$1.pdb")
				{
					`mv $abinitio_file $abinitio_file.org`; 
					`mv self$1.pdb $abinitio_file`; 
				}
				else
				{
					print "failed to remodel $abinitio_file\n";
				}
				chdir $cwd; 

				`cp $full_abinitio_dir/$abinitio_file $full_length_dir/meta/meta_f_$abinitio_file`; 
			}
		}
		# ############################################################################
		# re-evaluate the models with other models
	        system("$main_dir/script/multicom_server_va.pl $meta_option_hard_domain $query_file $full_length_dir");
		##############################################################################
	}
}
else
{
	`rm $query_file.tmp *.tmp 2>/dev/null`; 
	goto MODEL_EVA; 	
}


############################model evaluation###########################################
MODEL_EVA:

if ($model_comb_only != 1)
{
	print "Evaluate models based on template, alignments, and structural similarity.\n";
}

#pairwise model comparison score has been generated for the full-length models and domain models

#Generate a template and alignment perspective view for full-length models 
if ($manual_domain == 0)
{
	if ($model_comb_only != 1)
	{
		system("$multicom_dir/script/analyze_alignments_v3.pl    $full_length_dir/meta/   $full_length_dir/meta/$query_name.align");
	}
}

#generate dashboard for full length models
#generate a comprehensive view of all the models (full length, or domains)
#information includes: alignment information (method, template, freq, identity, coverage
#evalue of the top template)
#model max, tm, gdt-ts
#ab initio models do not have alignment information

#system("$multicom_dir/script/gen_dashboard_v4.pl $full_length_dir/meta/ $query_name $output_dir/full_length.dash");  
if ($manual_domain == 0)
{	
	if ($model_comb_only != 1)
	{
		system("$multicom_dir/script/gen_dashboard_v7.pl $full_length_dir/meta/ $query_name $output_dir/full_length.dash");  
	}
}

#Generate a template and alignment view for each domain
if ($domain_split_comb == 1 || $manual_domain == 1)
{
	my $domain_num = @pir_seq; 
	for ($i = 0; $i < $domain_num; $i++)
	{
		$model_dir = "$output_dir/domain$i/meta/";
		
		if ($model_comb_only != 1)
		{
			system("$multicom_dir/script/analyze_alignments_v3.pl    $model_dir   $output_dir/domain$i/meta/domain$i.align");
			system("$multicom_dir/script/gen_dashboard_v7.pl $model_dir domain$i $output_dir/domain$i.dash"); 
		}
	}
}


#############################model combination#########################################
MODEL_COMB:

if ($manual_domain == 0)
{

	#From 2020, full-length models are ranked according to tm-scores rather than gdt-ts scores.
	print "Combine full-length models based on based on pairwise tm-score. The results are stored in mcomb...\n";
	#system("$multicom_dir/script/combine_models.pl $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");

	if ($DEBUG == 0)
	{

		if ($cluster_ranking == 1)
		{
			print "Considering model clustering when combining full-length models.\n";
			system("$multicom_dir/script/combine_models_gdt_tm_v5.pl $system_option $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");
		}
		else
		{
			#print "$multicom_dir/script/combine_models_gdt_tm_v4.pl $system_option $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/\n";
			system("$multicom_dir/script/combine_models_gdt_tm_v4.pl $system_option $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");
			
		}
	}
	#check if combined model is very similar to the top ranked model
	#If not, it needs to be reverted back to the top ranked model
	#This will help avoid big deviation from the top model
	system("$multicom_dir/script/top2comb_v2020.pl $system_option $output_dir/mcomb/ $output_dir/mcomb/consensus.eva 0.92"); 
	system("$multicom_dir/script/rank_to_model_list.pl $output_dir/mcomb/consensus.eva $output_dir/mcomb/cscore.eva"); 
#######################################################################
#
	`mkdir $output_dir/top_full_models`; 
	print "Select full-length models based on based on average ranking. The results are stored in top_full_models...\n";
	system("$multicom_dir/script/combine_models_ave_rank.pl $system_option $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/top_full_models/");

}
#
#######################################################################

####################################Comprehensive Model Quality Assessment############################
MODEL_ASSESSMENT:



print "Combined the models of domains if necessary.\n";


###########################################################################################
#do combination
DOMAIN_COMB:

#######################################################################################################
#Do domain combination using clustering-based ranking
#######################################################################################################

if ($domain_split_comb == 1 || $manual_domain == 1)
{
	print "Combine domains into full-length models based on pairwise GDT-TS scores...\n";

	my $domain_num = @pir_seq; 
	my @domain_models = (); 

	#get all the ranked strucural models of each domain
	for ($i = 0; $i < $domain_num; $i++)
	{
		#domain model directory
		$domain_dir = "$output_dir/domain$i/meta/";

		#scoring file of ranking domain models according to tm scores
		$rank_file = $domain_dir . "domain$i.tm";

		open(RANK, $rank_file) || die "can't open $rank_file.\n";
		@rank = <RANK>;
		close RANK; 		

		$model = ""; 
		shift @rank; 
		shift @rank; 
		shift @rank; 
		shift @rank; 

		#check if the sbrod ranking is needed
		$max_tm_score = $rank[0]; 
		chomp $max_tm_score; 
		@fields = split(/\s+/, $max_tm_score); 
		$max_tm_score = $fields[1]; 
		if ($max_tm_score < 0.2)
		{
			print "The maximum pairwise tm-score is less than 0.2. Swtich to use SBROD ranking.\n";
			$rank_file = $domain_dir . "domain$i.sbrod";
			if (-f $rank_file)
			{
				open(RANK, $rank_file) || die "can't open $rank_file.\n";
				@rank = <RANK>;
				close RANK; 		
			}
		}

		#store the names of all ranked models according to their ranking
		foreach $record (@rank)
		{
			@fields = split(/\s+/, $record); 
			$model_id = $fields[0]; 
			$model .= "$domain_dir$model_id "; 
		}	
		push @domain_models, $model; 	
	}

	#generate pir alignments and models for each combination
	$comb_dir = $output_dir . "/comb/";
	$atom_dir = $comb_dir . "atom/";

	`mkdir $comb_dir $atom_dir`; 

	#generate five combined models
	for ($i = 0; $i < $final_model_num; $i++)
	{
		#generate pir alignment for each combination	
		$idx = $i + 1; 
		$pir_file = $comb_dir . "comb$idx.pir";

		open(PIR, ">$pir_file") || die "can't create pir file $pir_file.\n";
		for ($j = 0; $j < $domain_num; $j++)
		{
			print PIR "C;combination $i, domain $j\n";

			$model_names = $domain_models[$j];   
			@mnames = split(/\s+/, $model_names); 
			$model_file = $mnames[$i]; 

			$model_name = substr($model_file, rindex($model_file, "/") + 1, rindex($model_file, ".") - rindex($model_file, "/") -1);   			
			
			$model_name .= "_dom$j";
			print PIR ">P1;$model_name\n";
			#copy the file to the atom dir
			`cp -f $model_file $atom_dir/$model_name.atom`; 
			`gzip -f $atom_dir/$model_name.atom`; 
			$dlen = $domain_len[$j]; 
			print PIR "structureX:$model_name: 1: : $dlen: : : : : \n"; 
			print PIR "$pir_seq[$j]*\n\n";
		}
		print PIR "C; combination of multiple domains\n"; 
		print PIR ">P1;comb$idx\n";
		print PIR " : : : : : : : : : \n";
		print PIR "$qseq*\n";
		close PIR; 

		#generate models
		print "Use Modeller to generate models combining multiple domains...\n";

		if ($DEBUG == 0)
		{
			system("$prosys_dir/script/pir2ts_energy_v2020.pl $prosys_dir $modeller_dir $atom_dir $comb_dir $pir_file $cm_model_num");  	
		}

		if ( -f "$comb_dir/comb$idx.pdb")
		{
			print "A combined model $comb_dir/comb$idx.pdb is generated.\n";
			system("$prosys_dir/script/clash_check.pl $query_file $comb_dir/comb$idx.pdb > $comb_dir/comb$idx.clash");
		}

		#create a pir file with loop
		print "Create pir file with loops...\n";
		$loop_pir_file = $comb_dir . "loop$idx.pir";
		$loop_length = 1; 
		system("$multicom_dir/script/add_loop_into_pir.pl $pir_file $loop_length $loop_pir_file loop$idx");
		
		#generate models
		print "Use Modeller to generate models combining multiple domains with loops...\n";

		if ($DEBUG == 0)
		{
			system("$prosys_dir/script/pir2ts_energy_v2020.pl $prosys_dir $modeller_dir $atom_dir $comb_dir $loop_pir_file $cm_model_num");  	
		}

		if ( -f "$comb_dir/loop$idx.pdb")
		{
			print "A combined model with loops $comb_dir/loop$idx.pdb is generated.\n";
			system("$prosys_dir/script/clash_check.pl $query_file $comb_dir/loop$idx.pdb > $comb_dir/loop$idx.clash");
		}
		
	}

}###################################
###############################################End of Combination of Domains by clustering ranking#############
###############################################################################################################


#######################################################################################################
#Do domain combination using average ranking
#######################################################################################################

if ($domain_split_comb == 1 || $manual_domain == 1)
{
	print "Combine domains into full-length models based on average rankings...\n";

	my $domain_num = @pir_seq; 
	my @domain_models = (); 

	#get all the ranked strucural models of each domain
	for ($i = 0; $i < $domain_num; $i++)
	{
		#domain model directory
		$domain_dir = "$output_dir/domain$i/meta/";

		#scoring file of ranking domain models according to tm scores
		$rank_file = $domain_dir . "domain$i.ave";

		open(RANK, $rank_file) || die "can't open $rank_file.\n";
		@rank = <RANK>;
		close RANK; 		

		$model = ""; 

		#store the names of all ranked models according to their ranking
		foreach $record (@rank)
		{
			@fields = split(/\s+/, $record); 
			$model_id = $fields[0]; 
			$model .= "$domain_dir$model_id "; 
		}	
		push @domain_models, $model; 	
	}

	#generate pir alignments and models for each combination
	$comb_dir = $output_dir . "/top_domain_comb/";
	$atom_dir = $comb_dir . "atom/";

	`mkdir $comb_dir $atom_dir`; 

	#generate five combined models
	for ($i = 0; $i < $final_model_num; $i++)
	{
		#generate pir alignment for each combination	
		$idx = $i + 1; 
		$pir_file = $comb_dir . "comb$idx.pir";

		open(PIR, ">$pir_file") || die "can't create pir file $pir_file.\n";
		for ($j = 0; $j < $domain_num; $j++)
		{
			print PIR "C;combination $i, domain $j\n";

			$model_names = $domain_models[$j];   
			@mnames = split(/\s+/, $model_names); 
			$model_file = $mnames[$i]; 

			$model_name = substr($model_file, rindex($model_file, "/") + 1, rindex($model_file, ".") - rindex($model_file, "/") -1);   			
			
			$model_name .= "_dom$j";
			print PIR ">P1;$model_name\n";
			#copy the file to the atom dir
			`cp -f $model_file $atom_dir/$model_name.atom`; 
			`gzip -f $atom_dir/$model_name.atom`; 
			$dlen = $domain_len[$j]; 
			print PIR "structureX:$model_name: 1: : $dlen: : : : : \n"; 
			print PIR "$pir_seq[$j]*\n\n";
		}
		print PIR "C; combination of multiple domains\n"; 
		print PIR ">P1;comb$idx\n";
		print PIR " : : : : : : : : : \n";
		print PIR "$qseq*\n";
		close PIR; 

		#generate models
		print "Use Modeller to generate models combining multiple domains...\n";

		if ($DEBUG == 0)
		{
			system("$prosys_dir/script/pir2ts_energy_v2020.pl $prosys_dir $modeller_dir $atom_dir $comb_dir $pir_file $cm_model_num");  	
		}

		if ( -f "$comb_dir/comb$idx.pdb")
		{
			print "A combined model $comb_dir/comb$idx.pdb is generated.\n";
			system("$prosys_dir/script/clash_check.pl $query_file $comb_dir/comb$idx.pdb > $comb_dir/comb$idx.clash");
		}

		$loop_pir_file = $comb_dir . "loop$idx.pir";
		$loop_length = 5; 
		system("$multicom_dir/script/add_loop_into_pir.pl $pir_file $loop_length $loop_pir_file loop$idx");
		print "Use Modeller to generate models combining multiple domains with loops...\n";

		if ($DEBUG == 0)
		{
			system("$prosys_dir/script/pir2ts_energy_v2020.pl $prosys_dir $modeller_dir $atom_dir $comb_dir $loop_pir_file $cm_model_num");  	
		}

		if ( -f "$comb_dir/loop$idx.pdb")
		{
			print "A combined model $comb_dir/loop$idx.pdb with loops is generated.\n";
			system("$prosys_dir/script/clash_check.pl $query_file $comb_dir/loop$idx.pdb > $comb_dir/loop$idx.clash");
		}
		
	}

}###################################
###############################################End of Combination of Domains by clustering ranking#############
###############################################################################################################


#####################################################
#Do special domain combination for domain insertion
#####################################################




##########################################################################################


MODEL_SELECTION:

########Select final top five models################################################################
#Baseline approach: select five models based on pairwise gdt-ts score ranking and model clustering (MULTICOM-CLUSTER) in ./mcomb diretory for full-length, in ./comb for domain-based combination.
#Advanced approach: use deep learning ranking and model clustering (MULTICOM-CONSTRUCT) in ./deep for full length in ./comb for domain-based combination
#Issue 1: how to handle multi-domain models and full length model: average score of multiple domains versus full-length score
#and check if full length model has good coverage of each domain and check if ab initio domain exists. check the predicted quality and alignment
#of full-length model
#Issue 2: how to handle domain insertion. One hard domain is inserted into a template-based domain
####################################################################################################

###################################################
#Convert models in mcomb and cluster directory  into CASP format (the code needs to be executed at the end of the model selection.
#The code needs to be updated as well.

if ($manual_domain == 0)
{
	print "Convert top five models in mcomb and/or comb into CASP format.\n";
	system("$multicom_dir/script/convert2casp_v7_simple_v2020.pl $system_option $prosys_dir $multicom_dir $output_dir $query_name $query_file $full_length_dir"); 
}

###########################################################################################

#create a readme.txt to describe the output

open(README, ">$output_dir/readme.txt") || die "can't create the final readme file.\n";
print README "full_length.dash: the score and information of all full-length models\n";
print README "full_length: top five combined full-length models according to clustering or SBROD scores\n";
print README "In full_length/disthbond/full_length/aln/alnstat/, multiple sequence alignments and number of sequences or effective sequences in alignments can be found.\n";
print README "In full_length/betacon/, prediction of secondary structure and solvent accessibility can be found.\n";
print README "In full_length/hhsuite/, disorder and domain predictions can be found.\n";
print README "domain_info: the prediction of domains\n";
print README "domain#.fasta: the sequence of Domain #\n";
print README "domain#.dash: the score and information of models of Domain #\n";
print README "domain#: the models of Domain #\n";
print README "abinitio: ab initio model generated from combined distance maps generated by trRosetta.\n";
print README "comb: the combined full-length models of multiple domains according to cluster or SBROD scores.\n";
print README "top_full_models: top full-length models according to average ranking of clustering, SBROD, and distances\n";
print README "top_domain_comb: top combined full-length models of multiple domains according to the average ranking\n";
print README "Predicted binary contact map in CASP format and real-value distance map are in full_length/disthbond/\n";
print README "ConEva to compare predicted contact map with structural models: http://iris.rnet.missouri.edu/coneva/index.php\n";
close README; 

#delete temporary files
`rm $query_filename.sup 2>/dev/null`; 
print "MULTICOM prediction for $query_name is done.\n";
