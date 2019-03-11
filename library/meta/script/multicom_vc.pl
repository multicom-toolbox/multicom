#!/usr/bin/perl -w
#########################################################################
#
#               MULTICOM Protein Structure Prediction System
#                         Author: Jianlin Cheng
#                         Start date: 1/13/2010
#                         Expected End date: 3/31/2010
#
#########################################################################
#                       Overall Strategy
#
# 1. Generate a full-length model and get domain information (done)
#
# 2. Generate domain models if necessary (by Jan. 20) 
#    CASP8 evaluation should start ( Zheng, start on Jan. 31)
#
#    Still need to add ab initio domain generation. Domain combination 
#    is not done yet. For hard domain, methods to use: rosetta old (5),
#    rosetta new (5), hhsearch15, prc, com, csiblast, spem, sam, multicom, hhsearch, hmmer
#
# 3. Do model evalution at full length / domains and model combination
#    Evaluation is based on AB Initio Evaluation, Templates, and Pairwise
#    Comparison (by Feb. 10) 
#
# 4. AB Initio refinement of tails, long loops, 
#    or even some samll de novo domains (by Feb. 28)
#
# 5. System integration testing (by March 15) 
#
#########################################################################

$DEBUG = 0; #setting this flag to 1 will disable model generation

if (@ARGV != 3)
{
	die "need three parameters: multicom system option file, query file(fasta), output dir\n";
}

######################Process Inputs####################################
$system_option = shift @ARGV;
$query_file = shift @ARGV;
$output_dir = shift @ARGV;

#convert output_dir to absolute path if necessary
-d $output_dir || die "output dir doesn't exist.\n";

use Cwd 'abs_path';
$output_dir = abs_path($output_dir);
$query_file = abs_path($query_file);
$system_option = abs_path($system_option); 

$multicom_dir = ""; 
$meta_option_full_length = "";
$meta_option_easy_domain = "";
$meta_option_hard_domain = "";

$final_model_num = 5; 

$cm_model_num = 5; 

$prosys_dir = "";
$modeller_dir = "";

$tm_score = "/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/software/tm_score/TMscore_32";
$q_score =  "/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/software/pairwiseQA/q_score";

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

	if ($line =~ /^q_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$q_score = $value; 
	}

	if ($line =~ /^tm_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tm_score = $value; 
	}

}
close OPTION; 

#check the options
-d $multicom_dir || die "can't find multicom dir: $multicom_dir.\n";
-f $meta_option_full_length || die "can't find meta full length option: $meta_option_full_length.\n";
-f $meta_option_easy_domain || die "can't find meta easy domain option: $meta_option_easy_domain.\n";
-f $meta_option_hard_domain || die "can't find meta hard domain option: $meta_option_hard_domain.\n";
-f $tm_score || die "can't find $tm_score.\n";
-f $q_score || die "can't find $q_score.\n";

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

#Generate full length model
$full_length_dir = $output_dir . "/full_length";
`mkdir $full_length_dir`; 

print "Generate full length models...\n";


##########################Temporarily comment out this statement for testing#############################

#get query file name
$pos = rindex($query_file, "/");
$query_file_name = $query_file;
if ($pos >= 0)
{
	$query_filename = substr($query_file_name, $pos + 1); 
}
$hhsearch_local_alignment = "$full_length_dir/hhsearch15/$query_filename.local";
if ($DEBUG == 0 && ! -f $hhsearch_local_alignment)
{
	#system("$multicom_dir/script/multicom_server_v7.pl $meta_option_full_length $query_file $full_length_dir"); 
	#system("$multicom_dir/script/multicom_server_v8.pl $meta_option_full_length $query_file $full_length_dir"); 
	#system("$multicom_dir/script/multicom_server_v9.pl $meta_option_full_length $query_file $full_length_dir"); 
	system("$multicom_dir/script/multicom_server_vc.pl $meta_option_full_length $query_file $full_length_dir"); 

}
#########################################################################################################


