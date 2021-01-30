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

$tm_score = "/home/chengji/software/tm_score/TMscore_32";
$q_score =  "/home/chengji/software/pairwiseQA/q_score";

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
	#system("$multicom_dir/script/multicom_server_vb.pl $meta_option_full_length $query_file $full_length_dir"); 


	#generate models for the hybrid server. 
	#system("$multicom_dir/script/hybrid_server_v2.pl $output_dir $query_name hybrid"); 
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
	#	system("$multicom_dir/script/multicom_server_hard_vb.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
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
	#	system("$multicom_dir/script/multicom_server_hard_vb.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
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
	#system("$multicom_dir/script/multicom_server_hard_vb.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
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
	#	system("$multicom_dir/script/multicom_server_hard_vb.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
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

