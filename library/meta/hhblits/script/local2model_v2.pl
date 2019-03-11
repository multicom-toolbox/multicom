#!/usr/bin/perl -w

##############################################################################
#This script is used to combine local alignments and generate structure models
#Modified from main_hhsearch_easy.pl 
#Inputs: option file, fasta file, local prefix name, work dir.
#Outputs: pdb models, pir files, model refinement information 
#including loops, tails, small ab initio domains for refinement
#Author: Jianlin Cheng
#Start Date: 1/7/2009
##############################################################################
#Format of Option file:
#script_dir = value
#modeller_dir = value
#pdb_db_dir = value
#atom_dir = value
#cm_blast_evalue = ####  (evalue threshold used by psi-blast to choose templates)
#cm_align_evalue = #### (not used any more)
#cm_max_gap_size = #### (max gap size is allowed before stop adding more templates)
#cm_min_cover_size = #### (min gap cover size for template to be chosen)
#cm_model_num = ####  (number of model to be simulated: The model with lowest energy will be chosen)
#cm_max_linker_size=###(<0: simple combination; >=0: advanced combination, value is the max linker size at ends)
#cm_evalue_comb=####(threshold to include significant matched templates. templates with evalue lower than
#e^value will always be included no matter how many gaps are filled by the template).
#
#all kinds of comments starting with "#" are allowed. 
#################################################################

if (@ARGV != 4)
{
	die "need four parameters: option file, query fasta file, prefix name of local alignment files (.local.ext, .sim, .ext files), work dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$local_name = shift @ARGV; 
$work_dir = shift @ARGV;

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
	print "working dir: $work_dir\n";
}
-d $work_dir || die "working dir doesn't exist.\n";

#check if local alignment related files exist
-f "$work_dir/$local_name.ext" || die "can't find the extension file of local alignments.\n";
-f "$work_dir/$local_name.local.ext" || die "can't find extened local alignment file.\n";
-f "$work_dir/$local_name.sim" || die "can't find the structure similarity file of local alignments.\n";

`cp $fasta_file $work_dir 2>/dev/null`; 
`cp $option_file $work_dir 2>/dev/null`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
$modeller_dir = "";
$pdb_db_dir = "";
$atom_dir = "";
#initialized with default values
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 15;
$cm_min_cover_size = 15;
#number of models to simulate using Modeller (the model with mininum energy will be chosen)
$cm_model_num = 5; 

############################################################################################
#max linker can be long because now we only combine structurally consistent local alignments
$cm_max_linker_size=10;
############################################################################################

$cm_evalue_comb=0;
$adv_comb_join_max_size = -1; 
$sort_blast_align = "no";
$sort_blast_local_ratio = 2;
$sort_blast_local_delta_resolution = 2;
$add_stx_info_rm_identical = "yes";
$rm_identical_resolution = 2;
$cm_clean_redundant_align = "no";
$cm_evalue_diff = 1000; 
#the maximum number of easy models to generate
$easy_model_num = 5;

$output_prefix_name = "mu"; #stands for MULTICOM 

$meta_dir = "";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	#	print "$script_dir\n";
	}
	if ($line =~ /^modeller_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$modeller_dir = $value; 
	}
	if ($line =~ /^pdb_db_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pdb_db_dir = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}
	if ($line =~ /^cm_blast_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_blast_evalue = $value; 
	}
	if ($line =~ /^cm_align_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_align_evalue = $value; 
	}
	if ($line =~ /^cm_max_gap_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_gap_size = $value; 
	}
	if ($line =~ /^cm_min_cover_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_min_cover_size = $value; 
	}

	if ($line =~ /^cm_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_model_num = $value; 
	}

	if ($line =~ /^easy_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$easy_model_num = $value; 
	}

	if ($line =~ /^cm_max_linker_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_max_linker_size = $value; 
	}

	if ($line =~ /^cm_evalue_comb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_comb = $value; 
	}

	if ($line =~ /^adv_comb_join_max_size/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$adv_comb_join_max_size = $value; 
	}

	if ($line =~ /^chain_stx_info/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$chain_stx_info = $value; 
	}

	if ($line =~ /^sort_blast_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_align = $value; 
	}

	if ($line =~ /^sort_blast_local_ratio/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_ratio = $value; 
	}

	if ($line =~ /^sort_blast_local_delta_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sort_blast_local_delta_resolution = $value; 
	}

	if ($line =~ /^add_stx_info_rm_identical/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$add_stx_info_rm_identical = $value; 
	}

	if ($line =~ /^rm_identical_resolution/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rm_identical_resolution = $value; 
	}

	if ($line =~ /^cm_clean_redundant_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_clean_redundant_align = $value; 
	}

	if ($line =~ /^cm_evalue_diff/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_evalue_diff = $value; 
	}

	if ($line =~ /^output_prefix_name/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$output_prefix_name = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

}

