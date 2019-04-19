#!/usr/bin/perl -w
######################################################################################
#Generate all features for a pair of query and target
#Depending on the following scripts:
#	1. feature_pair_seq.pl   (pairing sequence information)
#	2. feature_pair_fam.pl	(pairing sequence family info)
#	3. feature_align_seq.pl (sequence alignment info using palign/clustalw)
#	4. feature_align_prof_clustalw.pl
#	5. feature_align_prof_palign.pl
#	6. feature_align_prof_psiblast.pl
#	7. feature_align_prof_tcoffee.pl
#	8. hmmer_pfam.pl
#	9. hmmer_search.pl
#	10. impala.pl
#	11. rps_blast.pl
#	12. feature_ssa_global.pl
#	13. feature_cm_global.pl
#	14. feature_bcm_global.pl
#	15. feature_pair_ssa.pl
#Inputs: query_file(fasta), target file(fasta), option file, output file
#all other files are identified by id in query or target file
#all options and other information are included in option file. 
#in output file: first line (name of features), second line: values
#
#Author: Jianlin Cheng
#Date started: 5/11/05
#Date Ended: 5/16/05 
######################################################################################

if (@ARGV != 4)
{
	die "Generate pairwise features for query and template proteins.\nneed four parameters: query_file(fasta), target file(fasta), option file, output file.\n"; 
}

$query_file = shift @ARGV;
$target_file = shift @ARGV;
$option_file = shift @ARGV;
$out_file = shift @ARGV; 

#read query file
open(QUERY, $query_file) || die "can't read query file.\n";
$qname = <QUERY>;
if ($qname =~ /^>(\S+)/)
{
	$qname = $1; 
}
else
{
	die "query file is not in fasta format.\n"; 
}
$qseq = ""; 
$qseq = <QUERY>;
close QUERY; 

#read target file
open(TARGET, $target_file) || die "can't read query file.\n";
$tname = <TARGET>;
if ($tname =~ /^>(\S+)/)
{
	$tname = $1; 
}
else
{
	die "target file is not in fasta format.\n"; 
}
$tseq = ""; 
$tseq = <TARGET>;
close TARGET; 

#read options
$blast_dir = "";
$clustalw_dir = ""; 
$palign_dir = "";
$tcoffee_dir = "";
$hmmer_dir = "";
$prosys_dir = "";
$template_dir = "";
$query_dir = "";
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	if ($_ =~ /^blast_dir\s*=\s*(\S+)/)
	{
		$blast_dir = $1; 
	}
	if ($_ =~ /^clustalw_dir\s*=\s*(\S+)/)
	{
		$clustalw_dir = $1; 
	}
	if ($_ =~ /^palign_dir\s*=\s*(\S+)/)
	{
		$palign_dir = $1; 
	}
	if ($_ =~ /^tcoffee_dir\s*=\s*(\S+)/)
	{
		$tcoffee_dir = $1; 
	}
	if ($_ =~ /^hmmer_dir\s*=\s*(\S+)/)
	{
		$hmmer_dir = $1; 
	}
	if ($_ =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($_ =~ /^template_dir\s*=\s*(\S+)/)
	{
		$template_dir = $1; 
	}
	if ($_ =~ /^query_dir\s*=\s*(\S+)/)
	{
		$query_dir = $1; 
	}
	if ($_ =~ /^use_tcoffee\s*=\s*(\S+)/)
	{
		$use_tcoffee = $1; 
	}
	if ($_ =~ /^use_palign_prof\s*=\s*(\S+)/)
	{
		$use_palign_prof = $1; 
	}
}

#check the existence of these directories 
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $clustalw_dir || die "can't find clustalw dir.\n";
-d $palign_dir || die "can't find palign dir.\n";
-d $tcoffee_dir || die "can't find tcoffee dir.\n";
-d $hmmer_dir || die "can't find hmmer dir.\n";
-d $prosys_dir || die "can't find prosys dir.\n";
-d $template_dir || die "can't find template dir.\n";
-d $query_dir || die "can't find query dir.\n";

$feature_name = ""; 
$feature = ""; 
$script_dir = "$prosys_dir/script";

#attribute names and values
@attr_names = ();
@attr_values = (); 

