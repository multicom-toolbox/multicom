#!/usr/bin/perl -w


### cd /home/casp13/TS_run/valid/T3333/full_length
### perl /home/casp13/TS_run/scripts/domain_identification_from_hhsearch15.pl /home/casp13/TS_run/fasta/T3333.fasta  hhsearch15 
### /home/casp13/TS_run/valid/T3333/full_length/hhsearch15/domain_info_thre40 
### /home/casp13/TS_run/valid/T3333/full_length/hhsearch15/domain_detection.log 
###  /home/casp13/MULTICOM_package/software/disorder_new/

### /home/casp13/MULTICOM_package/software/disorder_new/bin/predict_diso.sh /home/casp13/TS_run/fasta/T3333.fasta /home/casp13/TS_run/valid/T3333/full_length/hhsearch15/T3333.fasta.disorder

##########################################################################
#The main script of template-based modeling using hhsearch and combinations
#Inputs: option file, fasta file, output dir.
#Outputs: hhsearch output file, local alignment file, combined pir msa file,
#         pdb file (if available, and log file
#Author: Jianlin Cheng
#Modifided from cm_main_comb_join.pl
#Date: 10/16/2007
#Date: 04/25/2018
##########################################################################

if (@ARGV != 2)
{
	die "need three parameters: option file, sequence file, output dir.\n";
}

$query_file = shift @ARGV; #/home/jh7x3/test/casp1.fa
$work_dir = shift @ARGV; #


#get query file name
$pos = rindex($query_file, "/");
$query_file_name = $query_file;
if ($pos >= 0)
{
	$query_filename = substr($query_file_name, $pos + 1);
}

#get query name and sequence
open(FASTA, $query_file) || die "can't read fasta file.\n";
$query_name = <FASTA>;
chomp $query_name;
$qseq = <FASTA>;
chomp $qseq;
close FASTA;
$query_length = length($qseq);

$qlen = length($qseq);

if ($query_name =~ /^>/)
{
	$query_name = substr($query_name, 1);
}
else
{
	die "fasta foramt error.\n";
}



open(LOG,">$work_dir/domain_detection.log");
#make sure work dir is a full path (abosulte path)
$cur_dir = `pwd`;
chomp $cur_dir; 
#change dir to work dir
if ($work_dir !~ /^\//)
{
	if ($work_dir =~ /^\.\/(.+)/)
	{
		$work_dir = $cur_dir . "/" . $1;
	}
	else
	{
		$work_dir = $cur_dir . "/" . $work_dir; 
	}
	print LOG "working dir: $work_dir\n";
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

$output_dir = $work_dir;
chdir $work_dir; 


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
#$hmmer_local_alignment = "xxxx";
#$hmmer_local_alignment =  "$output_dir/hmmer/$query_filename.local";
$hhsearch_local_alignment = "$work_dir/$query_filename.local";
#$hhsearch_local_alignment = "$output_dir/hhsearch15/$query_filename.local";

#print "$hmmer_local_alignment\n";

if(!(-f $hhsearch_local_alignment))
{
	print "Warning: failed to find local alignment $hhsearch_local_alignment\n\n";
	print LOG "Warning: failed to find local alignment $hhsearch_local_alignment\n\n";
	goto MODEL_EVA;
}

print LOG "########  start domain detect algorithm\n\n";
print "########  start domain detect algorithm\n\n";

@local = ();
#$domain_split_comb = 0;
if (-f $hhsearch_local_alignment)
{
	print LOG "Read hhsearch local alignment file.\n";
	print "Read hhsearch local alignment file.\n";
	open(LOCAL, $hhsearch_local_alignment) || die "can't read $hhsearch_local_alignment.\n";
	@local = <LOCAL>;
	close LOCAL;

	#check if a significant template was found, if not call hard modeling
	$hhsearch_rank_file = "$work_dir/$query_name.rank";
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
		print LOG "This is hard targets, no need domain identification\n\n";
		print "This is hard targets, no need domain identification\n\n";
		#$full_length_dir_hard = $output_dir . "/full_length_hard";
		#`mkdir $full_length_dir_hard`;
		#system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard");
		#$full_length_dir = $full_length_dir_hard;
		$domain_def = "$output_dir/domain_info_thre$min_domain_length";
		open(DOM_DEF, ">$domain_def");
		print DOM_DEF "domain 0:1-".$qlen." hard\n";
		close DOM_DEF;
		goto MODEL_EVA;

	}
}
else
{
	print LOG "No local alignment file is found in hhsearch15. Re-run with hard domain option and ab initio tools. \n";
	print "No local alignment file is found in hhsearch15. Re-run with hard domain option and ab initio tools. \n";
	print LOG "This is hard targets, no need domain identification\n\n";
	print "This is hard targets, no need domain identification\n\n";
	#here, we may need to check how good the template is (if score < 0.7, the system should be rerun? )
##############################################################################################################

	`rm $query_file.tmp *.tmp 2>/dev/null`;

	goto MODEL_EVA;
}


print LOG "This target is template-based target, start identifying the domains\n\n";
print "This target is template-based target, start identifying the domains\n\n";
#analyze local alignments to get domain information


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
	
	### this is added on 2018/05/02 to avoid low evalue but low coverage
	if(  &comp_evalue($evalue, 1) > 0  || ($tend - $tstart < $hard_length))
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
	if ( ($tend - $tstart >= $hard_length || ($qend - $qstart) / $query_length >= $hard_coverage))
	{
		$bHard = 0;
	}

}
if ($bHard == 1)
{
	print LOG "This is hard targets, no need domain identification\n\n";
	print "This is hard targets, no need domain identification\n\n";
	#$full_length_dir_hard = $output_dir . "/full_length_hard";
	#`mkdir $full_length_dir_hard`;
	#system("$multicom_dir/script/multicom_server_hard_v7.pl $meta_option_hard_domain $query_file $full_length_dir_hard");
	#system("$multicom_dir/script/multicom_server_hard_v8.pl $meta_option_hard_domain $query_file $full_length_dir_hard");
	#system("$multicom_dir/script/multicom_server_hard_v9.pl $meta_option_hard_domain $query_file $full_length_dir_hard");
	#system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard");
	#$full_length_dir = $full_length_dir_hard;

	`rm $query_file.tmp *.tmp 2>/dev/null`;
	$domain_def = "$output_dir/domain_info_thre$min_domain_length";
	open(DOM_DEF, ">$domain_def");
	print DOM_DEF "domain 0:1-".$qlen." hard\n";
	close DOM_DEF;
	goto MODEL_EVA;
}

