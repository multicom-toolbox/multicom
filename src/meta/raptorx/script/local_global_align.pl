#!/usr/bin/perl -w
######################################################################
#Local - Global alignment combination algorithm
#Inputs: alignment option file, a local alignment file, fasta file, 
#an output name, number of composite aligments
#Outputs: combined alignments that use multiple templates, as long as
#possible, and structurally consistent
#Starte Date: 1/2/2010
#Author: Jianlin Cheng
#Tools and data: TM_Score, Clustal, PDB files of templates, template
#sequences
#due to time constraints, if the coverage of the first alignment > 80%, 
#at most 100 local alignments are selected
#######################################################################

$MAX_ALIGN = 100; 
$highest_num = 250; #support at most 200 local alignments to control the maximum time
$coverage_threshold = 0.8; 
$min_domain_length = 30; #used to judge if a domain is missing
$max_extension_length = 20; #the maximum length of extension at tails 

if (@ARGV != 4)
{
	die "need four parameters: alignment option file, a local alignment file, fasta query file, an output name.\n";
}

$align_option = shift @ARGV;
$local_align_file = shift @ARGV;
$fasta_file = shift @ARGV;
$output_name = shift @ARGV;

open(OPTION, $align_option) || die "can't read $align_option file.\n";

$align_dir="/home/jh7x3/multicom_beta1.0/src/meta/hhpred/script"; 

while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^tm_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tm_score = $value; 
	}
	if ($line =~ /^tm_align/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tm_align = $value; 
	}
	
	if ($line =~ /^atom_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$atom_dir = $value; 
		
	}

	if ($line =~ /^seq_lib/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$seq_lib = $value; 
		
	}

	if ($line =~ /^align_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$align_dir = $value; 
		
	}

	if ($line =~ /^clustalw_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$clustalw_dir = $value; 
		
	}
}

close OPTION;

-f $tm_score || die "can't find program $tm_score.\n";
-f $tm_align || die "can't find program $tm_align.\n";
-d $atom_dir || die "can't find atom dir $atom_dir.\n";
-f $seq_lib  || die "can't find sequence library file $seq_lib.\n";
-d $clustalw_dir || die "can't find clustalw dir $clustalw_dir.\n";
-d $align_dir || die "can't find alignment package dir $align_dir.\n";

#get query name and sequence 
open(FASTA, $fasta_file) || die "can't read fasta file.\n";
$qname = <FASTA>;
chomp $qname; 
$qname = substr($qname, 1);
$qseq = <FASTA>;
chomp $qseq; 
$qlen = length($qseq); 
chomp $qseq;
close FASTA;

#Step 0: read local alignments and create a data structure to store them
open(LOCAL, $local_align_file) || die "can't read local alignment file: $local_align_file.\n";
@local = <LOCAL>;
close LOCAL; 

if (@local < 5)
{
	warn "no local alignments exist.\n";
	exit; 
}

$line = shift @local;
@fields = split(/\s+/, $line);
$name = $fields[0];
#$len = $fields[1]; 

$qname eq $name || die "query names do not match: $qname != $name.\n";
#$qlen == $len || die "query lengths do not mache: $qlen != $len.\n"; 

$align_id = 0; 

$coverage = 0; 
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
	if ($coverage <= 0)
	{
		$coverage = ($qend - $qstart + 1) / $qlen;  
	}
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
			qname => $qname,
			qlen => $qlen,
			tname => $tname,
			tlen => $tlen,
			score => $score, 
			evalue => $evalue,
	#		align_len => $align_len,
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
	}
				
}

#Step 1: remove redundant fragments from the template
print "Analyze local alignments...\n";
print "Remove redundant local alignments...\n";
@new_local_list = (); 
$count = 0; 
foreach $local (@local_list)
{
	$redundant = 0;
	foreach $select (@new_local_list)
	{
		if ($local->{"tname"} eq $select->{"tname"} && $local->{"qstart"} >= $select->{"qstart"} && $local->{"qend"} <= $select->{"qend"})
		{
			$redundant = 1; 
		}
	}	

	if ($redundant == 1)
	{
	#	print "redundant alignment: ",  $local->{"tname"}, " ", $local->{"qstart"}, " ", $local->{"qend"}, " is redundant and is removed.\n"
		;
	}
	else
	{
		push @new_local_list, $local; 
		$count++; 
		if ( ($coverage >= $coverage_threshold && $count == $MAX_ALIGN) || $count >= $highest_num)
		{
			print "The coverage of the top alignment > $coverage_threshold, so only up to $MAX_ALIGN alignments are selected to save time.\n";
			last;
		}
	}

}
#print "$count non-redundant alignments are selected.\n";