#1. feature_pair_seq.pl: script dir, query file, query format, template file, template format

print "extract sequence pairing feature...\n";
$feature_name .=  "query_len target_len cos_of_comp1 corr_of_comp1 exp_of_comp1 cos_of_comp2 corr_of_comp2 exp_of_comp2 ";
push @attr_names, ("query_len",  "target_len", "cos_of_comp1", "corr_of_comp1", "exp_of_comp1", "cos_of_comp2",  "corr_of_comp2", "exp_of_comp2");
system("$script_dir/feature_pair_seq.pl $script_dir $query_file fasta $target_file fasta > $query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read sequence pairing features.\n";
@fea = <RES>;
close RES;
shift @fea;
shift @fea;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract sequence pairing features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "sequence pairing feature num doesn't match with feature values:$fea_num," , join(" ", @values), "\n"; 
}
$feature .= join(" ", @values) . " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 
#2. feature_pair_fam.pl: script dir, query file, query format, template file, template format, 
#query msa, template msa

print "extract family pairing feature...\n";
$feature_name .=  "cos_of_famcomp1 corr_of_fam comp1 exp_of_famcomp1 cos_of_famcomp2 corr_of_famcomp2 exp_of_famcomp2 ";
push @attr_names, ("cos_of_famcomp1", "corr_of_famcomp1", "exp_of_famcomp1", "cos_of_famcomp2","corr_of_famcomp2", "exp_of_famcomp2");
$query_msa = "$query_dir/$qname.align"; 
-f $query_msa || die "can't find query msa file: $query_msa\n"; 
$temp_msa = "$template_dir/$tname.align";
-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
system("$script_dir/feature_pair_fam.pl $script_dir $query_file fasta $target_file fasta $query_msa $temp_msa > $query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read sequence pairing features.\n";
@fea = <RES>;
close RES;
shift @fea;
shift @fea;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract family pairing features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "family pairing feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#3. feature_align_seq.pl: script dir, alignment tool dir, tool name, query file, query format, target file, target foramt

print "extract sequence alignment feature using palign...\n";
$feature_name .=  "palign_seq_align_score1 palign_seq_align_score2";
push @attr_names, ("palign_seq_align_score1", "palign_seq_align_score1");
system("$script_dir/feature_align_seq.pl $script_dir $palign_dir palign $query_file fasta $target_file fasta > $query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read sequence alignment features using palign.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract sequence alignment features using palign.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "sequence alignment feature num using palign doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	print join(",", @attr_names), "\n", join(",", @attr_values), "\n"; 
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 

print "extract sequence alignment feature using clustalw...\n";
$feature_name .=  "clustalw_seq_align_score ";
push @attr_names, "clustalw_seq_align_score ";
system("$script_dir/feature_align_seq.pl $script_dir $clustalw_dir clustalw $query_file fasta $target_file fasta > $query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read sequence alignment features using clustalw.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract sequence alignment features using clustalw.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "sequence alignment feature num using clustalw doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#4. feature_align_prof_clustalw.pl: script dir, clustalw dir, query file(fasta), query msa, target file(fasta), target msa, output file

print "extract profile-alignment feature using clustalw...\n";
$feature_name .=  "clustalw_prof_align_score ";
push @attr_names,  "clustalw_prof_align_score ";
$query_msa = "$query_dir/$qname.align"; 
-f $query_msa || die "can't find query msa file: $query_msa\n"; 
$temp_msa = "$template_dir/$tname.align";
-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
#print("$script_dir/feature_align_prof_clustalw.pl $script_dir $clustalw_dir $query_file $query_msa $target_file $temp_msa $query_file.fea > /dev/null\n"); 
system("$script_dir/feature_align_prof_clustalw.pl $script_dir $clustalw_dir $query_file $query_msa $target_file $temp_msa $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read clustalw profile alignment features.\n";
@fea = <RES>;
close RES;
#shift @fea;
#shift @fea;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract clustalw profile alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "clustal profile alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}

#backup the clustalw global alignment file
`mv $query_file.fea $query_file.clustalw`; 
#`rm $query_file.fea`; 


#5. feature_align_prof_palign.pl: palignp dir, query file(fasta), query pssm file, target file
#(fasta), target pssm file, output file
if ($use_palign_prof == 1)
{
print "extract profile-alignment feature using palign...\n";
$feature_name .=  "palign_prof_align_score1 palign_prof_align_score2";
push @attr_names, ("palign_prof_align_score1","palign_prof_align_score2");
$query_pssm = "$query_dir/$qname.pssm"; 
-f $query_pssm || die "can't find query pssm file: $query_pssm\n"; 
$temp_pssm = "$template_dir/$tname.pssm";
-f $temp_pssm || die "can't find template pssm file: $temp_pssm\n"; 
system("$script_dir/feature_align_prof_palign.pl $palign_dir $query_file $query_pssm $target_file $temp_pssm $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read palign profile alignment features.\n";
@fea = <RES>;
close RES;
#shift @fea;
#shift @fea;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract palign profile alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "palign profile alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 
}


#6. feature_align_prof_psiblast.pl: script dir, blast dir, query file(fasta), query chk file, 
#target file(fasta), output file

print "extract profile-sequence alignment feature using psi-blast...\n";
$feature_name .=  "psiblast_align_score psiblast_evalue psiblast_align_norm_length psiblast_int_rate psiblast_pos_rate ";
push @attr_names, ("psiblast_align_score", "psiblast_evalue", "psiblast_align_norm_length", "psiblast_int_rate", "psiblast_pos_rate");
$query_chk = "$query_dir/$qname.chk"; 
-f $query_chk || die "can't find query chk file: $query_chk\n"; 
system("$script_dir/feature_align_prof_psiblast.pl $script_dir $blast_dir $query_file $query_chk $target_file $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read psiblast profile alignment features.\n";
@fea = <RES>;
close RES;
#shift @fea;
#shift @fea;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract psiblast profile-sequence alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "psi-blast profile-seq alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#7. feature_align_prof_tcoffee.pl: script dir, tcoffee dir, query file(fasta), query msa, target file(fasta), target msa, output file.

if ($use_tcoffee == 1)
{

print "extract profile-alignment feature using tcoffee...\n";
$feature_name .=  "tcoffee_prof_align_score ";
push @attr_names, "tcoffee_prof_align_score";
$query_msa = "$query_dir/$qname.align"; 
-f $query_msa || die "can't find query msa file: $query_msa\n"; 
$temp_msa = "$template_dir/$tname.align";
-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
system("$script_dir/feature_align_prof_tcoffee.pl $script_dir $tcoffee_dir $query_file $query_msa $target_file $temp_msa $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read t-coffee profile alignment features.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract tcoffee profile alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "tcoffee profile alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 
}


#8. hmmer_pfam.pl: hmmer dir, query fasta file, target hmm file, target file(fasta), output file

print "extract sequence-profile alignment feature using hmmer_pfam...\n";
$feature_name .=  "hmmer_pfam_score hmmer_pfam_evalue ";
push @attr_names, ("hmmer_pfam_score", "hmmer_pfam_evalue");
$temp_hmm = "$template_dir/$tname.hmm"; 
-f $temp_hmm || die "can't find target hmm file: $temp_hmm\n"; 
system("$script_dir/hmmer_pfam.pl $hmmer_dir $query_file $temp_hmm $target_file $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read hmmer pfam profile alignment features.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract hmmerpfam sequence-profile alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "hmmerpfam sequence-profile alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#9. hmmer_search.pl: hmmer dir, query fasta file, query hmm file, target file(fasta), output file.

print "extract profile-sequence alignment feature using hmmer_search...\n";
$feature_name .=  "hmmer_search_score hmmer_search_evalue ";
push @attr_names, ("hmmer_search_score", "hmmer_search_evalue");
$query_hmm = "$query_dir/$qname.hmm"; 
-f $query_hmm || die "can't find query hmm file: $query_hmm\n"; 
system("$script_dir/hmmer_search.pl $hmmer_dir $query_file $query_hmm $target_file $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read hmmer search profile alignment features.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract hmmer search profile-sequence alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "hmmer search profile-sequence alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#10. impala.pl: script dir, blast dir, query file, target file, target chk file(naming: name.chk), output file

print "extract sequence-profile alignment feature using impala...\n";
$feature_name .=  "impala_align_score impala_evalue impala_align_length impala_int_rate impala_pos_rate ";
push @attr_names, ("impala_align_score", "impala_evalue", "impala_align_length", "impala_int_rate", "impala_pos_rate");
$temp_chk = "$template_dir/$tname.chk"; 
-f $temp_chk || die "can't find target chk file: $temp_chk\n"; 
system("$script_dir/impala.pl $script_dir $blast_dir $query_file $target_file $temp_chk $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read impala profile alignment features.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract impala sequence-profile alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "impala sequence-profile alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#11. rps_blast.pl: script dir, blast dir, query file, target file, target chk file(naming: name.chk), output file

print "extract sequence-profile alignment feature using rps-blast...\n";
$feature_name .=  "rpsblast_align_score rpsblast_evalue rpsblast_align_length rpsblast_int_rate rpsblast_pos_rate ";
push @attr_names, ("rpsblast_align_score", "rpsblast_evalue", "rpsblast_align_length", "rpsblast_int_rate", "rpsblast_pos_rate");
$temp_chk = "$template_dir/$tname.chk"; 
-f $temp_chk || die "can't find target chk file: $temp_chk\n"; 
system("$script_dir/rps_blast.pl $script_dir $blast_dir $query_file $target_file $temp_chk $query_file.fea > /dev/null"); 
open(RES, "$query_file.fea") || die "can't read rpsblast profile alignment features.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract rpsblast sequence-profile alignment features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "rpsblast sequence-profile alignment feature num doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#12. feature_ssa_global.pl: query file(fasta), query cm file(conpro foramt), target file(9-line set format, no title), alignment file(global alignment from clustalw)

print "extract ss, sa info using clustalw  alignments...\n";
$feature_name .=  "ss_match_ratio sa_match_ratio ";
push @attr_names, ("ss_match_ratio", "sa_match_ratio");
$query_cm = "$query_dir/$qname.cm8a";
-f $query_cm || die "can't find query cm8a file: $query_cm\n"; 
$temp_set = "$template_dir/$tname.set";
-f $temp_set || die "can't find template dataset file: $temp_set\n"; 
system("$script_dir/feature_ssa_global.pl $query_file $query_cm $temp_set $query_file.clustalw >$query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read ssa features using global alignment.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract ss and sa features from global alignment.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "ss sa feature number from global alignment doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 


#13. feature_cm_global.pl: query file(fasta), query cm file(conpro foramt), target file(9-line set format, no title), alignment file(global alignment from clustalw), contact threshold

print "extract cm8a info using clustalw  alignments...\n";
$feature_name .=  "norm_contact_prob_8a cosin_of_residue_contact_num corr_of_residue_contact_num cosin_of_residue_contact_num corr_of_residue_contact_num";
push @attr_names, ("norm_contact_prob_8a", "cosin_of_residue_contact_num", "corr_of_residue_contact_num", "cosin_of_residue_contact_num", "corr_of_residue_contact_num");
$query_cm = "$query_dir/$qname.cm8a";
-f $query_cm || die "can't find query cm8a file: $query_cm\n"; 
$temp_set = "$template_dir/$tname.set";
-f $temp_set || die "can't find template dataset file: $temp_set\n"; 
system("$script_dir/feature_cm_global.pl $script_dir $query_file $query_cm $temp_set $query_file.clustalw  8 >$query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read cm8a features using global alignment.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract cm8a features from global alignment.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "cm8a feature number from global alignment doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}

print "extract bcm8a info using clustalw  alignments...\n";
$feature_name .=  "norm_contact_prob_bcm8a cosin_of_residue_contact_num corr_of_residue_contact_num cosin_of_residue_contact_num corr_of_residue_contact_num";
push @attr_names, ("norm_contact_prob_bcm8a", "cosin_of_residue_contact_num", "corr_of_residue_contact_num", "cosin_of_residue_contact_num", "corr_of_residue_contact_num");
$query_cm = "$query_dir/$qname.bcm8a";
-f $query_cm || die "can't find query bcm8a file: $query_cm\n"; 
$temp_set = "$template_dir/$tname.set";
-f $temp_set || die "can't find template dataset file: $temp_set\n"; 
system("$script_dir/feature_cm_global.pl $script_dir $query_file $query_cm $temp_set $query_file.clustalw  8 >$query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read bcm8a features using global alignment.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract bcm8a features from global alignment.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "bcm8a feature number from global alignment doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 

print "extract cm12a info using clustalw  alignments...\n";
#$feature_name .=  "norm_contact_prob_12a ";
$feature_name .=  "norm_contact_prob_bcm12a cosin_of_residue_contact_num corr_of_residue_contact_num cosin_of_residue_contact_num corr_of_residue_contact_num";
push @attr_names, ("norm_contact_prob_bcm12a", "cosin_of_residue_contact_num", "corr_of_residue_contact_num", "cosin_of_residue_contact_num", "corr_of_residue_contact_num");
$query_cm = "$query_dir/$qname.cm12a";
-f $query_cm || die "can't find query cm12a file: $query_cm\n"; 
$temp_set = "$template_dir/$tname.set";
-f $temp_set || die "can't find template dataset file: $temp_set\n"; 
system("$script_dir/feature_cm_global.pl $script_dir $query_file $query_cm $temp_set $query_file.clustalw  12 >$query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read cm12a features using global alignment.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract cm12a features from global alignment.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "cm12a feature number from global alignment doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 

#14. feature_bcm_global.pl: query file(fasta), query beta residue pairing file, target file(9-line set format, no title), alignment file(from clustalw).

print "extract betamap info using clustalw  alignments...\n";
$feature_name .=  "norm_betamap_prob ";
push @attr_names, "norm_betamap_prob";
$query_cm = "$query_dir/$qname.bmap";
-f $query_cm || die "can't find query bmap file: $query_cm\n"; 
$temp_set = "$template_dir/$tname.set";
-f $temp_set || die "can't find template dataset file: $temp_set\n"; 
system("$script_dir/feature_bcm_global.pl $query_file $query_cm $temp_set $query_file.clustalw >$query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read bmap features using global alignment.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract betamap features from global alignment.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "betamap feature number from global alignment doesn't match with feature values.\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}
`rm $query_file.fea`; 

#15. feature_pair_ssa.pl: script dir, query file(fasta), query cm file(conpro format), target file(9-line set format, no title).

print "extract ssa pairing info...\n";
$feature_name .=  "ssa_comp_query(5) ssa_comp_target(5) ssa_cos ssa_corr ssa_exp dot_product ";
push @attr_names, ( "qhelix", "qstrand", "qcoil", "qexpo", "qburied", "thelix", "tstrand", "tcoil", "texpo", "tburied",  "ssa_cos", "ssa_corr", "ssa_exp", "ssa dot_product");
$query_cm = "$query_dir/$qname.cm8a";
-f $query_cm || die "can't find query cm8a file: $query_cm\n"; 
$temp_set = "$template_dir/$tname.set";
-f $temp_set || die "can't find template dataset file: $temp_set\n"; 
system("$script_dir/feature_pair_ssa.pl $script_dir $query_file $query_cm $temp_set >$query_file.fea"); 
open(RES, "$query_file.fea") || die "can't read ssa pairing features.\n";
@fea = <RES>;
close RES;
$fea_num = shift @fea;
if ($fea_num =~ /^feature num:\s*(\d+)/)
{
	$fea_num = $1; 
}
else
{
	die "fail to extract ssa pairing features.\n"; 
}
$fea_values = shift @fea;
@values = split(/\s+/, $fea_values);
if ($fea_num != @values)
{
	die "ssa pairing feature number doesn't match with feature values:$fea_num,", join(" ", @values), ".\n"; 
}
$feature .= join(" ", @values). " "; 
push @attr_values, @values; 
if (@attr_names != @attr_values)
{
	die "number of attributes doens't match with number of values.\n";
}

print "All the features have been generated.\n";

open(OUT, ">$out_file") || die "can't create output file.\n"; 
print OUT "$qname $tname\n$feature_name\n$feature\n"; 

$attr_num  = @attr_values;
print "Total number of features: $attr_num\n"; 
for ($i = 0; $i < $attr_num; $i++)
{
	print OUT "$attr_names[$i]: $attr_values[$i]\n";
}

`rm $query_file.clustalw $query_file.fea`; 