#####################To Do####################################################
#Convert top five models ranked by ModelEva to CASP format (4/16/2010)
#
#
#
##############################################################################

#get query file name
$pos = rindex($query_file, "/");
$query_file_name = $query_file;
if ($pos >= 0)
{
	$query_filename = substr($query_file_name, $pos + 1); 
}

#################################################################################
#A simple domain identification algorithm
#  (1) hit left part, right is a missing domain
#  (2) hit righ part, left is a missing domain
#  (3) hit a little left, missing an insertion, hit right
#  (4) hit left, missing an in sertioin, hit a little right
#  (5) both left and right are missing. if the length of left and right
#################################################################################
#$hmmer_local_alignment =  "$full_length_dir/hmmer/$query_filename.local"; 
#disable hmmer file for domain prediction
$hmmer_local_alignment = "xxxx";
#$hmmer_local_alignment =  "$output_dir/hmmer/$query_filename.local"; 
$hhsearch_local_alignment = "$full_length_dir/hhsearch15/$query_filename.local";
#$hhsearch_local_alignment = "$output_dir/hhsearch15/$query_filename.local";

#print "$hmmer_local_alignment\n"; 

@local = (); 
$domain_split_comb = 0; 
if (-f $hmmer_local_alignment)
{
	print "read hmmer local alignment file.\n";
	open(LOCAL, $hmmer_local_alignment) || die "can't read $hmmer_local_alignment.\n";
	@local = <LOCAL>;
	close LOCAL; 
}
elsif (-f $hhsearch_local_alignment)
{


	print "Read hhsearch local alignment file.\n";
	open(LOCAL, $hhsearch_local_alignment) || die "can't read $hhsearch_local_alignment.\n";
	@local = <LOCAL>;
	close LOCAL; 

	#check if a significant template was found, if not call hard modeling
	$hhsearch_rank_file = "$full_length_dir/hhsearch15/$query_name.rank";
	open(HHRANK, $hhsearch_rank_file) || die "can't read $hhsearch_rank_file\n";
	@hhrank = <HHRANK>;
	close HHRANK;
	shift @hhrank;
	$template_info = shift @hhrank;
	@temp_fields = split(/\s+/, $template_info);
	#check if a highly likely template is found and it is a short target
	if ($temp_fields[3] < 0.7 && length($qseq) < 200)
	{

		$bHard = 1; 
		$full_length_dir_hard = $output_dir . "/full_length_hard";
		`mkdir $full_length_dir_hard`; 
		system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		$full_length_dir = $full_length_dir_hard; 
		goto MODEL_EVA; 

	}		

}
else
{
	print "No local alignment file is found in hhsearch15 and hmmer. Re-run with hard domain option and ab initio tools. \n";

	#here, we may need to check how good the template is (if score < 0.7, the system should be rerun? )

##################################temporarily disable it for testing##########################################
	if ($DEBUG == 0)
	{
		###########################################################################################
		#here there is a bug, we should output results into full_length_hard (to do)
		###########################################################################################
		$bHard = 1; 
		$full_length_dir_hard = $output_dir . "/full_length_hard";
		`mkdir $full_length_dir_hard`; 
		#system("$multicom_dir/script/multicom_server_hard_v7.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		#system("$multicom_dir/script/multicom_server_hard_v8.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		#system("$multicom_dir/script/multicom_server_hard_v9.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		$full_length_dir = $full_length_dir_hard; 
	}
##############################################################################################################

	`rm $query_file.tmp *.tmp 2>/dev/null`; 

	goto MODEL_EVA; 
}

#analyze local alignments to get domain information

$min_domain_length = 40; #used to judge if a domain is missing (less than 40 will be refined by Rosetta refinement)
$align_id = 0; 

###############################################
#Decide if we need to restart hard from scrach
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
				
}