#set an index for each entry
for ($i = 0; $i < @new_local_list; $i++)
{
	$new_local_list[$i]->{"idx"} = $i; 
}

#check the structure consistence between local alignments (expensive)
	#should move it to the next step? 

#Step 2: create scalffolds for disjoint local alignments from the same templates
#Be aware of domain swapping and repetition. If the query match
#two disjoint fragments of the same template with reverse order
#the two fragments will be broken into two templates. 

#create disjoint scalfold for the same template
print "Construct scalfolds of each template...\n";
@scalfolds = (); 
@anchors = (); 

for ($i = 0; $i < @new_local_list; $i++)
{
	$local = $new_local_list[$i];
	if ($local->{"inscalfold"} == 1)
	{
		next; 	
	}
	
	$local->{"anchor"} = 1;
	$local->{"inscalfold"} = 1; 

	$tname1 = $local->{"tname"}; 
	
	@join_local = ($local->{"idx"});  

	for ($j = 0; $j < @new_local_list; $j++)
	{
		if ($j == $i)
		{
			#skip itself
			next; 
		}
		$candidate = $new_local_list[$j]; 	
		$tname2 = $candidate->{"tname"}; 	
		if ($tname1 ne $tname2)
		{
			next; 
		}
		print "same template: $tname1 ($i, $j)\n";
		
		#insert the local into the scalfold if necessary (insertion sorting)
		$pos = -1; 
		for ($k = 0; $k < @join_local; $k++)
		{
			#comparison
			$cur = $new_local_list[$join_local[$k]]; 					
			if ( $candidate->{"qstart"} > $cur->{"qend"})
			{
				if ($k == @join_local - 1)
				{
					#at the last element
					if ($candidate->{"tstart"} > $cur->{"tend"})
					{
						$pos = $k + 1; 	
					}
					last; 
				}
				else
				{
					next; 
				}
			}
			elsif ($candidate->{"qstart"} == $cur->{"qend"})
			{
				last;
			}
			elsif ($candidate->{"qend"} < $cur->{"qstart"})
			{
				if ( $candidate->{"tend"} < $cur->{"tstart"})
				{
					$pos = $k;  
				} 	
				last; 
			}
			else
			{
				last;
			}
		}			
		#add the local into the joined list if necessary
		if ($pos > 0)
		{
			$candidate_idx = $candidate->{"idx"}; 	
			push @join_local, -1; 
			$pos < @join_local || die "insertion position is inconsisent.\n";
			#insert the candidate at the right place
			for ($m = @join_local - 1; $m >= 0; $m--)
			{
				if ($m < @join_local - 1)
				{
					$join_local[$m+1] = $join_local[$m]; 			
				}

				if ($m == $pos)
				{
					#decide if need to move the element
					$join_local[$m] = $candidate_idx; 	
				}	
			}	
		}	
				
	}

	#store the scalfolds
	push @scalfolds, join(" ", @join_local); 
	push @anchors, $tname1; 

}

for ($i = 0; $i < @scalfolds; $i++)
{
	#rarely see scalfolds with more than two local alignments. 
	#print "Scalfold $i: template = $anchors[$i], local alignment ids = $scalfolds[$i]\n"; 

	#so calfolds are not used in the next steps at this moment. 
	;
}


#Step 3: select (partial) scalffolds that are structurally consistent with each of top templates. The quality of a fragment will be measured by
#its similarity of other fragments of the same range by tm_score
#remove local alignments that are not structurally consisent