print LOG "Check if front or end domains are missing...\n";
print "Check if front or end domains are missing...\n";

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
		print $local->{"align_id"}."\nfirst_left_len: $first_left_len\nfirst_right_len: $first_right_len\nevalue: ".$local->{"evalue"}."\n\n";
	}

}

if ($left_domain_missing >= $min_domain_length)
{
		print LOG "The left domain of $left_domain_missing residues is not covered. Suggested left domain size for domain splitting is $first_left_len.\n";
		print "The left domain of $left_domain_missing residues is not covered. Suggested left domain size for domain splitting is $first_left_len.\n"; 
}
else
{
	#recheck  if left is msising based on pir alignment, use evalue 0.1
	#recheck if left of right is missing based on pir alignment
	$hhsearch_pir_file = "$work_dir/ss1.pir";

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

			print LOG "the number of residues missed in the left domain based on the ss1.pir\n\n";
			print "the number of residues missed in the left domain based on the ss1.pir\n\n";
		}
	}
}

if ($right_domain_missing >= $min_domain_length)
{
		print LOG "The right domain of $right_domain_missing residues is not covered. Suggested left domain size for domain splitting is $first_right_len.\n";
		print "The right domain of $right_domain_missing residues is not covered. Suggested left domain size for domain splitting is $first_right_len.\n";
}
else
{
	#recheck if left of right is missing based on pir alignment
	$hhsearch_pir_file = "$work_dir/ss1.pir";

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
			print LOG "the number of residues missed in the right domain: $right_domain_missing\n";
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
		print LOG "Find an inserted domain of $longest_gap_len residues in range ($longest_gap_start, $longest_gap_end).\n";
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
	print LOG "Add left missing domain.\n";
	print "Add left missing domain.\n";
	#@start = (1);
	#@end = ($first_left_len);
	push @domain_start, "1";
	push @domain_end, "$first_left_len";
	push @domain_level, "hard";
	print LOG "domain_start: 1\n";
	print "domain_start: 1\n";
	print LOG "domain_end: $first_left_len\n";
	print "domain_end: $first_left_len\n";
	print LOG "domain_level: hard\n\n";
	print "domain_level: hard\n\n";
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
	print LOG "domain_start: $start\n";
	print "domain_start: $start\n";
	print LOG "domain_end: $end\n";
	print "domain_end: $end\n";
	print LOG "domain_level: hard\n\n";
	print "domain_level: hard\n\n";
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
	print LOG "domain_start: $start\n";
	print "domain_start: $start\n";
	print LOG "domain_end: $end\n";
	print "domain_end: $end\n";

	if ($hard_case == 0)
	{
		push @domain_level, "easy";
		print LOG "domain_level: easy\n\n";
		print "domain_level: easy\n\n";
	}
	else
	{
		push @domain_level, "hard";
		print LOG "domain_level: hard\n\n";
		print "domain_level: hard\n\n";
	}
}

#check the right end
if ( $right_domain_missing >= $min_domain_length )
{
	print LOG "Add right missing domain.\n";
	print "Add right missing domain.\n";
	$value = $qlen - $first_right_len + 1;
	$start = "$value";
	$end = "$qlen";
	push @domain_start, $start;
	push @domain_end, $end;
	push @domain_level, "hard";
	print LOG "domain_start: $start\n";
	print "domain_start: $start\n";
	print LOG "domain_end: $end\n";
	print "domain_end: $end\n";
	print LOG "domain_level: hard\n\n";
	print "domain_level: hard\n\n";
}