if ($bHard == 1)
{
	print "This is a hard target, recall MULTICOM with hard options on the full target.\n";
	$full_length_dir_hard = $output_dir . "/full_length_hard";
	`mkdir $full_length_dir_hard`; 
	#system("$multicom_dir/script/multicom_server_hard_v7.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
	#system("$multicom_dir/script/multicom_server_hard_v8.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
	#system("$multicom_dir/script/multicom_server_hard_v9.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
	system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
	$full_length_dir = $full_length_dir_hard;

	`rm $query_file.tmp *.tmp 2>/dev/null`; 
	goto MODEL_EVA;
}


print "Check if front or end domains are missing...\n";

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
	#	if ($a_next > 0)
#		{
	#		die "exponent must be negative or 0: $a\n"; 
#		}
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
	#	if ($b_next > 0)
	#	{
	#		die "exponent must be negative or 0: $b\n"; 
	#	}
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




$left_domain_missing = 10000;
$right_domain_missing = 10000; 

$first_left_len = 0;
$first_right_len = 0; 
for ($i = 0; $i < @local_list; $i++)
{
	$local = $local_list[$i]; 	
#	print $local->{"ltail_len"}, " < ", $left_domain_missing, " ",  $local->{"qend"}, " - ", $local->{"qstart"}, "\n";
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
	$hhsearch_pir_file = "$full_length_dir/hhsearch15/ss1.pir";

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

		print "the number of residues missed in the right domain: $left_domain_missing\n";
	}


	}
	



}

if ($right_domain_missing >= $min_domain_length)
{
		print "The right domain of $right_domain_missing residues is not covered. Suggested left domain size for domain splitting is $first_right_len.\n";
}
else
{
	#recheck if left of right is missing based on pir alignment
	$hhsearch_pir_file = "$full_length_dir/hhsearch15/ss1.pir";

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
	if ($domain_end[$i] - $domain_start[$i] < $min_domain_length)
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
	if (&comp_evalue($local->{"evalue"}, 1) > 0)
	{
		#hard case, not domain prediction. call hard. 
		print "This is a hard target, recall MULTICOM with hard options on the full target.\n";
		$full_length_dir_hard = $output_dir . "/full_length_hard";
		`mkdir $full_length_dir_hard`; 
		system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		$full_length_dir = $full_length_dir_hard;
		`rm $query_file.tmp *.tmp 2>/dev/null`; 
		goto MODEL_EVA;
	}
	######################################
}
#####################################################################



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
	print "\n";
	print DOM_DEF "\n";
}
close DOM_DEF; 
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
		$level = $domain_level[$i]; 
		if ($level eq "easy")
		{

			##############################Temporarily disable model generation#####################
			if ($DEBUG == 0)
			{
				#system("$multicom_dir/script/multicom_server_v7.pl $meta_option_easy_domain domain$i.fasta $domain_dir"); 
				#system("$multicom_dir/script/multicom_server_v8.pl $meta_option_easy_domain domain$i.fasta $domain_dir"); 
				#system("$multicom_dir/script/multicom_server_v9.pl $meta_option_easy_domain domain$i.fasta $domain_dir"); 
				system("$multicom_dir/script/multicom_server_vc.pl $meta_option_easy_domain domain$i.fasta $domain_dir"); 
			}
			#######################################################################################
		}
		else
		{
			##############################Temporarily disable model generation#####################
			if ($DEBUG == 0)
			{
				#system("$multicom_dir/script/multicom_server_hard_v8.pl $meta_option_hard_domain domain$i.fasta $domain_dir"); 
				#system("$multicom_dir/script/multicom_server_hard_v9.pl $meta_option_hard_domain domain$i.fasta $domain_dir"); 
				system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain domain$i.fasta $domain_dir"); 
			}
			#######################################################################################
		}

	}	
	`rm $query_file.tmp *.tmp 2>/dev/null`; 
}
else
{
	`rm $query_file.tmp *.tmp 2>/dev/null`; 
	goto MODEL_EVA; 	
}