#compare if two local alignments are structurally consistent
print "Calculate the stuructural similarity between local alignments...\n";
sub compare_locals
{
	my ($local1, $local2) = @_; 		
	
	#get common query regions				
	my $comm_qstart = $local1->{"qstart"};
	my $comm_qend = $local1->{"qend"};
	if ($comm_qstart < $local2->{"qstart"})
	{
		$comm_qstart = $local2->{"qstart"}; 
	}
	if ($comm_qend > $local2->{"qend"})
	{
		$comm_qend = $local2->{"qend"}; 
	}

	#check if common regions is big enough
	if ($comm_qend - $comm_qstart + 1 < 15)
	{
	#	warn "regions are too small to compare.\n"; 
		return -1; 		
	}

	#get common structure regions for each template
	my $tstart1 = $local1->{"tstart"};  
	my $tend1 = $local1->{"tend"};
	my $qstart1 = $local1->{"qstart"};  
	my $qend1 = $local1->{"qend"};
	my $talign1 = $local1->{"talign"};
	my $qalign1 = $local1->{"qalign"};  
	my $align_len = length($qalign1); 
	#identify common template regions
	my $index = $qstart1 - 1; 
	my $adjusted_tstart1 = $adjusted_tend1 = -1;
	my $adjusted = $tstart1 - 1; 
	my $i; 
	for ($i = 0; $i < $align_len; $i++)
	{
		if (substr($talign1, $i, 1) ne "-")
		{
			$adjusted++; 	
		}
		if (substr($qalign1, $i, 1) ne "-")
		{
			$index++; 
			if ($index == $comm_qstart)
			{
				$adjusted_tstart1 = $adjusted; 	
			}
			if ($index == $comm_qend)
			{
				
				$adjusted_tend1 = $adjusted; 	
			}
		}		
	} 
	$adjusted_tend1 >= $adjusted_tstart1 || die "wrong: adjusted end 1 < adjusted start 1.\n";

	
	my $tstart2 = $local2->{"tstart"};  
	my $tend2 = $local2->{"tend"};
	my $qstart2 = $local2->{"qstart"};  
	my $qend2 = $local2->{"qend"};
	my $talign2 = $local2->{"talign"};
	my $qalign2 = $local2->{"qalign"};  
	$align_len = length($qalign2); 
	#identify common template regions
	$index = $qstart2 - 1; 
	my $adjusted_tstart2 = $adjusted_tend2 = -1;
	$adjusted = $tstart2 - 1; 
	for ($i = 0; $i < $align_len; $i++)
	{
		if (substr($talign2, $i, 1) ne "-")
		{
			$adjusted++; 	
		}
		if ( substr($qalign2, $i, 1) ne "-")
		{
			$index++; 
			if ($index == $comm_qstart)
			{
				$adjusted_tstart2 = $adjusted; 	
			}
			if ($index == $comm_qend)
			{
				$adjusted_tend2 = $adjusted; 	
			}
		}		
	} 
	$adjusted_tend2 >= $adjusted_tstart2 || die "wrong: " . $local2->{"tname"} . ", adjusted end 2 ($adjusted_tend2)  < adjusted start 2 ($adjusted_tstart2).\n";

	#get structures of common regions of two templates
	my $tname1 = $local1->{"tname"};
	my $tname2 = $local2->{"tname"};
	my $pdb1 = "$tname1.pdb";
	my $pdb2 = "$tname2.pdb";

	if (! -f $pdb1)
	{
		`cp $atom_dir/$tname1.pdb .`; 
	}
	
	if (! -f $pdb2)
	{
		`cp $atom_dir/$tname2.pdb .`; 
	}

	#create two temporary alignment file		
	open(TMP, ">$tname1.frag1"); 
	open(ATM, "$pdb1") || die "can't read $tname1.atm.";
	@atom = <ATM>;
	close ATM; 
	while (@atom)
	{
		$line = shift @atom;
		if ($line =~ /^ATOM/)
		{
		#	@fields = split(/\s+/, $line);
		#	my $a_idx = $fields[4]; 
			my $a_idx = substr($line, 22, 4); 
			$a_idx =~ s/\s//g; 
			if ($a_idx >= $adjusted_tstart1 && $a_idx <= $adjusted_tend1)
			{
				print TMP $line;
			}
		}
		elsif ($line =~ /^END/)
		{
			print TMP $line;
		}
	}
	close TMP; 

	open(TMP, ">$tname2.frag2"); 
	open(ATM, "$pdb2") || die "can't read $tname2.atm.";
	@atom = <ATM>;
	close ATM; 
	while (@atom)
	{
		$line = shift @atom;
		if ($line =~ /^ATOM/)
		{
			#@fields = split(/\s+/, $line);
			#my $a_idx = $fields[4]; 
			my $a_idx = substr($line, 22, 4); 
			$a_idx =~ s/\s//g; 
			if ($a_idx >= $adjusted_tstart2 && $a_idx <= $adjusted_tend2)
			{
				print TMP $line;
			}
		}
		elsif ($line =~ /^END/)
		{
			print TMP $line;
		}
	}
	close TMP; 

	#compare two structure fragments
	system("$tm_align $tname2.frag2 $tname1.frag1 > $tname2-$tname1"); 
	open(RES, "$tname2-$tname1") || die "can't read fragment alignment results.\n";
	$score = 0;
	while ($line = <RES>)
	{
		if ($line =~ /TM-score=([\d|.]+),/)
		{
			$score = $1; 	
			last;
		}
	}	
	close RES;

	`rm $tname1.frag1 $tname2.frag2 $tname2-$tname1`; 
	return $score; 	
}

