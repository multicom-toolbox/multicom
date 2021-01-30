#!/usr/bin/perl -w
##########################################################################################
#generate pairwise prof-prof alignment for query and templates.
#Input: option_file, query file(fasta), template library file(fasta), template id list file, output file
#Output format: for each template, one or more alignments in pir format 
#are generated. the alignments between templates are separated by ===========.
#Author: Jianlin Cheng
#Date: 8/29/05
##########################################################################################
if (@ARGV != 5)
{
	die "need 5 parameters: option file(option_pairwise), query file(fasta), template library file(fasta), selected template id list file (fr format), output alignment file.\n";
}
$option_file = shift @ARGV;
$query_file = shift @ARGV;
$lib_file = shift @ARGV; 
$id_file = shift @ARGV;
$out_file = shift @ARGV;

open(OPTION, $option_file) || die "can't read option file.\n";
$alignment_method = "";
$lobster_dir = "";
$fr_palign_join_gap_size = 5; 
$fr_palign_stop_gap_size = 20;
$fr_palign_min_cover_size = 20; 
while(<OPTION>)
{
	$line = $_;
	if ($line =~ /^#/)
	{
		next;
	}
	if ($line =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($line =~ /^query_dir\s*=\s*(\S+)/)
	{
		$query_dir = $1; 
	}
	if ($line =~ /^template_dir\s*=\s*(\S+)/)
	{
		$template_dir = $1; 
	}
	if ($line =~ /^lobster_dir\s*=\s*(\S+)/)
	{
		$lobster_dir = $1; 
	}
	if ($line =~ /^clustalw_dir\s*=\s*(\S+)/)
	{
		$clustalw_dir = $1; 
	}
	if ($line =~ /^atom_dir\s*=\s*(\S+)/)
	{
		$atom_dir = $1; 
	}
	if ($line =~ /^tcoffee_dir\s*=\s*(\S+)/)
	{
		$tcoffee_dir = $1; 
	}
	if ($line =~ /^new_hhsearch_dir\s*=\s*(\S+)/)
	{
		$new_hhsearch_dir = $1; 
	}
	if ($line =~ /^spem_dir\s*=\s*(\S+)/)
	{
		$spem_dir = $1; 
	}
	if ($line =~ /^palign_dir\s*=\s*(\S+)/)
	{
		$palign_dir = $1; 
	}
	if ($line =~ /^compass_dir\s*=\s*(\S+)/)
	{
		$compass_dir = $1; 
	}
	if ($line =~ /^alignment_method\s*=\s*(\S+)/)
	{
		$alignment_method = $1; 
	}
	if ($line =~ /^fr_palign_join_gap_size\s*=\s*(\S+)/)
	{
		$fr_palign_join_gap_size = $1; 
	}
	if ($line =~ /^fr_palign_stop_gap_size\s*=\s*(\S+)/)
	{
		$fr_palign_stop_gap_size = $1; 
	}
	if ($line =~ /^fr_palign_min_cover_size\s*=\s*(\S+)/)
	{
		$fr_palign_min_cover_size = $1; 
	}

}
-d $prosys_dir || die "prosys dir doesn't exist.\n";
-f $query_file || die "query file doesn't exist.\n";
-f $id_file || die "id file doesn't exist.\n";
-f $lib_file || die "library file doesn't exist.\n";
-d $query_dir || die "query dir doesn't exist.\n";
-d $template_dir || die "template dir doesn't exist.\n";
-d $clustalw_dir || die "clustalw dir doesn't exist.\n";
-d $palign_dir || die "palign dir doesn't exist.\n";
-d $compass_dir || die "compass dir doesn't exist.\n";

-d $atom_dir || die "atom dir does not exist.\n";
-d $new_hhsearch_dir || die "new hhsearch doesn't exist.\n";
-d $spem_dir || die "spem dir doesn't exist.\n";

if ($alignment_method ne "clustalw" && $alignment_method ne "lobster" && $alignment_method ne "palign" && $alignment_method ne "palign_ss" && $alignment_method ne "tcoffee" && $alignment_method ne "hhsearch" && $alignment_method ne "spem" && $alignment_method ne "compass" && $alignment_method ne "muscle" && $alignment_method ne "prc")
{
	die "profile-profile alignment method is not specified. (must be clustalw, lobster, tcoffee, palign, hhsearch, spem, compass, muscle, and prc)\n";
}

#we support the following alignment methods: 
#clustalw, lobster, palign, palign_ss, tcoffee, hhsearch, spem

$script_dir = $prosys_dir . "/script";
-d $script_dir || die "prosys script dir doesn't exist.\n";

#read  query file
open(QUERY, $query_file) || die "can't read query file.\n";
$qname = <QUERY>;
close QUERY;
if ($qname =~ />(\S+)/)
{
	$qname = $1; 
}
else
{
	die "query file is not in fasta format.\n";
}

#read template library
%lib = (); 
open(LIB, $lib_file) || die "can't read library file.\n"; 
@entries = <LIB>;
close LIB; 
while (@entries)
{
	$tname = shift @entries;	
	$tseq = shift @entries;
	chomp $tseq; 
	if ($tname =~ />(\S+)/)
	{
		$tname = $1; 
	}
	else
	{
		die "library file is not in fasta format.\n";
	}
	if (!exists $lib{$tname})
	{
		$lib{$tname} = $tseq; 
	}
	else
	{
		die "library file includes redundant entries: $tname.\n"; 
	}
}


open(ID, $id_file) || die "can't read fr id list file.\n";
@ids = <ID>;
close ID; 

$title = shift @ids;
#check the format
if ($title =~ /Ranked templates for (\S+),/)
{
	$query_name = $1; 
}
else
{
	die "id file is not in right fr format.\n"; 
}

if ($query_name ne $qname)
{
	die "query name doesn't match the query name in the id list file.\n"; 
}

open(OUT, ">$out_file") || die "can't create output file.\n";

#generate alignments
while (@ids)
{
	$record = shift @ids;
	($rank, $tname, $score) = split(/\s+/, $record); 
	if (exists $lib{$tname})
	{
		$tseq = $lib{$tname};
	}
	else
	{
		die "can't find template $tname in the library file.\n"; 
	}

	#create template file
	open(TEMP, ">$tname.fasta") || die "can't create template fasta file.\n"; 
	print TEMP ">$tname\n$tseq\n";
	close TEMP; 

	print "generate profile-profile alignment for $qname and $tname using $alignment_method...";

	if ($alignment_method eq "clustalw")
	{
		$query_msa = "$query_dir/$qname.align";
		-f $query_msa || die "can't find query msa file: $query_msa\n"; 
		$temp_msa = "$template_dir/$tname.align";
		-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
		system("$script_dir/feature_align_prof_clustalw.pl $script_dir $clustalw_dir $query_file $query_msa $tname.fasta $temp_msa $tname.res > /dev/null"); 
		#open(RES, "$tname.res") || die "can't read clustalw profile alignments.\n";
		#@res = <RES>;
		#close RES;
		#shift @res;
		#shift @res;
		print OUT "$rank $tname $score\n";
		#print OUT join("", @res);
		#print OUT "\n";

		#here: bug fix (remove the unnecessary gaps at the ends of both query and template)
		system("$script_dir/fix_clustal_gaps.pl $tname.res");

		#convert global alginment into pir format
		system("$script_dir/global2pir.pl $tname.res $tname.pir"); 
		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";

	}

	elsif ($alignment_method eq "lobster")
	{
		$query_fas = "$query_dir/$qname.fas"; 
		-f $query_fas || die "can't find query fas file: $query_fas\n"; 
		$temp_fas = "$template_dir/$tname.fas"; 
		-f $temp_fas || die "can't find target fas file: $temp_fas\n"; 
		$temp_lob = "$template_dir/$tname.lob"; 
		-f $temp_lob || die "can't find target lob file: $temp_lob\n"; 

		system("$script_dir/coach.pl $lobster_dir $query_file $query_fas $tname.fasta $temp_fas $temp_lob $tname.res > /dev/null"); 
		#system("$script_dir/muscle.pl $lobster_dir $query_file $query_fas $tname.fasta $temp_fas $temp_lob $tname.res > /dev/null"); 
		#open(RES, "$tname.res") || die "can't read clustalw profile alignments.\n";
		#@res = <RES>;
		#close RES;
		#shift @res;
		#shift @res;
		#print OUT "$rank $tname $score\n";
		#print OUT join("", @res);
		#print OUT "\n";
		print OUT "$rank $tname $score\n";

		#convert global alginment into pir format
		system("$script_dir/global2pir.pl $tname.res $tname.pir"); 
		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";

	}

	elsif ($alignment_method eq "muscle")
	{
		$query_fas = "$query_dir/$qname.fas"; 
		-f $query_fas || die "can't find query fas file: $query_fas\n"; 
		$temp_fas = "$template_dir/$tname.fas"; 
		-f $temp_fas || die "can't find target fas file: $temp_fas\n"; 
		$temp_lob = "$template_dir/$tname.lob"; 
		-f $temp_lob || die "can't find target lob file: $temp_lob\n"; 

		#system("$script_dir/coach.pl $lobster_dir $query_file $query_fas $tname.fasta $temp_fas $temp_lob $tname.res > /dev/null"); 
		system("$script_dir/muscle.pl $lobster_dir $query_file $query_fas $tname.fasta $temp_fas $temp_lob $tname.res > /dev/null"); 
		#open(RES, "$tname.res") || die "can't read clustalw profile alignments.\n";
		#@res = <RES>;
		#close RES;
		#shift @res;
		#shift @res;
		#print OUT "$rank $tname $score\n";
		#print OUT join("", @res);
		#print OUT "\n";
		print OUT "$rank $tname $score\n";

		#convert global alginment into pir format
		system("$script_dir/global2pir.pl $tname.res $tname.pir"); 
		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";

	}

	elsif ($alignment_method eq "palign")
	{
		$query_msa = "$query_dir/$qname.pssm";
		-f $query_msa || die "can't find query msa file: $query_msa\n"; 
		$temp_msa = "$template_dir/$tname.pssm";
		-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
		system("$script_dir/feature_align_prof_palign.pl $palign_dir $query_file $query_msa $tname.fasta $temp_msa $tname.res >/dev/null"); 

		#join local alignments with gap distance less than 5. 
		#system("$script_dir/join_local.pl $query_file $tname.fasta $tname.res 5 $tname.join >/dev/null 2>/dev/null");
		system("$script_dir/join_local.pl $query_file $tname.fasta $tname.res $fr_palign_join_gap_size $tname.join >/dev/null 2>/dev/null");
		#order local alignments
		system("$script_dir/order_local.pl $tname.join $tname.ord");
		#convert local aligment to pir format (set maximum gap size: 20, minimum cover size: 20)
		#system("$script_dir/local2pir.pl $query_file $tname.ord 20 20 $tname.pir"); 
		system("$script_dir/local2pir.pl $query_file $tname.ord $fr_palign_stop_gap_size $fr_palign_min_cover_size $tname.pir"); 

		print OUT "$rank $tname $score\n";

		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";

		`rm $tname.join $tname.ord`; 
	}

	elsif ($alignment_method eq "compass")
	{
		$query_msa = "$query_dir/$qname.aln";
		-f $query_msa || die "can't find query msa file: $query_msa\n"; 

		#this part does not work for multi-threading. cant' generate file shared by many threads on the fly
		#now comment it out. or move it before the alignment generation.
#		$query_aln = "$query_dir/$qname.paln";
#		system("$compass_dir/new_compass/prep_psiblastali -i $query_msa -o $query_aln");
		$temp_msa = "$template_dir/$tname.aln";
		-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
		system("$script_dir/new_compass.pl $compass_dir $query_file $query_msa $tname.fasta $temp_msa $tname.res >/dev/null"); 
		system("$script_dir/local2pir.pl $query_file $tname.res $fr_palign_stop_gap_size $fr_palign_min_cover_size $tname.pir"); 

		if (-f "$tname.pir")
		{
			print OUT "$rank $tname $score\n";

			open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
			@pir = <PIR>;
			close PIR; 
			print OUT join("", @pir);
			print OUT "\n==================================================\n\n";
		}

	}




	elsif ($alignment_method eq "palign_ss")
	{
		$query_msa = "$query_dir/$qname.pssm";
		-f $query_msa || die "can't find query msa file: $query_msa\n"; 
		$temp_msa = "$template_dir/$tname.pssm";
		-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 

		#generate ss file
		system("$script_dir/cm2psipred.pl $query_dir/$qname.cm8a map > $qname.ss");
		system("$script_dir/cm2psipred.pl $template_dir/$tname.set set > $tname.ss");

		system("$script_dir/feature_align_prof_palign_ss.pl $palign_dir $query_file $query_msa $qname.ss $tname.fasta $temp_msa $tname.ss $tname.res >/dev/null"); 

		#join local alignments with gap distance less than 5. 
		#system("$script_dir/join_local.pl $query_file $tname.fasta $tname.res 5 $tname.join >/dev/null 2>/dev/null");
		system("$script_dir/join_local.pl $query_file $tname.fasta $tname.res $fr_palign_join_gap_size $tname.join >/dev/null 2>/dev/null");
		#order local alignments
		system("$script_dir/order_local.pl $tname.join $tname.ord");
		#convert local aligment to pir format (set maximum gap size: 20, minimum cover size: 20)
		#system("$script_dir/local2pir.pl $query_file $tname.ord 20 20 $tname.pir"); 
		system("$script_dir/local2pir.pl $query_file $tname.ord $fr_palign_stop_gap_size $fr_palign_min_cover_size $tname.pir"); 

		print OUT "$rank $tname $score\n";

		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";

		`rm $tname.join $tname.ord $qname.ss $tname.ss`; 
	}
	elsif ($alignment_method eq "tcoffee")
	{
		$query_msa = "$query_dir/$qname.align";
		-f $query_msa || die "can't find query msa file: $query_msa\n"; 
		$temp_msa = "$template_dir/$tname.align";
		-f $temp_msa || die "can't find template msa file: $temp_msa\n"; 
		system("$script_dir/feature_align_prof_tcoffee.pl $script_dir $tcoffee_dir $query_file $query_msa $tname.fasta $temp_msa $tname.res > /dev/null"); 
		#open(RES, "$tname.res") || die "can't read clustalw profile alignments.\n";
		#@res = <RES>;
		#close RES;
		#shift @res;
		#shift @res;

		if (!-f "$tname.res")
		{
			warn "tcoffee fails to generate prof-prof alignment, use clustalw instead.\n";
			system("$script_dir/feature_align_prof_clustalw.pl $script_dir $clustalw_dir $query_file $query_msa $tname.fasta $temp_msa $tname.res > /dev/null"); 
		}

		print OUT "$rank $tname $score\n";
		#print OUT join("", @res);
		#print OUT "\n";

		#here: bug fix (remove the unnecessary gaps at the ends of both query and template)
		system("$script_dir/fix_clustal_gaps.pl $tname.res");

		#convert global alginment into pir format
		system("$script_dir/global2pir.pl $tname.res $tname.pir"); 
		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";

	}

	elsif ($alignment_method eq "spem")
	{
		#copy pdb file to here
		#`cp $atom_dir/$tname.atom.gz .`;	
		#`gunzip $tname.atom.gz`;
		#`mv $tname.atom $tname.pdb`;
		#run spem alignment
		#system("$script_dir/spem_align_prof.pl $script_dir $spem_dir $query_file $tname.pdb $tname.pir");
		system("$script_dir/spem_align_simple.pl $script_dir $spem_dir $query_file $tname.fasta $tname.pir");
		if (-f "$tname.pir")
		{
			open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
			@pir = <PIR>;
			close PIR; 
			print OUT "$rank $tname $score\n";
			print OUT join("", @pir);
			print OUT "\n==================================================\n\n";
		}
		else
		{
			print "fail to generate alignment with $tname. skip.\n";
		}
	}

	elsif ($alignment_method eq "hhsearch")
	{
		#assume query shhm file must exist in the current directory
		`cp $template_dir/$tname.shhm .`;
		system("$script_dir/hhsearch_align.pl $prosys_dir $new_hhsearch_dir $qname.shhm $tname.shhm $query_file $tname.pir");	
		print OUT "$rank $tname $score\n";
		open(PIR, "$tname.pir") || die "can't read $tname.pir\n";
		@pir = <PIR>;
		close PIR; 
		print OUT join("", @pir);
		print OUT "\n==================================================\n\n";
		
	}

	`rm $tname.res 2>/dev/null`; 
	`rm $tname.fasta`; 
	`rm $tname.pir 2>/dev/null`; 
	print "done\n";
}

close OUT; 