#############################domain combination########################################
DOMAIN_COMB:
if ($domain_split_comb == 1)
{
	print "Combine domains into full-length models...\n";

	my $domain_num = @pir_seq; 
	my @domain_models = (); 

	#get the models of each domain
	for ($i = 0; $i < $domain_num; $i++)
	{
		$domain_dir = "$output_dir/domain$i/meta/";
		$rank_file = $domain_dir . "meta.eva";

		open(RANK, $rank_file) || die "can't open $rank_file.\n";
		@rank = <RANK>;
		close RANK; 		

		$model = ""; 
		shift @rank; 
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
		system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $comb_dir $pir_file $cm_model_num");  	

		if ( -f "$comb_dir/comb$idx.pdb")
		{
			print "A combined model $comb_dir/comb$idx.pdb is generated.\n";
		}
		
	}

}

############################model evaluation###########################################
MODEL_EVA:
print "Evaluate models based on template, alignments, and structural similarity.\n";

#Until this point, we have pairwise, model eva, model energy evaluation for full-length
#or domain models 
#So this section, we need to consider template, alignments, identify, and coverage
#domain combined models will not be considered in this step
 
#Selection. Consider the following factors
#Template identity (>0.45), template-evalue, model_eve_energy score, pairwise score
#We need to construct a decision rule to select models
# If (template identify > 0.45 && coverage > 0.70  ------- ask Zheng to do a test
# && pairwise_score with top models > ? && model_eva > ?) --> select
# else  consider other factors 
# I think identify is a very important factors. Learn from CASP8 (find a good threshold) 
# In any case, remember that identity if extremly important as long as the struture is
# similar to other templates
# We need to make this process automatic
# Evaluate is not reliably. so we need to consider identify as the most important factor
# We need to check the template wit with the higest identity and with coverage > 0.7. 
# So, we should pay particular attention to BLAST hits, which is usually the best templlate
# with high identify. 
#template base selection is very import. also need to consider library size
# blast > csblast, csiblast, multicom, psi-blast, sam, hmmer > prc, hhsearch, hhsearch15, com
# > spem (smallest library, but longer alignments)
# first make selection based on blast, then based on weighted templates in csblast, csiblast,
#  multicom, psi-blast, sam, hmmer (need to select long alignments), then select based
# on prc, hhsearh, hhsearch15, com, and then spem, and finally rosetta. Use T0487 as an 
# example.  I notice that sam can generate long alignments covering multiple domains ---
# a good feature (see T0487)
# Model selection: multi-level, in same level, first template (top one), 
# then consider identity, coverage and alignment length, then evalue, then pairwise score, then
# model_eva_energy score

#to avoid outlier, the top models delected by identity should also be ranked high in terms
#of other measures such as pairwise scores, template consensus, and model evaluation
#Output: multi-level ranking tables
#for easy targets, we trust pairwise more. for hard ones (domain combination, we can trust 
#model eva and energy more --- check the evalue thresholds of the templates)
#Deadline: 2/7

#Generate a template and alignment perspective view for full-length models 
system("$multicom_dir/script/analyze_alignments_v2.pl    $full_length_dir/meta/   $full_length_dir/meta/$query_name.align.old");
system("$multicom_dir/script/analyze_alignments_v3.pl    $full_length_dir/meta/   $full_length_dir/meta/$query_name.align");

#generate dashboard for full length models
#generate a comprehensive view of all the models (full length, or domains)
#information includes: alignment information (method, template, freq, identity, coverage
#evalue of the top template)
#, model evaluator score, average ranks of
#model evaluator and model energy, max, tm, gdt-ts, q-score. Ab intio models
#do not have alignment information
system("$multicom_dir/script/gen_dashboard_v2.pl $full_length_dir/meta/ $query_name $output_dir/full_length.dash");  

#Generate a template and alignment view for each domain
if ($domain_split_comb == 1)
{
	my $domain_num = @pir_seq; 
	for ($i = 0; $i < $domain_num; $i++)
	{
		$model_dir = "$output_dir/domain$i/meta/";
		
		system("$multicom_dir/script/analyze_alignments_v2.pl    $model_dir   $output_dir/domain$i/$query_name.align");
		system("$multicom_dir/script/gen_dashboard.pl $model_dir domain$i $output_dir/domain$i.dash"); 
	}
}