open(SIM, ">$output_name.sim") || die "can't create $output_name.sim.\n";; 
for ($i = 0; $i < @new_local_list; $i++)
{
	$local = $new_local_list[$i]; 
	$lid = $local->{"idx"};
	for ($j = 0; $j < $i; $j++)
	{
		$local2 = $new_local_list[$j]; 
		#compare each local with its top to see if it is strcturally consistent
		
		$score = &compare_locals($local2, $local); 
		$pair_id = $local->{"tname"} . "-" . $local->{"qstart"} . "-" . $local->{"qend"} . "-" . $local->{"tstart"} . "-" . $local->{"tend"} . ":";  
		$pair_id .= ($local2->{"tname"} . "-" . $local2->{"qstart"} . "-" . $local2->{"qend"} . "-" . $local2->{"tstart"} . "-" . $local2->{"tend"});  
		
#		print "$pair_id = $score\n";
		$id = $local2->{"idx"} . "-" . $local2->{"tname"} . "-" . $lid . "-" . $local->{"tname"};
		print SIM $id, "\t", $score, "\n"; 
#		<STDIN>;
	}
}
close SIM; 

#Step 4: append tail regions and fill gaps between fragments within scalffolds. Sometime, we may need to chop off unaligned regions if they. So we have two options here: chop or join. 
#if chop, we will change template pdb file
#are already covered by local alignments
#using global alignments. Be aware of domain issues. 
#A large domain region should not be simply filled by global alignments
#but it may be filled in by an ab initio domain later
#now, the main task is to append tail regions and check if one domain is missing. (domain missing, we should find an template to fill entire domain
#instead of short fragments or suggest to call ab initio domain - use Rosetta loop building)  
#########################################################
#Using Align.pm ------------ Developed by Soeding.
#########################################################

use lib "/home/jh7x3/multicom_beta1.0/src/meta/script/";
use Align; 
#load the alignment methods
#require "$align_dir/align_methods.pl";

print "Check if front or end domains are missing...\n";
$left_domain_missing = 10000;
$right_domain_missing = 10000; 

$first_left_len = 0;
$first_right_len = 0; 
for ($i = 0; $i < @new_local_list; $i++)
{
	$local = $new_local_list[$i]; 	
	if ($local->{"ltail_len"} < $left_domain_missing && ($local->{"qend"} - $local->{"qstart"} + 1 >= $min_domain_length) )
	{
		$left_domain_missing = $local->{"ltail_len"}; 
		if ($i == 0)
		{
			$first_left_len = $left_domain_missing; 
		}
	}
	if ($local->{"rtail_len"} < $right_domain_missing && ($local->{"qend"} - $local->{"qstart"} + 1 >= $min_domain_length) )
	{
		$right_domain_missing = $local->{"rtail_len"}; 
		if ($i == 0)
		{
			$first_right_len = $right_domain_missing; 
		}
	}
}

#get all the template sequences
open(LIB, $seq_lib) || die "can't read $seq_lib.\n";
%name2seq = (); 
while (<LIB>)
{
	$name = substr($_, 1);
	chomp $name;
	$seq = <LIB>;
	chomp $seq; 
	$found = 0; 
	for ($i = 0; $i < @new_local_list; $i++)
	{
		if ($name eq $new_local_list[$i]->{"tname"})
		{
			$found = 1; 
			last;
		}
	}	
	if ($found == 1)
	{
		$name2seq{$name} = $seq; 
	}
}
close LIB; 

