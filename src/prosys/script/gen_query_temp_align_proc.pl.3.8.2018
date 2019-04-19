#!/usr/bin/perl -w
##############################################################################
#Generate pairwise alignments between query and each template in 
#template file in parallel 
#Input: option file, query fasta file(fasta), library file (sort30), template list file, out pir file
#query sequence name must not contain "." and white space. 
#	(better just alphanumeric, "_" or "-")
#option file: include path to prosys, pspro, and other alignment tools, stem, hhsearch.
#output file format: pir alignments between query with each template 
#Author: Jianlin Cheng
#Date: 08/21/2005
###############################################################################
if (@ARGV != 5)
{
	die "need five parameters: option file(option_pairwise), query fasta file(fasta), fr library file (sort90), template list file, output pir file\n"; 
}
$option_file = shift @ARGV; 
$query_file = shift @ARGV; 
$lib_file = shift @ARGV;
$list_file = shift @ARGV;
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
	if ($line =~ /^new_hhsearch_dir\s*=\s*(\S+)/)
	{
		$new_hhsearch_dir = $1; 
	}
	if ($line =~ /^spem_dir\s*=\s*(\S+)/)
	{
		$spem_dir = $1; 
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
use Cwd 'abs_path';

-f $lib_file || die "can't find $lib_file.\n";
$lib_file = abs_path($lib_file);
-f $list_file || die "can't find $list_file.\n";

-d $new_hhsearch_dir || die "can't find new hhsearch dir.\n";
-d $spem_dir || die "can't find spem dir.\n";

if (substr($template_dir,0,1) ne "/")
{
	die "template dir must use full path.\n";
}

-d $query_dir || die "can't find query_dir.\n";
$query_dir = abs_path($query_dir);
if (substr($query_dir,0,1) ne "/")
{
	die "query dir must use full path.\n";
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


$full_path = `pwd`;
chomp $full_path;
$query_opt = $option_file;


#generate features
open(LIB, $list_file) || die "can't read selected list file.\n";
@idlist = <LIB>;
close LIB;

#remove title
shift @idlist;

#split  for threads
$total = @idlist; 
if ($total < $thread_num)
{
	$thread_num = 1; 
}

$max_num = int($total / $thread_num) + 1; 
$thread_dir = "$name-thread";
for ($i = 0; $i < $thread_num; $i++)
{
	`mkdir $thread_dir$i`; 	
	`cp $query_file $query_opt $thread_dir$i`; 
	`cp $name.fas $thread_dir$i`;
	`cp $name.shhm $thread_dir$i 2>/dev/null`;

	open(THREAD, ">$thread_dir$i/lib$i.list") || die "can't create template file for thread $i\n";
	print THREAD "Ranked templates for $name, thread$i\n";

	#allocate templates for thread
	for ($j = $i * $max_num; $j < ($i+1) * $max_num && $j < $total; $j++)
	{
		print THREAD $idlist[$j];
	}
	close THREAD;

}

#input: working dir, prosys dir, query seq name, query file, query opt name, library file, output file, thread id
sub create_feature
{
	my ($work_dir, $libfile, $qname, $qfile, $qopt, $tfile, $ofile, $id) = @_; 
	
	chdir $work_dir; 
	
	#generate alignments between query and templates in $tfile.
	system("$prosys_dir/script/fr_gen_align_all.pl $qopt $qfile $libfile $tfile $ofile");

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
		#within the child process
		print "start thread $i\n";
		&create_feature("$full_path/$thread_dir$i", $lib_file, $name, $query_file, $query_opt, "lib$i.list", "thread$i.out", $i);
		goto END;
	}
	else
	{
		$thread_ids[$i] = $kidpid;
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
		   warn "thread $i doesn't generate alignment file.\n";
		}

		#remove thread dir
	}
	close OUT;



	#clean current dir
	if ($rm_query == 1)
	{
		`rm $query_opt`; 
	}
}
END:
#	`rm -r -f $full_path/$thread_dir$i 2>/dev/null`;