#############################model combination#########################################
MODEL_COMB:
#Deadline: 2/14, soon after these we should start to generate models
#Estimate that 6 hours per target * 150 = 900 hours. 
#900 / 24 = 38 days ------------- by 3/31, all the models should be generated
#Evaluation: 4/1 - 4/10. 
#Finalization: 4/10-4/20   
print "Combine models based on model evaluation (reuse MULTICOM-REFINE code).\n";
#system("$multicom_dir/script/combine_models.pl $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");
system("$multicom_dir/script/combine_models_gdt_tm.pl $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");

#######################################################################
#check if combined model is very similar to the top ranked model
#If not, it needs to be reverted back to the top ranked model
#This will help avoid big deviation from the top model
#system("$meta_dir/script/top2comb.pl $model_dir/mcomb/ $model_dir/mcomb/consensus.eva 0.85"); 
system("$multicom_dir/script/top2comb.pl $output_dir/mcomb/ $output_dir/mcomb/consensus.eva 0.88"); 
#######################################################################


#############################model refinement##########################################

#disable model refinment in CASP11
if (0)
{

MODEL_REFINE:
#Deadline: 2/21 (expected, may not)
#final model selection, refinement, and side chain (SCWRL)
#select local regions to refine based on alignment information and local model quality
#assessment
print "Refine full-length models (long loops, tails. need to add local quality assessment into it. reuse MULTICOM-CLUSTER code).\n";
#open(DASH, "$output_dir/full_length.dash"); 
open(DASH, "$output_dir/mcomb/consensus.eva"); 
@dash = <DASH>;
close DASH;
shift @dash;
@fields = split(/\s+/, $dash[0]); 
$model_prefix = $fields[0]; 

$dot_pos = rindex($model_prefix, ".");
$model_prefix = substr($model_prefix, 0, $dot_pos);

$refine_dir = "$output_dir/refine";
`mkdir $refine_dir`; 
$refine_num = 100; 
if ($query_length > 400)
{
	$refine_num = 80; 
}
print "Refine tails of top models if necessary...\n";
#system("$multicom_dir/script/refine_model_tails_v2.pl /home/chengji/cheng_group/bin/run_rosetta_refine.sh $full_length_dir/meta/$model_prefix.pir $full_length_dir/meta/$model_prefix.pdb  $refine_dir $refine_num 2>&1 1>/dev/null");  
system("$multicom_dir/script/refine_model_tails_v2.pl /home/chengji/cheng_group/bin/run_rosetta_refine.sh $full_length_dir/meta/$model_prefix.pir $output_dir/mcomb/casp1.pdb  $refine_dir $refine_num 2>&1 1>/dev/null");  

$model_prefix = "casp1";
#need to evaluate refined models using pairwise model evaluation 
$model_list = $refine_dir . "/model.list";
open(MLIST, ">$model_list") || die "can't create $model_list.\n";
$count = 0; 
for ($i = 1; $i <= $refine_num; $i++)
{
	if (-f "$refine_dir/$model_prefix.$i.pdb")
	{
		print MLIST "$refine_dir/$model_prefix.$i.pdb\n";
		$count++;
	}
}
close MLIST; 

if ($count > 0)
{
	#do pairwise selection of refined models	
	print "Evaluate refined models...\n";
	system("$q_score $model_list $query_file $tm_score $refine_dir $query_name 2>&1 1>/dev/null"); 
	print "Refinement is done.\n";

	########################################
	#to do here
	#Need to update refinement program using Jesse's latest version
	#Need to remove chain id in the refined models
	#Need to convert models into CASP format
	#######################################
}


}

#need to write a program to refine a model given three parameters (pir file / local quaity file, input model, output file name)
#we need to run five processes to refine five models at the same time
#we will use Rosetta_refine and Rosetta_loop to do refinement. We will ignore internal loops because
#according to others' evalution, Modeller is better at internal loop refinment (a BMC structual biology manuscript) 
#write two scripts: one use Rosetta to refine loops and the other use Modeller to refine loops (to do)