#check the options
$script_dir = "$prosys_dir/script";
-d $prosys_dir || die "can't find prosys dir: $prosys_dir.\n";
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
#-d $meta_dir || die "can't find meta dir.\n";
-d $atom_dir || die "can't find atom dir.\n";

if ($cm_blast_evalue <= 0 || $cm_blast_evalue > 10 || $cm_align_evalue <= 0 || $cm_align_evalue > 10)
{
	die "blast evalue or align evalue is out of range (0,10).\n"; 
}

if ($cm_min_cover_size <= 0)
{
	die "max gap size or min cover size is non-positive. stop.\n"; 
}

if ($cm_model_num < 1)
{
	die "model number should be bigger than 0.\n"; 
}

if ($cm_evalue_comb > 0)
{
	die "the evalue threshold for alignment combination must be <= 0.\n";
}

if ($sort_blast_align eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
	}
}

if ($add_stx_info_rm_identical eq "yes")
{
	if (!-f $chain_stx_info)
	{
		warn "chain structural information file doesn't exist. Don't add structural information to alignments.\n";
		$add_stx_info_rm_identical = "no";
	}
}
if ($rm_identical_resolution <= 0)
{
	warn "rm_identical_resolution <= 0. Don't add structure information and remove identical alignments.\n";
	$add_stx_info_rm_identical = "no";
}

