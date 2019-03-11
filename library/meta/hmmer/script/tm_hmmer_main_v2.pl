#!/usr/bin/perl -w

##########################################################################
#The main script of template-based modeling using hmmer and combinations
#Inputs: option file, fasta file, output dir.
#Outputs: hmmer output file, local alignment file, combined pir msa file,
#         pdb file (if available, and log file
#Author: Jianlin Cheng
#Date: 12/28/2009
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
$atom_dir = "";
$hmmer_dir = "";
$hmmerdb = "";
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
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
	}

	if ($line =~ /^hmmer_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmer_dir = $value; 
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

	if ($line =~ /^hmmerdb/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$hmmerdb = $value; 
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
-d $hmmer_dir || die "can't find hmmer dir.\n";
-f $hmmerdb || die "can't find hmmer database.\n";
-d $nr_dir || die "can't find nr dir.\n";
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


$nr_db = "$nr_dir/nr";
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
#covert fas alignment file into stockholm format
system("$meta_dir/script/fasta_2_stock.pl $fasta_file.fas $fasta_file.sto 100"); 
system("$hmmer_dir/hmmbuild $name.hmmer $fasta_file.sto"); 

#search hmmer hhm against the database
print "search HMMER hmm against database ...\n";
system("$hmmer_dir/hmmsearch $name.hmmer $hmmerdb > $name.score");

#####################################################################################
#########################Stop here to work on rank_templates.pl######################
print "generate ranking list...\n";
system("$meta_dir/script/rank_templates.pl $name.score $work_dir/$name.rank");
#####################################################################################


###############################################################################
#select the templates whose evalue < $cm_blast_evalue (to do....) (an output fasta file)

open(RANK, "$work_dir/$name.rank") || die "can't open the template rank file.\n"; 
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

open(HMMERDB, "$hmmerdb") || die "can't read $hmmerdb.\n";
@allseq = <HMMERDB>;
close HMMERDB; 
while (@allseq)
{
	$temp_id = shift @allseq;
	chomp $temp_id;
	$temp_id = substr($temp_id, 1); 

	$temp_seq = shift @allseq;
	chomp $temp_seq;
	
	$id2seq{$temp_id} = $temp_seq; 
}

open(SEL, ">$name.sel") || die "can't create $name.sel.\n";

#first sequence is query itself
print SEL ">$name\n$seq\n";

foreach $sel_id (@sel_templates)
{
	if ( exists($id2seq{$sel_id}) )
	{
		$sel_seq = $id2seq{$sel_id}; 
		print SEL ">$sel_id\n$sel_seq\n";	
	}
	else
	{
		warn "The sequence of $sel_id is not found.\n";
	}
}
close SEL; 
###############################################################################
###############################################################################
#generate alignments between sam model and the selected sequence
#the alignment file is $name.a2m, which is a global alignment file
system("$hmmer_dir/hmmalign $name.hmmer $name.sel > $name.halign");
#############################################################################

#convert alignment from stockhom format to fasta format
system("$meta_dir/script/stock_2_fasta.pl $name.halign $name.a2m 50");
#convert sam global alignments to pir format
open(ALIGN, "$name.a2m") || die "can't read $name.a2m\n";
@align = <ALIGN>;
close ALIGN; 

$query_seq = $seq;  #store the orginal query protein sequence



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
	last; 
}

$seq = uc($seq); 

#check if the first seuqnce is the same as the orignal query sequence
$new_seq = $seq; 
$new_seq =~ s/-//g;  
$query_seq eq $new_seq || die "query sequence $query_seq doesn't match with the sequence $new_seq in the sam alignment.\n";

$qname = $name;
$qalign = $seq; 

#generate one pir alignment for each template 
#also generate a local alignment file
open(LOCAL, ">$name.local") || die "can't create $name.local.\n";
print LOCAL $qname, " ", length($query_seq), "\n"; 

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
#		print LOCAL "\n$name", "\t", length($query_seq),"\t", 0, "\t", $evalue, "\n";
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
		
################################################################################################################
#fix a common problem of hmmer alignment
#1DCZA   150     0       3.6e-05
#1       131     5       57
#MKIPKIYVEGELNDGDRVAIEKDGNAIIFLEKDEEYSGNGKLLYQVIYDDLAKYMSLDTLKKDVLIQYPDKHTLTYLKAGTKLISVPAEGYKVYPIMDFGFRVLKGYRLATLESKKGDLRYVNSPVSGTVI
#K-----------------------------------------------------------------------------AGEGEIPAPLAGTVSKILVKEGDTVKAGQTVLVLEAMKME-TEINAPTDGKVE
###############################################################################################################
		#check if the template alignment falls into this pattern
		$qalign_temp = substr($qalignment, $astart, $aend-$astart+1);
		$talign_temp = substr($talignment, $astart, $aend-$astart+1);
		if ($talign_temp =~ /^\w-{20,}\w+/)
		{
			warn "local alignment with $name is in strange shape, try to correct it.\n";
			#get the position of first and last continuous -		
			my $aa = substr($talign_temp, 1, 1);
			$aa eq "-" || die "inconsistent local alignment $name : $aa.\n";
			my $first_gap = 1; 
			my $last_gap = 0; 	
			my $k = 0; 	
			for ($k = 1; $k < length($talign_temp); $k++)
			{
				if (substr($talign_temp, $k, 1) ne "-")
				{
					$last_gap = $k - 1; 
					last;
				}	
			} 
			$last_gap - $first_gap + 1 >= 20 || die "inconsistent local alignment $name - $last_gap.\n";

			#make adjustment
			$talign_temp = substr($talign_temp, 0, 1) . substr($talign_temp, $last_gap+1); 
			$qalign_temp = substr($qalign_temp, $last_gap);   
			$qstart = $qstart + $last_gap; 
			
		}


		##########################################################################
		##########################################################################
		#process weird alignment
		if ($talign_temp =~ /^(\w{1,2})(-{20,})(\w+.*)/)
		{
			print "Remove weird leading long gaps in local alignments with $name.\n";
			$talign_temp = $1 . $3; 	
			$org_qalign = $qalign_temp;
			$qalign_temp = substr($qalign_temp, length($2)); 

			$count = length($2);
			#$query_rm = substr($qalign_temp, 0, length($2)); 
			$query_rm = substr($org_qalign, 0, length($2)); 
			for ($j = 0; $j < length($query_rm); $j++)
			{
				if (substr($query_rm, $j, 1) eq "-")
				{
					$count--; 
				}
			}
			#$qstart = $qstart + length($2); 		
			$qstart = $qstart + $count; 		
		}
		if ($talign_temp =~ /(.*\w+)(-{20,})(\w{1,2})$/)
		{
			print "Remove weird trailing long gaps in local alignments with $name.\n";
			$talign_temp = $1 . $3;  
			#$qalign_temp = substr($qalign_temp, 0, length($qalign_temp) - length($2));
			#$qend = $qend - length($2); 	
			$org_len = length($qalign_temp);
			$org_qalign = $qalign_temp;
			$qalign_temp = substr($qalign_temp, 0, $org_len - length($2));

			$query_rm = substr($org_qalign, $org_len - length($2)); 
			$count = 0;
			for ($j = 0; $j < length($query_rm); $j++)
			{
				if (substr($query_rm, $j, 1) ne "-")
				{
					$count++; 
				}
			}

			$qend = $qend - $count; 	


		}
		##########################################################################
		##########################################################################	



		print LOCAL $qstart, "\t", $qend, "\t", $tstart, "\t", $tend, "\n";
		print LOCAL $qalign_temp, "\n", $talign_temp, "\n"; 
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


