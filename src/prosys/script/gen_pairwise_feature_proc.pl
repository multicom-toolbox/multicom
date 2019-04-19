#!/usr/bin/perl -w
##############################################################################
#Generate pairwise features for a query against a library (fasta set) 
#for fold recognition. (MULTI-THREAD VERSION)
#Modifided from gen_pairwise_feature.pl
#Input: option file, fasta file(fasta), library fasta file, out file
#query sequence name must not contain "." and white space. 
#	(better just alphanumeric, "_" or "-")
#option file: include path to prosys, pspro, and other alignment tools.
#output file format: each pair has two lines. line 1: pair name line 2: features in svm format
#Author: Jianlin Cheng
#Date: 08/21/2005
###############################################################################
if (@ARGV != 4)
{
	die "need four parameters: option file(option_pairwise), query fasta file(fasta), template library fasta file, output feature file\n"; 
}
$option_file = shift @ARGV; 
$query_file = shift @ARGV; 
$lib_file = shift @ARGV;
$out_file = shift @ARGV;

-f $option_file || die "can't read option file.\n"; 

#read options
$blast_dir = "";
$clustalw_dir = ""; 
$palign_dir = "";
$tcoffee_dir = "";
$hmmer_dir = "";
$prosys_dir = "";
$prc_dir = ""; 
$hhsearch_dir = "";
$lobster_dir = ""; 
$compass_dir = ""; 
$pspro_dir = ""; 
$betapro_dir = ""; 
$cm_seq_dir = ""; 
$template_dir = ""; 
$thread_num = 1;
$query_dir = "generate";
$fr_stx_feature_alignment = "clustalw";
$rm_query = 0;
open(OPTION, $option_file) || die "can't read option file.\n";
@options = <OPTION>;
close OPTION; 
foreach $line (@options)
{
	if ($line =~ /^blast_dir\s*=\s*(\S+)/)
	{
		$blast_dir = $1; 
	}
	if ($line =~ /^clustalw_dir\s*=\s*(\S+)/)
	{
		$clustalw_dir = $1; 
	}
	if ($line =~ /^palign_dir\s*=\s*(\S+)/)
	{
		$palign_dir = $1; 
	}
	if ($line =~ /^tcoffee_dir\s*=\s*(\S+)/)
	{
		$tcoffee_dir = $1; 
	}
	if ($line =~ /^hmmer_dir\s*=\s*(\S+)/)
	{
		$hmmer_dir = $1; 
	}
	if ($line =~ /^prc_dir\s*=\s*(\S+)/)
	{
		$prc_dir = $1; 
	}
	if ($line =~ /^hhsearch_dir\s*=\s*(\S+)/)
	{
		$hhsearch_dir = $1; 
	}
	if ($line =~ /^lobster_dir\s*=\s*(\S+)/)
	{
		$lobster_dir = $1; 
	}
	if ($line =~ /^compass_dir\s*=\s*(\S+)/)
	{
		$compass_dir = $1; 
	}
	if ($line =~ /^prosys_dir\s*=\s*(\S+)/)
	{
		$prosys_dir = $1; 
	}
	if ($line =~ /^pspro_dir\s*=\s*(\S+)/)
	{
		$pspro_dir = $1; 
	}
	if ($line =~ /^betapro_dir\s*=\s*(\S+)/)
	{
		$betapro_dir = $1; 
	}
	if ($line =~ /^cm_seq_dir\s*=\s*(\S+)/)
	{
		$cm_seq_dir = $1; 
	}
	if ($line =~ /^template_dir\s*=\s*(\S+)/)
	{
		$template_dir = $1; 
	}
	if ($line =~ /^atom_dir\s*=\s*(\S+)/)
	{
		$atom_dir = $1; 
	}
	if ($line =~ /^query_dir\s*=\s*(\S+)/)
	{
		$query_dir = $1; 
	}
	if ($line =~ /^thread_num\s*=\s*(\S+)/)
	{
		$thread_num = $1; 
	}
	if ($line =~ /^fr_stx_feature_alignment\s*=\s*(\S+)/)
	{
		$fr_stx_feature_alignment = $1; 
	}
}
if ($fr_stx_feature_alignment ne "clustalw" && $fr_stx_feature_alignment ne "lobster" && $fr_stx_feature_alignment ne "lobster_sel" && $fr_stx_feature_alignment ne "muscle" && $fr_stx_feature_alignment ne "lobster_no_clustalw")
{
	die "alignment method for stx feature must be clustalw, lobster, muscle, or lobster_sel: $fr_stx_feature_alignment\n";
}