#check fast file format
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$name = <FASTA>;
chomp $name; 
$seq = <FASTA>;
chomp $seq;
close FASTA;
if ($name =~ /^>/)
{
	$name = substr($name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}

###################################################################################################
###################################################################################################
##################################Local Alignment Combination Algorithm############################
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
			return $a <=> $b_prev * (2.72**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
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

###########################################################################
#get the exponent of evalue
#if evalue is 0, the exponent is set to -1000
#if no exponent exists, the exponent is set to 0.
sub get_exponent 
{
	my $a = $_[0];
	$exponent = 0;

	#get the format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		if ($a <= 0) #evalue is 0
		{
			$exponent = -1000; 
		}
		else
		{
			$exponent = 0; 
		}
	}
	elsif ($a =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
		$exponent = $a_next; 
	}
	else
	{
		die "evalue format error: $a";	
	}
	return $exponent; 
}
########################End of compare evalue################################
sub combine_local
{
#Input parameters: script dir, query file(fasta), local alignment file(blast format), local alignment similarity file, min cover size(20), stop gap size(20), max_linker_size(>=0: use advanced combination, <0: use simple combination), evalue_threshold(0:0, -1:e-1, -2:e-2,...), join max size(for advance comb only,e.g. 5), cm_evalue_diff (10), and output file.\n";

#we need to consider domain combinations --- if a template can cover an entire domain, we should
#let it do a simple combination with previous templates.  

	my $script_dir = shift @_;
	-d $script_dir || die "can't find script dir.\n";
	my $query_file = shift @_;
	my $local_align_file = shift @_;
	-f $local_align_file || die "can't find file $local_align_file.\n";
	my $local_sim_file = shift @_; 
	-f $local_sim_file || die "can't find file $local_sim_file.\n";
	my $min_cover_size = shift @_;
	$min_cover_size > 0 || die "parameter min_cover_size must be bigger than 0.\n";
	my $stop_gap_size = shift @_;
	my $max_linker_size = shift @_;
	my $align_comb_method = "advanced";
	if ($max_linker_size < 0)
	{
		$align_comb_method = "simple";	
	}
	my $evalue_th = shift @_;

	#convert evalue
	if ($evalue_th !~ /^([-\d]+)$/)
	{
		die "evalue threshold must be a number.\n";
	}
	elsif ($evalue_th < 0)
	{
		$evalue_th = "1e$evalue_th";
	}
	elsif ($evalue_th > 0)
	{
		$evalue_th = "${evalue_th}e-0";
	}

	my $join_max_size = shift @_;

	#no join in advanced combination, why?????
#	$join_max_size = -1; 

	my $cm_evalue_diff = shift @_;
	my $output_file = shift @_;

	#the structural similarity threshold to combine local alignments
	my $sim_threshold = 0.75; 

	if (@_ > 0)
	{
		$sim_threshold = shift @_; 
	}


	#a constant to determine if a template can cover a missing domain
	my $domain_cover_size = 40;   
	my $left_missing_size = 1000000;
	my $right_missing_size = 1000000; 
	my $min_domain_size = 30; #decide if a local alignment is considered a domain

	#read query file.
	open(QUERY, $query_file) || die "can't read query file: $query_file.\n";
	my $qname = <QUERY>;
	chomp $qname;
	if ($qname =~ /^>(.+)$/)
	{
		$qname = $1; 
	}
	else
	{
		die "query file is not in fasta format.\n";
	}
	my $qseq = <QUERY>;
	chomp $qseq;
	close QUERY;

	my $query_length = length($qseq); 

	#read structure similarity
	open(SIM, $local_sim_file) || die "can't read $local_sim_file.\n";
	my @sim = <SIM>;
	close SIM;
	my $id2sim = (); 
	while (@sim)
	{
		my $line = shift @sim;  		
		chomp $line; 
		my @fields = split(/\s+/, $line);
		if ($fields[0] =~ /(\d+)-.+-(\d+)-/)
		{
			$pair_id = "$1-$2";
			$id2sim{$pair_id} = $fields[1];  
		}	
		else
		{
			die "format error in the local alignment similarity file.\n";
		}
	}
	
	#read local alignment file
	open(LOCAL, $local_align_file) || die "can't read local alignment file.\n";
	my @local = <LOCAL>;
	close LOCAL;

	my $title = shift @local;
	my @fields = split(/\s+/, $title);
	#check if query name matches.
	$fields[0] eq $qname || die "query name doesn't match with local alignment file.\n";
	$fields[1] == length($qseq) || die "query length doesn't match with local alignment file.\n";

	#combine alignment file according to evalue and gaps
	my $first = 0; 
	my @temps = ();

	my $min_exponent = 10000; 

	my @combine_ids = (); 

	while (@local > 4)
	{
		shift @local;
		my $info = shift @local;
		my $range = shift @local;
		my $qseg = shift @local;
		my $tseg = shift @local;

		my @fields = split(/\s+/, $info);
		my $tname = $fields[0];
		my $evalue = $fields[3]; 

		my $local_id = $fields[$#fields]; 		

		#check if it is necessary to add index to name to make it uniq. 
		#check if there is same name
		my $times = 0;
		my $i = 0; 
		for($i = 0; $i < @temps; $i++)
		{
			if ($tname eq $temps[$i])
			{
				$times++;
			}
		}
		push @temps, $tname;

		if ($times > 0)
		{
			$tname .= $times;
		}

		#check the consistency with the query.
		my @pos = split(/\s+/, $range);
		my $qstart = $pos[0];
		my $qend = $pos[1];
		my $qtest = $qseg;
		chomp $qtest;
		$qtest =~ s/-//g;
		$qtest eq substr($qseq, $qstart - 1, $qend-$qstart+1) || die "local alignment sub string is not found in the query.\n";

		open(TMP, ">$output_file.local") || die "can't create temporay file.\n"; 
		#The format is consistent with palign format.
		print TMP "$title$info$range$qname\n$qseg$tname\n$tseg";
		close TMP;

		#set stop gap size to 0, and min cover size to 0, so that it always to convert.
		system("$script_dir/local2pir_hp.pl $query_file $output_file.local 0 0 $output_file.pir");
		`rm $output_file.local`; 

		#change, fix a bug of e-value difference, 11/05/2006
		my $align_exp = &get_exponent($evalue);

		#do combination
		if ($first == 0)
		{
			#print "first one: make a copy\n";
			`cp $output_file.pir $output_file`; 
			`rm $output_file.pir`; 
			$first = 1;
			if ($align_exp < $min_exponent)
			{
				$min_exponent = $align_exp;
			}

			#record the id of the local alignments
			push @combine_ids, $local_id; 

			if ($qstart - 1 < $left_missing_size)
			{
				$left_missing_size = $qstart - 1; 
			}
			$query_length >= $qend || die "query length is less than alignment end.\n";
			if ($query_length - $qend < $right_missing_size)
			{
				$right_missing_size = $query_length - $qend; 
			}

			next; 
		}

		#check if the struture of the local alignment are consisent with previous ones
		$i = 0; 
		my $consistent = 1; 
		for ($i = 0; $i < @combine_ids; $i++)
		{
			my $prev_id = $combine_ids[$i]; 		
			$local_id > $prev_id || die "local alignment id ($local_id, $prev_id) is wrong.\n";
			my $pair_id = "$prev_id-$local_id";
			if ( exists $id2sim{$pair_id} )
			{
				my $my_score = $id2sim{$pair_id}; 
		
				#comments: if score < 0, the two regions have at most 15 common residues
				#so they can be of big conflict and can potentially be combined. 
				if ($my_score < $sim_threshold && $my_score >= 0)
				{
					print "local alignment $local_id is not similar (score=$my_score) to local alignment $prev_id.\n";	
					$consistent = 0; 
					last;
				}
				
			}
			else
			{
				die "can't find similarity between two local alignments: $prev_id - $local_id.\n";
			}
		}

	#Here we allow inconsisent template to do advanced combination only
	#	if ($consistent == 0)
	#	{
	#		next; 
	#	}

		#check if a template can cover an entire missing domain
		$cover_a_domain = 0; 
		if ( $left_missing_size >= $domain_cover_size && ($qstart - 1) / $left_missing_size < 0.5 && ($qend - $qstart + 1) >= $min_domain_size )
		{
			#this local alignment can cover more than 50% of a missing domain	
			print "this local alignment ($local_id) can cover a missing left domain.\n";
			$cover_a_domain = 1; 	
		}
		if ($right_missing_size >= $domain_cover_size && ($query_length - $qend) / $right_missing_size < 0.5 && ($qend - $qstart + 1) >= $min_domain_size )
		{
			print "this local alignment ($local_id) can cover a missing right domain.\n";
			$cover_a_domain = 1; 

		}


		if ( &comp_evalue($evalue, $evalue_th) <= 0 && ($align_exp <= $min_exponent || $align_exp - $min_exponent < $cm_evalue_diff) && $consistent == 1 )
		{
			#for very significant match, take it, do a simple combination by settting 
			#minimum cover size to 0. 
			system("$script_dir/simple_gap_comb.pl $script_dir $output_file $output_file.pir 0 $output_file >/dev/null");
			push @combine_ids, $local_id;
		}
		elsif ($align_comb_method eq "simple" && $consistent == 1)
		{
			system("$script_dir/simple_gap_comb.pl $script_dir $output_file $output_file.pir $min_cover_size $output_file >/dev/null");
			push @combine_ids, $local_id;
		}
		elsif ($cover_a_domain == 1 && $consistent == 1) #the template can at 50% of an entire domain, so use the entire template
		{
			system("$script_dir/simple_gap_comb.pl $script_dir $output_file $output_file.pir 0 $output_file >/dev/null");
			push @combine_ids, $local_id;
		}
		else 
		{
	#		print("$script_dir/combine_pir_align_adv_join.pl $script_dir $output_file $output_file.pir $min_cover_size $max_linker_size $join_max_size $output_file");
			$comb_state = `$script_dir/combine_pir_align_adv_join_v2.pl $script_dir $output_file $output_file.pir $min_cover_size $max_linker_size $join_max_size $output_file`;
				
			if ($comb_state =~ /used in advanced combination/)
			{
				push @combine_ids, $local_id;
			}
		}
		`rm $output_file.pir`;

		#set the minimum exponent
		if ($align_exp < $min_exponent)
		{
			$min_exponent = $align_exp;
		}


		if ($qstart - 1 < $left_missing_size)
		{
			$left_missing_size = $qstart - 1; 
		}
		if ($query_length - $qend < $right_missing_size)
		{
			$right_missing_size = $query_length - $qend; 
		}

		#check if it needs to stop
		system("$script_dir/analyze_pir_align.pl $output_file > $output_file.ana");
		open(ANA, "$output_file.ana") || die "can't read analysis file of pir alignment.\n";
		<ANA>;
		my $len_size = <ANA>;
		close ANA;
		`rm $output_file.ana`; 
		if ($len_size =~ /length=(\d+)\s+covered=(\d+)/)
		{
			my $len = $1;
			my $cov = $2;
			my $gap = $len - $cov;
			if ($gap <= $stop_gap_size)
			{
				print "stop: $stop_gap_size\n";	
				last;
			}
		}
		else
		{
			die "error in analyzing the combined pir alignment.\n";
		}
	}

}#end of combine_local

#################################End of Local Alignment Combination Algorithm######################
###################################################################################################
###################################################################################################

print "Check if the local alignment file exists in the work dir.\n"; 
open(LOCAL, "$local_name.local.ext") || die "can't find the blast local alignment file. Stop.\n"; 
@local = <LOCAL>;
close LOCAL;
if (@local <= 2)
{
	die "no significant templates are found. stop.\n";
}

#TAKE TOP RANKED TEMPLATES AND ALIGNMENTS TO GENERATE MODELS ONE BY ONE
open(LOCAL, "$local_name.local.ext") || die "can't read local alignment file\n";
@easy_cm = <LOCAL>;
$title = shift @easy_cm;
close LOCAL;

$model_idx = 1;

while ($model_idx <= $easy_model_num && @easy_cm >= 5)
{
	print "generate PIR alignments for easy template $model_idx...\n";

	#create a local file
	open(EASY, ">$fasta_file.easy") || die "can't create an easy local file.\n";
	print EASY $title;
	print EASY join("",@easy_cm);
	close EASY;
	
	#print $script_dir, $fasta_file, "$fasta_file.easy", "$local_name.sim", $cm_min_cover_size, $cm_max_gap_size, $cm_max_linker_size, $cm_evalue_comb, $adv_comb_join_max_size, $cm_evalue_diff, "$output_prefix_name$model_idx.pir", "\n";  
	$stx_similarity_threshold = 0.75;
	&combine_local($script_dir, $fasta_file, "$fasta_file.easy", "$local_name.sim", $cm_min_cover_size, $cm_max_gap_size, $cm_max_linker_size, $cm_evalue_comb, $adv_comb_join_max_size, $cm_evalue_diff, "$output_prefix_name$model_idx.pir", $stx_similarity_threshold);  

	open(PIR, "$output_prefix_name$model_idx.pir") || die "can't generate pir file from local alignments.\n";
	@pir = <PIR>;
	close PIR; 
	if (@pir <= 4)
	{
		die "no pir alignments are generated from target: $name\n"; 
	}

	#	print "Add structural information to blast pir alignments.\n";
	#	system("$script_dir/pir_proc_resolution.pl $output_prefix_name$model_idx.pir $chain_stx_info $rm_identical_resolution $fasta_file.pir.stx");
	#	`mv $fasta_file.pir.stx $output_prefix_name$model_idx.pir`; 



	print "Use Modeller to generate tertiary structures...\n"; 

	$temp_dir = "$work_dir/pdb";
	`mkdir $temp_dir`; 

        #adjust pir files by pdb file
        system("$meta_dir/script/adjust_pir_by_pdb.pl $atom_dir $output_prefix_name$model_idx.pir $output_prefix_name$model_idx.pir.adj");
        `mv $output_prefix_name$model_idx.pir $output_prefix_name$model_idx.pir.ini`;
        `mv $output_prefix_name$model_idx.pir.adj $output_prefix_name$model_idx.pir`;


	#filter pir and pdb file to remove residues without coordinates
	system("$meta_dir/script/verify_pir_pdb_v2.pl $atom_dir $output_prefix_name$model_idx.pir $output_prefix_name$model_idx.pir.fil $temp_dir");
	`mv $output_prefix_name$model_idx.pir $output_prefix_name$model_idx.pir.org`;
	`mv $output_prefix_name$model_idx.pir.fil $output_prefix_name$model_idx.pir`;

	#system("$script_dir/pir2ts_energy_pdb.pl $modeller_dir $atom_dir $work_dir $output_prefix_name$model_idx.pir $cm_model_num");
	system("$script_dir/pir2ts_energy_pdb.pl $modeller_dir $temp_dir $work_dir $output_prefix_name$model_idx.pir $cm_model_num");
	`rm model.log`; 


	if ( -f "$name.pdb")
	{
		`mv $name.pdb $output_prefix_name$model_idx.pdb`;

		print "Comparative modelling for $name is done.\n"; 

	}
	else
	{
		print "Fail to generate a easy model $model_idx\n";
	}

	$model_idx++;
	if (@easy_cm >= 5)
	{
		shift @easy_cm;
		shift @easy_cm;
		shift @easy_cm;
		shift @easy_cm;
		shift @easy_cm;
	}
}
