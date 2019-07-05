#!/usr/bin/perl -w
#################################################################################
#
#               MULTICOM Protein Structure Prediction System
#                         Author: Jianlin Cheng,Jie Hou
#                         Start date: 1/13/2010
#                         Current date: 06/01/2019
#
# 	J. Hou, et al. Protein tertiary structure modeling driven by deep learning 
#				and contact distance prediction in CASP13. Proteins.
#
#################################################################################
#                       Overall Strategy
# 1. model generation using diverse techniques
# 2. domain-based model generation
# 3. model evaluation (full length and domain based)
# 4. model combination
#
#################################################################################

$GLOBAL_PATH="/home/jh7x3/multicom_beta1.0/";

$DEBUG = 0; #0: non-debug runtime model; set DEBUG 1 will enter into debug mode and will not generate models 

if (@ARGV != 3)
{
	die "need three parameters: multicom system option file, query file(fasta), output dir\n";
}

######################Process Inputs############################################
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

$tm_score = "$GLOBAL_PATH/tools/tm_score/TMscore_32";

$q_score = "$GLOBAL_PATH/tools/pairwiseQA/q_score";

#$human_qa_program = "/home/casp13/Human_QA_package/HUMAN/run_CASP13_HumanQA.sh";

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

	#if ($line =~ /^human_qa_program/)
	#{
	#	($other, $value) = split(/=/, $line);
	#	$value =~ s/\s//g; 
	#	$human_qa_program = $value; 
	#}

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
#-f $human_qa_program || die "can't find $human_qa_program.\n";

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
####################################End of Process Inputs##############################################
#enter into the output directory
chdir $output_dir; 

#Generate full length model
$full_length_dir = $output_dir . "/full_length";
`mkdir $full_length_dir`; 

print "Step1: generate full length models...\n";


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
	#generate full-length model
	system("$GLOBAL_PATH/src/meta/script/multicom_server_ve.pl $meta_option_full_length $query_file $full_length_dir"); 
}
#########################################################################################################


#########################################################################################################

#get query file name
$pos = rindex($query_file, "/");
$query_file_name = $query_file;
if ($pos >= 0)
{
	$query_filename = substr($query_file_name, $pos + 1); 
}


print "Step 2: identify domains of the protein...\n";

#########################################################################################################
#   A simple domain identification algorithm
#  (1) hit left part, right is a missing domain
#  (2) hit righ part, left is a missing domain
#  (3) hit a little left, missing an insertion, hit right
#  (4) hit left, missing an in sertioin, hit a little right
#  (5) both left and right are missing. if the length of left and right
#########################################################################################################

#disable hmmer file for domain prediction
$hmmer_local_alignment = "xxxx";

#hhsearch15 local alignment is used to identify domains
$hhsearch_local_alignment = "$full_length_dir/hhsearch15/$query_filename.local";