#check the existence of these directories 
-d $blast_dir || die "can't find blast dir:$blast_dir.\n";
-d $clustalw_dir || die "can't find clustalw dir.\n";
-d $palign_dir || die "can't find palign dir.\n";
-d $tcoffee_dir || die "can't find tcoffee dir.\n";
-d $hmmer_dir || die "can't find hmmer dir.\n";
-d $hhsearch_dir || die "can't find hhsearch dir.\n";
-d $lobster_dir || die "can't find lobster dir.\n";
-d $prosys_dir || die "can't find prosys dir.\n";
-d $pspro_dir || die "can't find pspro dir.\n";
-d $betapro_dir || die "can't find betapro dir.\n";
-d $cm_seq_dir || die "can't find cm_seq_dir dir.\n";
-d $template_dir || die "can't find template_dir.\n"; 
if (substr($template_dir,0,1) ne "/")
{
	die "template dir must use full path.\n";
}
if ($query_dir ne "generate")
{
	-d $query_dir || die "can't find query_dir.\n";
	if (substr($query_dir,0,1) ne "/")
	{
		die "query dir must use full path.\n";
	}
}
if ($thread_num <= 0)
{
	$thread_num = 1; 
}

#read query file
open(QUERY, $query_file) || die "can't read query file.\n";
$name = <QUERY>;
close QUERY;
if ($name =~ /^>(\S+)/)
{
	$name = $1; 

	#check  if name is valid
	if ($name =~ /\./)
	{
		die "sequence name can't include .\n"; 
	}
}
else
{
	die "query file is not in fasta format.\n"; 
}

$lib_lock = "$atom_dir/_lib_lock";
print "try to get library lock to generate query files and to split FR template library for feature generation (into a loop)...\n"; 
while (1)
{
	if (! -f $lib_lock)
	{
		print "get library lock.\n";
		`touch $lib_lock`; 
		last;
	}
	else
	{
		#block for 5 seconds
		sleep(5);
	}
}
	
if ($query_dir eq "generate")
{
	#create a temporary option file
	$query_dir = "$name-query";
	$full_path = `pwd`;
	chomp $full_path;
	$query_dir = $full_path . "/" . $query_dir;
	#print "fullpath: $full_path";
	#<STDIN>;
	`mkdir $query_dir`; 
	$query_opt = "$name.opt";
	open(QOPT, ">$query_opt") || die "can't create query option file.\n";
	print QOPT join("", @options);
	#set a new query dir
	print QOPT "query_dir=$query_dir\n";
	close QOPT; 

	#generate query related files
	system("$prosys_dir/script/gen_query_files.pl $query_opt $query_file $query_dir");
	#might want to check if all files are generated.

	$rm_query = 1;
}
else
{
	$full_path = `pwd`;
	chomp $full_path;
	$query_opt = $option_file;
}

#generate features
open(LIB, $lib_file) || die "can't read query file.\n";
@fasta = <LIB>;
close LIB;

print "release library lock.\n"; 
`rm $lib_lock`; 

#split template library for threads
$total = @fasta / 2; 
if ($total < 2 * $thread_num)
{
	$thread_num = 1; 
}

$max_num = int($total / $thread_num) + 1; 
$thread_dir = "$name-thread";
for ($i = 0; $i < $thread_num; $i++)
{
	`mkdir $thread_dir$i`; 	
	`cp $query_file $query_opt $thread_dir$i`; 

	open(THREAD, ">$thread_dir$i/lib$i.fasta") || die "can't create template file for thread $i\n";
	#allocate sequences for thread
	for ($j = $i * $max_num; $j < ($i+1) * $max_num && $j < $total; $j++)
	{
		print THREAD $fasta[2*$j];
		print THREAD $fasta[2*$j+1]; 
	}
	close THREAD;
}