#do extension
print "Extend local alignments if necessary....\n";
open(EXT, ">$output_name.ext") || die "can't create $output_name.ext.\n";

if ($left_domain_missing >= $min_domain_length)
{
	print EXT "Warning: the left domain of $left_domain_missing residues is not covered.\n";
	print EXT "Suggested left domain size for re-modeling: $first_left_len.\n\n";
}

if ($right_domain_missing >= $min_domain_length)
{
	print EXT "Warning: the right domain of $right_domain_missing residues is not covered.\n\n";
	print EXT "Suggested right domain size for re-modeling: $first_right_len.\n\n";
}

#@ext_local_list = (); 

open(EXT_LOCAL, ">$output_name.local.ext") || die "can't create $output_name.local.ext.\n";
print EXT_LOCAL "$qname $qlen (line 1: template name, template length, score, evalue, id; line 2: qstart qend, tstart tend; line 3: query align; line 4: template align)\n";

for ($i = 0; $i < @new_local_list; $i++)
{
	$left_ext_len = 100000; 
	$right_ext_len = 100000; 	
	$local = $new_local_list[$i]; 

	#calculate the length of left extension
	$l_tlen = $local->{"tstart"} - 1; 
	if ($left_ext_len > $l_tlen) { $left_ext_len = $l_tlen; } 
	if ($left_ext_len > $local->{"ltail_len"}) { $left_ext_len = $local->{"ltail_len"} };
	if ($left_ext_len > $max_extension_length) { $left_ext_len = $max_extension_length }; 
	
	#calculate the length of right extension
	$r_tlen = $local->{"tlen"} - $local->{"tend"}; 
	if ($right_ext_len > $l_tlen) { $right_ext_len = $r_tlen }; 
	if ($right_ext_len > $local->{"rtail_len"}) { $right_ext_len = $local->{"rtail_len"} };
	if ($right_ext_len > $max_extension_length) { $right_ext_len = $max_extension_length }; 

	$tname = $local->{"tname"}; 

	if (exists $name2seq{$tname})
	{
		$tseq = $name2seq{$tname}; 
	}
	else
	{
		die "can't find the sequence of the template $tname.\n";
	}
	
	our $d=5; #gap openning penalty for Align.pm
	our $e=0.5; #gap extension penalty for Align.pm
	our $g=1; #end gap penalty for Align.pm	
	#do left extension if necessary (only do extension for tail regions)


	if ($left_ext_len > 0 &&  $local->{"ltail_len"} <= $max_extension_length && 0)
	{
		#do left extension
		$left_qseq = substr($qseq, $local->{"qstart"} - $left_ext_len - 1, $left_ext_len);  
		$left_tseq = substr($tseq, $local->{"tstart"} - $left_ext_len - 1, $left_ext_len);
		#align left and righ sequence
		print EXT "Extend the left tail of $tname ($left_qseq, $left_tseq) = ";
		#$align_score = &AlignNW(\$left_qseq, \$left_tseq, \@a, \@b, \$imin, \$imax, \$jmax, \$str);
		$align_score = &AlignNW(\$left_qseq, \$left_tseq);
		print EXT "($left_qseq, $left_tseq) = $align_score; ";

		#strip out the left gaps
		$q_left_ext = $t_left_ext = $left_ext_len; 
		
		$left_gaps = 0; 		
		for ($k = 0; $k < length($left_qseq); $k++)
		{
			$q_aa = substr($left_qseq, $k, 1);	
			$t_aa = substr($left_tseq, $k, 1);	
			if ($q_aa ne "-" && $t_aa ne "-")
			{
				last;
			}
			else
			{
				if ($q_aa eq "-" && $t_aa ne "-")
				{
					--$t_left_ext; 
				}
				if ($t_aa eq "-" && $q_aa ne "-")
				{
					--$q_left_ext;
				}
				++$left_gaps; 
			}
		
		}
		if ($t_left_ext > 0 && $q_left_ext > 0)
		{
			$left_qseq = substr($left_qseq, $left_gaps); 
			$left_tseq = substr($left_tseq, $left_gaps); 

			print EXT "adjusted extension ($left_qseq, $left_tseq)\n";
		}

	}	
	
	#do right extension if necessary
	#disable extension because the index problem of hhpred pdb file
	if ($right_ext_len > 0 && $local->{"rtail_len"} <= $max_extension_length && 0)
	{
		#do left extension
		$right_qseq = substr($qseq, $local->{"qend"}, $right_ext_len);  
		$right_tseq = substr($tseq, $local->{"tend"}, $right_ext_len);
		#align left and righ sequence
		print EXT "Extend the right tail of $tname ($right_qseq, $right_tseq) = ";
		$align_score = &AlignNW(\$right_qseq, \$right_tseq);
		print EXT "($right_qseq, $right_tseq) = $align_score, ";

		#strip out the left gaps
		$q_right_ext = $t_right_ext = $right_ext_len; 
		
		$right_gaps = 0; 		
		for ($k = length($right_qseq) - 1; $k >= 0; $k--)
		{
			$q_aa = substr($right_qseq, $k, 1);	
			$t_aa = substr($right_tseq, $k, 1);	
			if ($q_aa ne "-" && $t_aa ne "-")
			{
				last;
			}
			else
			{
				if ($q_aa eq "-" && $t_aa ne "-")
				{
					--$t_right_ext; 
				}
				if ($t_aa eq "-" && $q_aa ne "-")
				{
					--$q_right_ext;
				}
				++$right_gaps; 
			}
		
		}

		if ($t_right_ext > 0 && $q_right_ext > 0)
		{
			$tmp_len = length($right_qseq); 
			$right_qseq = substr($right_qseq, 0, $tmp_len - $right_gaps); 
			$right_tseq = substr($right_tseq, 0, $tmp_len - $right_gaps); 

			print EXT "adjusted extension ($right_qseq, $right_tseq)\n";
		}
	}	

	#output the extended local alignments
	print EXT_LOCAL "\n";
		
	#print EXT_LOCAL $local->{"tname"}, "\t", $local->{"tlen"}, "\t", $local->{"score"}, "\t", $local->{"evalue"}, "\t", $local->{"align_len"}, "\t", $local->{"idx"}, "\n";
	print EXT_LOCAL $local->{"tname"}, "\t", $local->{"tlen"}, "\t", $local->{"score"}, "\t", $local->{"evalue"}, "\t", $local->{"idx"}, "\n";

	$qstart = $local->{"qstart"}; 
	$qend = $local->{"qend"}; 
	$tstart = $local->{"tstart"};
	$tend = $local->{"tend"}; 	
	$qalign = $local->{"qalign"};
	$talign = $local->{"talign"}; 
		
	if ($left_ext_len > 0 && $local->{"ltail_len"} <= $max_extension_length && 0)
	{	
		if ($q_left_ext > 0 &&  $t_left_ext > 0)
		{
			$qstart -= $q_left_ext;
			$tstart -= $t_left_ext; 
			$qalign = $left_qseq . $qalign;  
			$talign = $left_tseq . $talign; 
		}
	}
	if ($right_ext_len > 0 && $local->{"rtail_len"} <= $max_extension_length && 0)
	{
		if ($q_right_ext > 0 && $t_right_ext > 0)
		{
			$qend += $q_right_ext; 
			$tend += $t_right_ext; 

			$qalign .= $right_qseq;
			$talign .= $right_tseq; 
		}
	}
	
	print EXT_LOCAL "$qstart\t$qend\t$tstart\t$tend\n";
	print EXT_LOCAL "$qalign\n$talign\n";

	#check the integrity of the sequence
	$qalign =~ s/-//g;	
	$qalign eq substr($qseq, $qstart-1, $qend - $qstart + 1) || die "query alignment is inconsistent: $tname\n";
	$talign =~ s/-//g;

	#this checking is not necessary because the hhpred pdb file's residue may not start from 1
	#$talign eq substr($tseq, $tstart-1, $tend - $tstart + 1) || die "template alignment is inconsistnet: $tname\n";

}

close EXT_LOCAL; 
close EXT; 



#Step 5: produce a number of combined alignments (below an evalue or at a pre-specified number)
###################################################################
#the algorithm will report some critical information:
#if there is an ab initio domain? 
#if there is an repeated domain? 
#if there is an domain combination
#the local coverage and overall coverage by the top template
#number of confident scalfolds
###################################################################