@local = (); 
$domain_split_comb = 0; 
if (-f $hmmer_local_alignment)  #not used anymore
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
		#if not, run the hard prediction program for short targets
		$bHard = 1; 
		$full_length_dir_hard = $output_dir . "/full_length_hard";
		`mkdir $full_length_dir_hard`; 

		if ($DEBUG == 0)
		{
			#system("$multicom_dir/script/multicom_server_hard_ve.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
			system("$GLOBAL_PATH/src/meta/script/multicom_server_hard_ve.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
			# /data/jh7x3/multicom_github/multicom/src/meta/
			# /data/jh7x3/multicom_github/multicom/src/meta/test_system/multicom_option_hard_casp13
		}
		$full_length_dir = $full_length_dir_hard; 
		goto MODEL_EVA; 

	}		

}
else
{
	print "No local alignment file is found in hhsearch15 and hmmer. Re-run with hard domain option and ab initio tools. \n";

	#no significant template is found, run in hard mode
	if ($DEBUG == 0)
	{
		$bHard = 1; 
		$full_length_dir_hard = $output_dir . "/full_length_hard";
		`mkdir $full_length_dir_hard`; 
		system("$multicom_dir/script/multicom_server_hard_ve.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		$full_length_dir = $full_length_dir_hard; 
	}

	`rm $query_file.tmp *.tmp 2>/dev/null`; 

	goto MODEL_EVA; 
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

$min_domain_length = 40; #used to judge if a domain is missing (less than 40 will be refined by Rosetta refinement)
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
	if(  &comp_evalue($evalue, 1) > 0  || $tend - $tstart < $hard_length)
	{
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
				
}

if ($bHard == 1)
{
	print "This is a hard target, recall MULTICOM with hard options on the full target.\n";
	$full_length_dir_hard = $output_dir . "/full_length_hard";
	`mkdir $full_length_dir_hard`; 
	if ($DEBUG == 0)
	{
		system("$multicom_dir/script/multicom_server_hard_ve.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
	}
	$full_length_dir = $full_length_dir_hard;

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
	if ($domain_end[$i] - $domain_start[$i] + 1 < $min_domain_length) 
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
		if ($DEBUG == 0)
		{
			system("$multicom_dir/script/multicom_server_hard_ve.pl $meta_option_hard_domain $query_file $full_length_dir_hard"); 
		}
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



####################  added by jie to use disorder information to correct domain information 2018/04/28 
$sequence = $qseq;
chomp $sequence;

$disorder_seq="";
$disorder_file = "$full_length_dir/hhsearch15/$query_name.fasta.disorder";
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
@domain_start_tmp = ();
@domain_end_tmp = (); 
#print out domain information
$domain_def = "$output_dir/domain_info_withdisorder";
open(DOM_DEF, ">$domain_def");
print "\nCorrected domain regions:\n";
for($i=0;$i<@domain_range_info_corrected;$i++)
{
	print "domain $i:".$domain_range_info_corrected[$i]." ".$domain_disorder_info_corrected[$i]."\n";
	print DOM_DEF "domain $i:".$domain_range_info_corrected[$i]." ".$domain_disorder_info_corrected[$i]."\n";
	
	@tmp = split('-',$domain_range_info_corrected[$i]);
	
	push @domain_start_tmp, $tmp[0] ; 
	push @domain_end_tmp, $tmp[1]; 
}
close DOM_DEF;


if($correct_check ==1 and length($qseq)>500)
{
	`mv $output_dir/domain_info $output_dir/domain_info_original`;
	`cp $output_dir/domain_info_withdisorder $output_dir/domain_info`;
	@domain_start = @domain_start_tmp;
	@domain_end = @domain_end_tmp;
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
		$level = $domain_level[$i]; 
		if ($level eq "easy")
		{

			##############################Temporarily disable model generation#####################
			if ($DEBUG == 0)
			{
				system("$multicom_dir/script/multicom_server_ve.pl $meta_option_easy_domain domain$i.fasta $domain_dir"); 
			}
			#######################################################################################
		}
		else
		{
			##############################Temporarily disable model generation#####################
			if ($DEBUG == 0)
			{
				system("$multicom_dir/script/multicom_server_hard_ve.pl $meta_option_hard_domain domain$i.fasta $domain_dir"); 
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
#
#To do: how to combine an inserted domain with the rest of protein: 2018
#
#######################################################################################


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
system("$multicom_dir/script/analyze_alignments_v3.pl    $full_length_dir/meta/   $full_length_dir/meta/$query_name.align");

#generate dashboard for full length models
#generate a comprehensive view of all the models (full length, or domains)
#information includes: alignment information (method, template, freq, identity, coverage
#evalue of the top template)
#, model evaluator score, average ranks of
#model evaluator and model energy, max, tm, gdt-ts, q-score. Ab intio models
#do not have alignment information

###################################################################################
#this script needs to be updated to remove energy score 
###################################################################################

system("$multicom_dir/script/gen_dashboard_v4.pl $full_length_dir/meta/ $query_name $output_dir/full_length.dash");  

#Generate a template and alignment view for each domain
if ($domain_split_comb == 1)
{
	my $domain_num = @pir_seq; 
	for ($i = 0; $i < $domain_num; $i++)
	{
		$model_dir = "$output_dir/domain$i/meta/";
		
		system("$multicom_dir/script/analyze_alignments_v3.pl    $model_dir   $output_dir/domain$i/meta/domain$i.align");
		system("$multicom_dir/script/gen_dashboard_v4.pl $model_dir domain$i $output_dir/domain$i.dash"); 
	}
}


#############################model combination#########################################
MODEL_COMB:
print "Combine full-length models based on based on pairwise GDT-TS or tm-score...\n";
#system("$multicom_dir/script/combine_models.pl $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");

if ($DEBUG == 0)
{
	system("$multicom_dir/script/combine_models_gdt_tm_v2.pl $multicom_dir  $full_length_dir/meta/ $output_dir/full_length.dash $query_file $output_dir/mcomb/");
}
#check if combined model is very similar to the top ranked model
#If not, it needs to be reverted back to the top ranked model
#This will help avoid big deviation from the top model
system("$multicom_dir/script/top2comb.pl $output_dir/mcomb/ $output_dir/mcomb/consensus.eva 0.88"); 
#######################################################################

####################################Comprehensive Model Quality Assessment############################
MODEL_ASSESSMENT:

#Launch one or multiple proceses to run deep learning program to assess the quality of models in full length and in each domain directory
#The program should be run in parallel to save time
#

=pod
#evaluate the quality of full-length models without contact prediction
print("Using deep QA to assess the models of full-length...\n");

`mkdir $output_dir/qa`; 

$eva_dir = $output_dir . "/qa/full";
`mkdir $eva_dir`; 

if ($DEBUG == 0)
{
	$dncon_check = "$full_length_dir/confold/dncon2/$query_name.dncon2.rr";
	if(-e $query_name) ## added by Jie 2018/04/09
	{
		system("$human_qa_program $query_name $query_file $full_length_dir/meta $eva_dir $dncon_check >$eva_dir/qa.log 2>&1");
	}else{
		system("$human_qa_program $query_name $query_file $full_length_dir/meta $eva_dir >$eva_dir/qa.log 2>&1");
	}
	
}
system("$multicom_dir/script/sort_deep_qa_score.pl $eva_dir/HumanQA_gdt_prediction.txt $output_dir/qa/deep.full"); 

#output scoring file: HumanQA_gdt_prediction.txt in eva_dir

if (@domain_start > 1)
{
	for ($i = 0; $i < @domain_start; $i++)
	{
		$domain_dir = "$output_dir/domain$i";
		$domain_file = "$output_dir/domain$i.fasta";
		$domain_name = "domain$i";
		$eva_dir = $output_dir . "/qa/domain$i";
		`mkdir $eva_dir`; 
		print "Using deep QA to assess the models of domain$i...\n";
		if ($DEBUG == 0)
		{
			$dncon_check = "$domain_dir/confold/dncon2/$query_name.dncon2.rr";
			if(-e $dncon_check) ## added by Jie 2018/04/09
			{
				system("$human_qa_program $domain_name $domain_file $domain_dir/meta $eva_dir $dncon_check >$eva_dir/qa.log 2>&1");
			}else{
				system("$human_qa_program $domain_name $domain_file $domain_dir/meta $eva_dir >$eva_dir/qa.log 2>&1");
			}
		}
		system("$multicom_dir/script/sort_deep_qa_score.pl $eva_dir/HumanQA_gdt_prediction.txt $output_dir/qa/deep.domain$i"); 
	}
}

=cut
####################################################################################################

print "Combined the models of domains if necessary.\n";


###########################################################################################
#do combination
DOMAIN_COMB:

####################################
#Do general domain combination

if ($domain_split_comb == 1)
{
	print "Combine domains into full-length models based on pairwise GDT-TS scores...\n";

	my $domain_num = @pir_seq; 
	my @domain_models = (); 

	#get all the ranked strucural models of each domain
	for ($i = 0; $i < $domain_num; $i++)
	{
		#domain model directory
		$domain_dir = "$output_dir/domain$i/meta/";

		#scoring file of ranking domain models
		$rank_file = $domain_dir . "domain$i.gdt";

		open(RANK, $rank_file) || die "can't open $rank_file.\n";
		@rank = <RANK>;
		close RANK; 		

		$model = ""; 
		shift @rank; 
		shift @rank; 
		shift @rank; 
		shift @rank; 

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
			system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $comb_dir $pir_file $cm_model_num");  	
		}

		if ( -f "$comb_dir/comb$idx.pdb")
		{
			print "A combined model $comb_dir/comb$idx.pdb is generated.\n";
		}
		
	}

}###################################

#do domain combination based on deep-learning based model ranking
#if ($domain_split_comb == 1)
#{
#	my $domain_num = @pir_seq; 
#
#	system("$multicom_dir/script/combine_domains_v6.pl $prosys_dir $modeller_dir $query_file $output_dir $domain_num"); 	
#}

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
#Convert deep learning models in qa directory into CASP format

if ($full_length_dir =~ /hard/)
{
	system("$multicom_dir/script/convert2casp_v6_simple.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file $full_length_dir"); 

}
else
{
	system("$multicom_dir/script/convert2casp_v5_simple.pl $prosys_dir $multicom_dir $output_dir $query_name $query_file"); 
}
###########################################################################################




print "MULTICOM prediction for $query_name is done.\n";