#############################################################
#check if domain information is correct
#this is a temporary bug fix to avoid running the program
#on the wrong domain information
# jie found sometimes domain information will like
=pod
domain_start: 1
domain_end: 3
domain_level: hard

domain_start: 4
domain_end: 76
domain_level: easy

Add right missing domain.
domain_start: 77
domain_end: 137
domain_level: hard
=cut
# in this case, need merge short part into second domain
##############################################################

print LOG "\n#check if domain information is correct\n\n";
print "\n#check if domain information is correct\n\n";
$wrong = 0;
for ($i = 0; $i < @domain_start; $i++)
{
	if ($domain_end[$i] - $domain_start[$i] + 1 < $min_domain_length)
	{
		$domain_len = $domain_end[$i] - $domain_start[$i] + 1;
		$wrong = 1;
		print LOG "Too short domain ($domain_len) between ".$domain_start[$i].' and '.$domain_end[$i]."\n";
		print "Too short domain ($domain_len) between ".$domain_start[$i].' and '.$domain_end[$i]."\n";
	}
}
if ($wrong == 1)
{
	##warn "domain information is wrong. skip domain prediction.\n";
	warn "\n\n!!!!!!!!!!! domain information is wrong. need adjust the domain prediction.\n";


	######################################################################################
	$local = $local_list[0];
	if (&comp_evalue($local->{"evalue"}, 1) > 0)
	{
		#hard case, not domain prediction. call hard.
		print LOG "This is hard targets, no need domain identification\n\n";
		print "This is hard targets, no need domain identification\n\n";
		#$full_length_dir_hard = $output_dir . "/full_length_hard";
		#`mkdir $full_length_dir_hard`;
		#system("$multicom_dir/script/multicom_server_hard_vc.pl $meta_option_hard_domain $query_file $full_length_dir_hard");
		#$full_length_dir = $full_length_dir_hard;
		`rm $query_file.tmp *.tmp 2>/dev/null`;
		$domain_def = "$output_dir/domain_info_thre$min_domain_length";
		open(DOM_DEF, ">$domain_def");
		print DOM_DEF "domain 0:1-".$qlen." hard\n";
		close DOM_DEF;
		goto MODEL_EVA;
	}

	$all_fine=1;
	$check_time=0;
	while(1)
	{
		$check_time++;
		for ($i = 0; $i < @domain_start; $i++)
		{
			if ($domain_end[$i] - $domain_start[$i] + 1 < $min_domain_length)
			{
				if($i < @domain_start -1) # if next is available, merge to next
				{
					$domain_start[$i+1] = $domain_start[$i]; #
					shift @domain_start;
					shift @domain_end;
					shift @domain_level;
					last; # recheck
				}else{ # if next is not available, merge to previous
					$domain_end[$i-1] = $domain_end[$i]; #
					pop @domain_start;
					pop @domain_end;
					pop @domain_level;
				}
			}
		}

		print "Adjust step $check_time: \n";
		for ($i = 0; $i < @domain_start; $i++)
		{
			print LOG "\tdomain_start: $domain_start[$i]\n";
			print "\tdomain_start: $domain_start[$i]\n";
			print LOG "\tdomain_end: $domain_end[$i]\n";
			print "\tdomain_end: $domain_end[$i]\n";
			print LOG "\tdomain_level: $domain_level[$i]\n\n";
			print "\tdomain_level: $domain_level[$i]\n\n";
		}

		for ($i = 0; $i < @domain_start; $i++)
		{
			if ($domain_end[$i] - $domain_start[$i] + 1 < $min_domain_length)
			{
				$domain_len = $domain_end[$i] - $domain_start[$i] + 1;
				$all_fine = 0;
				print "Still has too short domain ($domain_len) between ".$domain_start[$i].' and '.$domain_end[$i]."\n";
			}
		}


		if($all_fine == 1)
		{
			print "The domain identification is corrected!\n";
			last;
		}
		if($check_time>10)
		{
			warn "domain information is wrong. skip domain prediction.\n";
			last;
		}
	}
	######################################
}
#####################################################################

#print out domain information
$domain_def = "$output_dir/domain_info_thre$min_domain_length";
open(DOM_DEF, ">$domain_def");
for ($i = 0; $i < @domain_start; $i++)
{
	print LOG "domain ", $i, ":";
	print "domain ", $i, ":";
	print DOM_DEF "domain ", $i, ":";
	$start = $domain_start[$i];
	@astart = split(/:/, $start);
	$end = $domain_end[$i];
	@aend = split(/:/, $end);
	for ($j = 0; $j < @astart; $j++)
	{
		print LOG "$astart[$j]-$aend[$j] ";
		print "$astart[$j]-$aend[$j] ";
		print DOM_DEF "$astart[$j]-$aend[$j] ";
	}
	print $domain_level[$i]."\n";
	print DOM_DEF $domain_level[$i]."\n";
}
close DOM_DEF;
print LOG "Domain identification is done, the domain file is saved in $domain_def\n\n";
print "Domain identification is done, the domain file is saved in $domain_def\n\n";
#################################################################################
MODEL_EVA:
print LOG "Domain identification is done!!!!\n\n";
print "Domain identification is done!!!!\n\n";