MODEL_SELECTION:
#######################################################################################
#select five models for three groups and convert them into CASP format: 
#no model combination, with refinement
#no model combination, no refinement
#model combination, no  refinement
#Implement MULTICOM-CLUSTER model selection method or MULTICOM model selection method (to do)
#Three level model selection: 
# (1) identify & coverage (easy) (and pairwise score - top pairwise score > ?) 
# (2) template frequency (and pairwise score - top pairwise score > ?)
# (3) pairwise comparison (TBM) (and mcheck score - top mcheck score > ?) 
# (4) ab initio+reference (hard case, ab initio)
##########################################################################################
`mkdir $output_dir/select`;
#system("$multicom_dir/script/multi_level_model_selection_v2.pl $full_length_dir/meta/ $output_dir/full_length.dash $output_dir/select");  
system("$multicom_dir/script/multi_level_model_selection_v3.pl $full_length_dir/meta/ $output_dir/full_length.dash $output_dir/select");  

#Generate CASP9 models for three groups: MULTICOM-NOVEL, MULTICOM-REFINE, MULTICOM-CLUSTER
#system("$multicom_dir/script/convert2casp_v2.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file"); 
#system("$multicom_dir/script/convert2casp_v3.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file"); 
#system("$multicom_dir/script/convert2casp_v4.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file"); 

if ($full_length_dir =~ /hard/)
{
	system("$multicom_dir/script/convert2casp_v6.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file $full_length_dir"); 

}
else
{
	system("$multicom_dir/script/convert2casp_v5.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file"); 
}




###########################################################################################

#do more domain combination
#if (-d "$output_dir/comb" && $domain_num > 0)
if (-d "$output_dir/comb" && $domain_split_comb == 1)
{
	my $domain_num = @pir_seq; 
	#system("$multicom_dir/script/combine_domains_v2.pl $prosys_dir $modeller_dir $query_file $output_dir $domain_num"); 	

	#CASP11 change
	#system("$multicom_dir/script/combine_domains_v3.pl $prosys_dir $modeller_dir $query_file $output_dir $domain_num"); 	
	system("$multicom_dir/script/combine_domains_v4.pl $prosys_dir $modeller_dir $query_file $output_dir $domain_num"); 	
}

#generate sov scores for models, may be useful for very hard targets
#CASP11: the casp_roll directory is hard coded. it failed. - disable it. 
#system("/home/chengji/casp8/sov/run_sov.pl $query_name $full_length_dir/meta/ $full_length_dir/meta/$query_name.sov"); 

#generate ss and sa matching scores
system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/casp8/meta/script/get_ss_sa_score.pl $query_file $full_length_dir/meta/ $full_length_dir/meta/model_check > $full_length_dir/meta/$query_name.ss.sa"); 

if (0)   #disable this option in order to save time
{
	#do pairwise model evaluation on the top half models
	$short_dir = "$output_dir/short";
	`mkdir $short_dir`; 
	system("$multicom_dir/script/short_list.pl $full_length_dir/meta/ $query_file $short_dir");

	print "Combine models according to short ranking list...\n";
	system("$multicom_dir/script/global_local_human_coarse_new.pl $multicom_dir  $full_length_dir/meta/ $query_file $short_dir/$query_name.max $short_dir");

	$pdb2casp2 = "$multicom_dir/script/pdb2casp.pl";
	$mdir = $short_dir;
	for ($i = 1; $i <= 5; $i++)
	{
       		 $model_file = "$mdir/casp$i.pdb";
       		 `mv $model_file $model_file.org`;
	        if (-f "$model_file.org")
       		 {
    	            system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/software/scwrl4/Scwrl4 -i $model_file.org -o $mdir/casp$i.scw >/dev/null");
       		         system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/casp8/meta/script/clash_check.pl $query_file $mdir/casp$i.scw > $mdir/clash$i.txt");
       		         system("$pdb2casp2 $mdir/casp$i.scw $i $query_name $mdir/casp$i.pdb");
	        }
	}

}