#input: working dir, prosys dir, query seq name, query file, query opt name, library file, output file, thread id
sub create_feature
{
	my ($work_dir, $pdir, $qname, $qfile, $qopt, $tfile, $ofile, $id) = @_; 

	#here,  the current directories for other threads and process are changed (global impact)
#	print "work dir=$work_dir\n";
	#don't use cd, it doesn't work, I don't know why
	chdir $work_dir; 
	
	open(OUT, ">$ofile") || die "can't create output feature file for thread $id.\n"; 

	open(LIB, "$tfile") || die "can't read library file for thread $id.\n";
	my @fasta = <LIB>;
	close LIB; 

	while (@fasta)
	{
		my $temp = shift @fasta;
		if ($temp =~ /^>(\S+)/)
		{
			$temp = $1; 

			#check  if name is valid
			if ($temp =~ /\./)
			{
				die "sequence name can't include .\n"; 
			}
		}
		else
		{
			die "fasta file is not in fasta format.\n"; 
		}
		my $seq = shift @fasta;
		print "$temp ";

		if ($temp eq $qname)
		{
			print "query name is the same as template name. Skip!\n";
			next;
		}

		#create a temporary template file
		open(TEMP, ">$temp.fasta") || die "can't create $temp.fasta\n";
		print TEMP ">$temp\n$seq"; 
		close TEMP; 

		#generate pairwise features
		if ($fr_stx_feature_alignment eq "lobster" || $fr_stx_feature_alignment eq "lobster_sel" || $fr_stx_feature_alignment eq "muscle")
		{
			system("$pdir/script/feature_complete_lobster.pl $qfile $temp.fasta $qopt $temp.out >/dev/null 2>/dev/null"); 
		}
		elsif ($fr_stx_feature_alignment eq "lobster_no_clustalw")
		{
			#system("$pdir/script/feature_complete_lobster_no_clustal.pl $qfile $temp.fasta $qopt $temp.out >/dev/null 2>/dev/null"); 
			#system("$pdir/script/feature_complete_lobster_no_clustalw.pl $qfile $temp.fasta $qopt $temp.out"); 
			system("$pdir/script/feature_complete_lobster_no_clustalw.pl $qfile $temp.fasta $qopt $temp.out >/dev/null 2>/dev/null"); 
		}
		else
		{
			system("$pdir/script/feature_complete.pl $qfile $temp.fasta $qopt $temp.out >/dev/null 2>/dev/null"); 
		}
		if (!open(RES, "$temp.out"))
		{
			`rm $temp.fasta`; 
			 print "can't read feature output file for $name vs $temp.\n";
			 next; 
		}
		my $pair_name = <RES>;

		#check the consistency
		my ($pa, $pb) = split(/\s+/, $pair_name);
		<RES>;
		my $feature = <RES>; #numbers separated by space
		close RES;

		if ($pa ne $qname || $pb ne $temp)
		{
			print "pair ids ($qname, $temp) don't match.\n"; 
			`rm $temp.fasta $temp.out`; 
			next; 
		}

		my @attrs = split(/\s+/, $feature); 
		my $size = @attrs;
		#print "feature size = $size\n"; 
		print OUT "#$pair_name";
		#print OUT "#$feature\n";
		#set label to unknown
		print OUT "0";
		for ($i = 1; $i <= $size; $i++)
		{
			print OUT " $i:$attrs[$i-1]"; 
		}
		print OUT "\n"; 

		`rm $temp.fasta $temp.out`; 
	
		#remove the temporary file left by feature_complete.pl
		if (-f "gmon.out")
		{
			`rm gmon.out`; 
		}

	}
	close OUT; 
}

#run treads to generate features
#input: working dir, prosys dir, query seq name, query file, query opt name, library file, output file, thread id

#use Thread; 

$post_process = 0; 

for ($i = 0; $i  < $thread_num; $i++)
{
#	$threads[$i] = new Thread \&create_feature, "$full_path/$thread_dir$i", $prosys_dir, $name, $query_file, $query_opt, "lib$i.fasta", "thread$i.out", $i;
	if ( !defined( $kidpid = fork() ) )
	{
		die "can't create process $i\n";
	}
	elsif ($kidpid == 0)
	{
		&create_feature("$full_path/$thread_dir$i", $prosys_dir, $name, $query_file, $query_opt, "lib$i.fasta", "thread$i.out", $i);
	}
	else
	{
		$thread_ids[$i] = $kidpid;
		#if ($i < $thread_num - 1)
		#{
		#	goto END;
		#}
	}
	
}

#collect results
#wait threads to return
use Fcntl qw (:flock);
if ($i == $thread_num && $post_process == 0)
{
	#print "postprocess: $i\n";
	$post_process = 1; 
	chdir $full_path;
	#`>$out_file`; 
	if ( -f $out_file )
	{
		`rm $out_file`; 
	}
	open(OUT, ">$out_file") || die "can't create output file.\n";
	flock OUT, LOCK_EX;
	for ($i = 0; $i < $thread_num; $i++)
	{
		#$threads[$i]->join;
		if (defined $thread_ids[$i])
		{
			print "wait thread $i ";
			waitpid($thread_ids[$i], 0);
			$thread_ids[$i] = ""; 
			print "done\n";
		}
		if (-f "$full_path/$thread_dir$i/thread$i.out")
		{
			#`cat $full_path/$thread_dir$i/thread$i.out >> $out_file`; 
			open(IN, "$full_path/$thread_dir$i/thread$i.out");
			@in = <IN>;
			close IN;
			print OUT join("",@in);
		}
		else
		{
		   warn "thread $i doesn't generate feature file.\n";
		}

		#remove thread dir
		`rm -r -f $full_path/$thread_dir$i`;
	}
	close OUT;



	#clean current dir
	if ($rm_query == 1)
	{
#		`rm -r -f $query_dir`; 
		`rm $query_opt`; 
	}
}
END:
