#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using sam and combinations
#Inputs: option file, fasta file, output dir.
#Outputs: sam output file, local alignment file, combined pir msa file,
#         pdb file (if available, and log file
#Author: Jianlin Cheng
#Date: 12/14/2009
##########################################################################

if (@ARGV != 3)
{
	die "need three parameters: option file, sequence file, output dir.\n"; 
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
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

`cp $fasta_file $work_dir 2>/dev/null`; 
`cp $option_file $work_dir 2>/dev/null`; 
chdir $work_dir; 

#take only filename from fasta file
$pos = rindex($fasta_file, "/");
if ($pos >= 0)
{
	$fasta_file = substr($fasta_file, $pos + 1); 
}

#take only filename from fasta file
$pos = rindex($option_file, "/");
if ($pos >= 0)
{
	$option_file = substr($option_file, $pos + 1); 
}

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
$prosys_dir = "";
$blast_dir = "";
$modeller_dir = "";
$pdb_db_dir = "";
$nr_dir = "";
$nr_db = "";
$atom_dir = "";
$sam_dir = "";
$samdb = "";
#initialized with default values
$cm_blast_evalue = 1;
$cm_align_evalue = 1;
$cm_max_gap_size = 20;
$cm_min_cover_size = 20;

$cm_comb_method = "new_comb";
$cm_model_num = 5; 

$cm_max_linker_size=10;
$cm_evalue_comb=0;

$adv_comb_join_max_size = -1; 

#options for sorting local alignments
$sort_blast_align = "no";
$sort_blast_local_ratio = 2;
$sort_blast_local_delta_resolution = 2;
$add_stx_info_rm_identical = "no";
$rm_identical_resolution = 2;

$cm_clean_redundant_align = "no";

$cm_evalue_diff = 1000; 

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^script_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$script_dir = $value; 
	#	print "$script_dir\n";
	}

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
		$script_dir = "$prosys_dir/script";
	#	print "$script_dir\n";
	}

	if ($line =~ /^blast_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$blast_dir = $value; 
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
	if ($line =~ /^nr_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_dir = $value; 
	}
	if ($line =~ /^nr_db/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_db = $value; 
	}
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^sam_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$sam_dir = $value; 
	}

	if ($line =~ /^prc_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prc_dir = $value; 
	}

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^meta_common_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_common_dir = $value; 
	}

	if ($line =~ /^samdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$samdb = $value; 
	}

	if ($line =~ /^prcdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prcdb = $value; 
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

	if ($line =~ /^cm_comb_method/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$cm_comb_method = $value; 
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
	if ($line =~ /^nr_iteration_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_iteration_num = $value; 
	}
	if ($line =~ /^nr_return_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_return_evalue = $value; 
	}
	if ($line =~ /^nr_including_evalue/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$nr_including_evalue = $value; 
	}

}

#check the options
-d $script_dir || die "can't find script dir: $script_dir.\n"; 
-d $blast_dir || die "can't find blast dir.\n";
-d $modeller_dir || die "can't find modeller_dir.\n";
-d $pdb_db_dir || die "can't find pdb database dir.\n";
-d $sam_dir || die "can't find sam dir.\n";
-f $samdb || die "can't find sam database.\n";
-d $prc_dir || die "can't find prc dir.\n";
-f $prcdb || die "can't find prc database.\n";
-d $nr_dir || die "can't find nr dir.\n";
-f "$nr_db.pal" || die "can't find nr database.\n";
-d $atom_dir || die "can't find atom dir.\n";
-d $meta_dir || die "can't find $meta_dir.\n";
-d $meta_common_dir || die "can't find $meta_common_dir.\n";

if ($cm_blast_evalue <= 0 || $cm_blast_evalue > 10 || $cm_align_evalue <= 0 || $cm_align_evalue > 10)
{
	die "blast evalue or align evalue is out of range (0,10).\n"; 
}
#if ($cm_max_gap_size <= 0 || $cm_min_cover_size <= 0)
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
#	die "the evalue threshold for alignment combination must be <= 0.\n";
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

if ($sort_blast_local_ratio <= 1 || $sort_blast_local_delta_resolution <= 0)
{
		warn "sort_blast_local_ratio <= 1 or delta resolution <= 0. Don't sort blast local alignments.\n";
		$sort_blast_align = "no";
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

#check if local alignment file exist. 
if (-f "$fasta_file.local")
{
        print "The local alignment file exists, so directly go to alignment refinement and model generation.\n";
        goto MULTICOM;
}


################################################################
#blast protein and nr(if necessary) to find homology templates.
#assumption: pdb database name is: pdb_cm
#	     nr database name is: nr
#################################################################


#$nr_db = "$nr_dir/nr";
print "blast NR to find homology templates...\n";
(-f "$nr_dir/nr.phr" || -f "$nr_dir/nr.pal") || die "can't find the nr database.\n"; 

#use new version: cm_psiblast_temp_opt.pl with many options to tune
#system("$blast_dir/blastpgp -i $fasta_file -o $fasta_file.blast -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue -d $nr_db"); 

###############################################################################
#iteration is changed to 1 for test use only. 
system("$blast_dir/blastpgp -i $fasta_file -o $fasta_file.blast -j $nr_iteration_num -e $nr_return_evalue -h $nr_including_evalue -d $nr_db"); 
###############################################################################

#get file name prefix
$idx = rindex($fasta_file, ".");
if ($idx > 0)
{
	$filename = substr($fasta_file, 0, $idx);
}
else
{
	$filename = $fasta_file; 
}

#convert blast output to raw alignment
print "convert blast output to alignment...\n"; 
system("$meta_dir/script/process-blast.pl $fasta_file.blast $filename.align $fasta_file");
	

#conver raw alignment to hhm
print "convert alignment to HMM...\n";
system("$prosys_dir/script/msa2gde.pl $fasta_file $filename.align fasta $fasta_file.fas");
system("$sam_dir/bin/w0.5 $fasta_file.fas $name.mod 2>/dev/null"); 

#search prc hmm against the database
print "search PRC HMM against database ...\n";
system("$prc_dir/prc-1.5.6-linux-x86_64 -hits 50 -align prc $name.mod $prcdb $name");
#output file is: name.dist

#####################################################################################
#########################Stop here to work on rank_templates.pl######################
print "generate ranking list...\n";
system("$meta_dir/script/rank_templates.pl $name.scores $work_dir/$name.prank");
#####################################################################################

###############################################################################
#select the templates whose evalue < $cm_blast_evalue (to do....) (an output fasta file)

open(RANK, "$work_dir/$name.prank") || die "can't open the template rank file.\n"; 
@rank = <RANK>;
close RANK; 
shift @rank; 

#return: -1: less, 0: equal, 1: more
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
			return $a <=> $b_prev * (10**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			#return -1; 
			#return $a_prev * (10 ** $a_next) <=> $b; 
			return $a_prev * (10 ** $a_next) <=> $b; 
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

@sel_templates  = (); 
@sel_evalues = (); 

while (@rank)
{
	$line = shift @rank; 
	chomp $line; 
	($index, $template, $evalue) = split(/\s+/, $line); 
	$index = 0; 
	if (&comp_evalue($evalue, $cm_blast_evalue) <= 0)
	{
		push @sel_templates, $template;
		push @sel_evalues, $evalue; 
	}			

	$temp2evalue{$template} = $evalue; 
}

if (@sel_templates <= 0)
{
	die "No templates with evalue than $cm_blast_evalue were found. Stop!\n";
}

print "Selected templates: @sel_templates\n";

open(SAMDB, "$samdb") || die "can't read $samdb.\n";
@allseq = <SAMDB>;
close SAMDB; 
while (@allseq)
{
	$temp_id = shift @allseq;
	chomp $temp_id;
	$temp_id = substr($temp_id, 1); 

	$temp_seq = shift @allseq;
	chomp $temp_seq;
	
	$id2seq{$temp_id} = $temp_seq; 
}

open(SEL, ">$name.psel") || die "can't create $name.psel.\n";

#first sequence is query itself
print SEL ">$name\n$seq\n";

foreach $sel_id (@sel_templates)
{
	if ( exists($id2seq{$sel_id}) )
	{
		$sel_seq = $id2seq{$sel_id}; 
		print SEL ">$sel_id\n$sel_seq\n";	

		push @todo_name, $sel_id;
		push @todo_seq,  $sel_seq; 
	}
	else
	{
		warn "The sequence of $sel_id is not found.\n";
	}
}
close SEL; 


###############################################################################
###############################################################################
#generate alignments between prc model and the selected sequence

$query_seq = $seq;  #store the orginal query protein sequence

`>$name.a2m`; 

#align query sequence against its model
system("$sam_dir/bin/hmmscore ${name}tmp -i $name.mod -db $fasta_file -sw 2 -dpstyle 0 -adpstyle 5 -select_align 8 2>/dev/null"); # a file ${name}tmp.a2m is created

$pos = rindex($prcdb, "/");
$model_dir = substr($prcdb, 0, $pos); 

while (@todo_name)
{
	$tid = shift @todo_name;
	$tseq = shift @todo_seq; 
	open(TMP, ">$tid.tmp.fasta");
	print TMP ">$tid\n$tseq"; 
	close TMP; 
	
	#align template sequence against its model
	system("$sam_dir/bin/hmmscore ${tid}tmp -i $model_dir/$tid.mod -db $tid.tmp.fasta -sw 2 -dpstyle 0 -adpstyle 5 -select_align 8 2>/dev/null");  #a file ${tid}tmp.a2m is created

	#do profile-profile alignment	
	system("$prc_dir/prc-1.5.6-linux-x86_64 -hits 1 -align prc $name.mod $model_dir/$tid.mod > $tid.prc"); 

	#merge alignments 
	system("$prc_dir/merge_aligns.pl $tid.prc ${name}tmp.a2m ${tid}tmp.a2m > $name-$tid"); 

	#convert merge alignments to a true alignment 

	system("$meta_dir/script/gen_prc_alignment.pl $name-$tid $name-$tid.global"); 
	
	`cat $name-$tid.global >> $name.a2m`; 

	`rm ${tid}tmp.a2m $name-$tid.global $tid.tmp.fasta`; 

}

#############################################################################

#generate one pir alignment for each template 
#also generate a local alignment file
open(LOCAL, ">$name.local") || die "can't create $name.local.\n";
print LOCAL $name, " ", length($query_seq), "\n"; 
$qname = $name;

open(ALIGN, "$name.a2m") || die "can't open $name.a2m.\n";;
@align = <ALIGN>;
close ALIGN;
#get the query sequence
while (@align)
{
	$name = shift @align;
	chomp $name;
	if ($name !~ /^>/)
	{
		die "sam alignment error: $name\n";
	}	
	$name = substr($name, 1); 
	
	#get sequence
	$seq = "";
	while (@align)
	{
		$line = shift @align;
		chomp $line;
		$seq .= $line;
		if ($align[0] =~ /^>/)
		{
			last; 
		}	
	}
	#replace . with -
	$seq =~ s/\./-/g; 

	$seq = uc($seq); 

	#check if the first seuqnce is the same as the orignal query sequence
	$new_seq = $seq; 
	$new_seq =~ s/-//g;  
	$query_seq eq $new_seq || die "query sequence $query_seq doesn't match with the sequence $new_seq in the sam alignment.\n";

	$qname eq $name || die "query name doesn't match: $qname != $name\n";
	$qalign = $seq; 


	#get the template name and sequence
	$name = shift @align;
	chomp $name;
	if ($name !~ /^>/)
	{
		die "sam alignment error: $name\n";
	}	
	$name = substr($name, 1); 
	
	#get sequence
	$seq = "";
	while (@align)
	{
		$line = shift @align;
		chomp $line;
		$seq .= $line;
		if (@align == 0)
		{
			last;
		}
		if ($align[0] =~ /^>/)
		{
			last; 
		}	
	}
	$seq = uc($seq); 
	#replace . with -
	$seq =~ s/\./-/g; 

	$raw_seq = $seq;
	$raw_seq =~ s/-//g; 

	length($qalign) == length($seq) || die "alignment length doesn't match.\n";
	$align_len = length($qalign);

	#remove common "-" gaps	
	$qalignment = $talignment = "";
	for ($i = 0; $i < $align_len; $i++)
	{
		if (substr($qalign, $i, 1) ne "-" || substr($seq, $i, 1) ne "-")
		{
			$qalignment .= substr($qalign, $i, 1);
			$talignment .= substr($seq, $i, 1); 
		}	
	}

	open(GLOBAL, ">$name.global") || die "can't create $name.global.\n";
	print GLOBAL "\n\n$qname\n$qalignment\n$name\n$talignment"; 
	close GLOBAL; 
	#convert global aligment into pir format
	system("$meta_dir/script/global2pir.pl $name.global $name.pir"); 

	{
		#need to get the evalue of the template
		$evalue = $temp2evalue{$name}; 
		print LOCAL "\n$name", "\t", length($raw_seq),"\t", 0, "\t", $evalue, "\n";

		$align_len = length($qalignment);
		$qstart = $qend = $tstart = $tend = 0; 
		$astart = $aend = -1; 

		$qa_idx = $ta_idx = 0; #index of amino acids 
		for ($i = 0; $i < $align_len; $i++)
		{
			if (substr($qalignment, $i, 1) ne "-")
			{
				$qa_idx++; 
			}
			if (substr($talignment, $i, 1) ne "-")
			{
				$ta_idx++; 
			}
			
			if (substr($qalignment, $i, 1) ne "-" && substr($talignment, $i, 1) ne "-")
			{
				if ($astart == -1)
				{
					$astart = $i; 
				}
				if ($qstart == 0)
				{
					$qstart = $qa_idx;
					$tstart = $ta_idx; 
				}	
				$aend = $i; 
				$qend = $qa_idx;
				$tend = $ta_idx; 
			}
		}

		#print LOCAL 1, "\t", length($query_seq), "\t", 1, "\t", length($raw_seq), "\n";
		#print LOCAL "$qalignment\n$talignment\n"; 
		print LOCAL $qstart, "\t", $qend, "\t", $tstart, "\t", $tend, "\n";
		print LOCAL substr($qalignment, $astart, $aend-$astart+1), "\n", substr($talignment, $astart, $aend-$astart+1), "\n"; 
	}
}

close LOCAL; 

`cp $qname.local $fasta_file.local`; 

#############################################################################
#############################################################################

print "Generate a model from combined templates...\n";

MULTICOM:

$align_option = "$meta_common_dir/script/align_option";
-f $align_option || die "can't find alignment option file: $align_option.\n";

#preprocess local alignments
system("$meta_common_dir/script/local_global_align.pl $align_option $fasta_file.local $fasta_file $fasta_file");

#generate structure from local alignments
system("$meta_common_dir/script/local2model.pl $option_file $fasta_file $fasta_file .");

print "Comparative modelling for $fasta_file is done.\n";