if (1)   
{
	#do pairwise model evaluation on the top half models
	$compo_dir = "$output_dir/compo";
	`mkdir $compo_dir`; 
	system("$multicom_dir/script/composite_eva_v2.pl $full_length_dir/meta/ $output_dir/full_length.dash $compo_dir");

	print "Select models according to composite ranking list...\n";
	#system("$multicom_dir/script/global_local_human_coarse_new.pl $multicom_dir  $full_length_dir/meta/ $query_file $compo_dir/$query_name.max $short_dir");

	$pdb2casp2 = "$multicom_dir/script/pdb2casp.pl";
	$mdir = $compo_dir;

	#convert models (a)
	for ($i = 1; $i <= 5; $i++)
	{
       		 $model_file = "$mdir/compoa_$i.pdb";
       		 `mv $model_file $model_file.org`;
	        if (-f "$model_file.org")
       		 {
    	            system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/software/scwrl4/Scwrl4 -i $model_file.org -o $mdir/caspa$i.scw >/dev/null");
       		    system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/casp8/meta/script/clash_check.pl $query_file $mdir/caspa$i.scw > $mdir/clasha$i.txt");
       		    system("$pdb2casp2 $mdir/caspa$i.scw $i $query_name $mdir/caspa$i.pdb");
	        }
	}

	#convert models (b)
	for ($i = 1; $i <= 5; $i++)
	{
       		 $model_file = "$mdir/compob_$i.pdb";
       		 `mv $model_file $model_file.org`;
	        if (-f "$model_file.org")
       		 {
    	            system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/software/scwrl4/Scwrl4 -i $model_file.org -o $mdir/caspb$i.scw >/dev/null");
       		    system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/casp8/meta/script/clash_check.pl $query_file $mdir/caspb$i.scw > $mdir/clashb$i.txt");
       		    system("$pdb2casp2 $mdir/caspb$i.scw $i $query_name $mdir/caspb$i.pdb");
	        }
	}

}
#if (-d "$output_dir/comb" && $domain_split_comb == 1)
if (0)
{

	#do more domain-based assessment and combination
	system("$multicom_dir/script/compo_comb.pl $multicom_dir/script/ $output_dir");

	$domain_num = @pir_seq; 

	system("$multicom_dir/script/compo_domains_v2.pl $prosys_dir $modeller_dir $query_file $output_dir $domain_num"); 
}

print "Do domain level assessment and combination if necessary...\n";
$dom_dir = "$output_dir/dom";
`mkdir $dom_dir`; 
#######################################################
#In the future, we may check the quality of models of each domain.
#we can recall modeling to generate ab initio models for hard domains based on their pairwise quality score or single score
#This may help avoid the false domain hit attached with the true positive hit of the other domain (e.g. T0660)
#system("/home/chengji/casp8/casp10_tools/domain_eva/domain_eva_comb_server.pl $query_file $full_length_dir/meta $output_dir/full_length.dash $dom_dir"); 
#
#######################################################

###############################################################################
#use model check 2 to evaluate models. disable. 
if (0)
{
$feature_dir = "$output_dir/features";
`mkdir $feature_dir`; 
$check_dir = "$output_dir/check";
`mkdir $check_dir`; 
system("/storage/htc/bdm/tools/MULTICOM_CLUSTER/sunflower/chengji/casp8/meta/script/model_check_v2.pl $query_file $full_length_dir/meta $feature_dir $check_dir $output_dir/check2.score"); 
}
###############################################################################

#try a new model ranking...
system("$multicom_dir/script/combine_models_v2.pl $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");

#generate the consensus ranking
if ($full_length_dir =~ /hard/)
{

	system("$multicom_dir/script/consensus_model_hard.pl $output_dir $query_name consensus"); 
}
else
{
	system("$multicom_dir/script/consensus_model.pl $output_dir $query_name consensus"); 
}

print "MULTICOM prediction for $query_name is done.\n";
