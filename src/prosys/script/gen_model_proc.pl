#!/usr/bin/perl -w
##############################################################################
#Generate structure model from pir files using multiple threads
#Author: Jianlin Cheng
#Date: 08/21/2005
###############################################################################
if (@ARGV != 8)
{
	die "need eight parameters: prosys dir, modeller dir, atom dir, query_dir (also is output fie), list of pir files in a file, num of models to simulate, number of threads, query_name\n"; 
}

$prosys_dir = shift @ARGV;
$modeller_dir = shift @ARGV; 
$atom_dir = shift @ARGV;
$query_dir = shift @ARGV; 
$pir_list_file = shift @ARGV;
$num_model_simulate = shift @ARGV;
$thread_num = shift @ARGV;
$query_name = shift @ARGV;

-d $prosys_dir || die "can't find modeller dir:$prosys_dir.\n";
-d $modeller_dir || die "can't find modeller dir:$modeller_dir.\n";
-d $atom_dir || die "can't find $atom_dir dir.\n";
-d $query_dir || die "can't find $query_dir.\n";
-f $pir_list_file || die "can't find $pir_list_file.\n";
use Cwd 'abs_path';
$pir_list_file = abs_path($pir_list_file);

if ($thread_num <= 0)
{
	$thread_num = 1; 
}

$full_path = `pwd`;
chomp $full_path;


#generate features
open(LIB, $pir_list_file) || die "can't read selected list file.\n";
@idlist = <LIB>;
close LIB;

$total = @idlist; 
if ($total < 2 * $thread_num)
{
	$thread_num = 1; 
}

$max_num = int($total / $thread_num) + 1; 
$thread_dir = "$query_name-thread";
for ($i = 0; $i < $thread_num; $i++)
{
	`mkdir $thread_dir$i`; 	

	open(THREAD, ">$thread_dir$i/lib$i.list") || die "can't create template file for thread $i\n";

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
	my ($work_dir, $modeller_dir, $atom_dir, $query_dir, $my_list, $num_model_simulate, $query_name) = @_; 
	
	chdir $work_dir; 

	open(LIST, $my_list) || die "can't open $my_list.\n";
	@files = <LIST>;
	foreach $pir_file (@files)
	{
		chomp $pir_file;
		#print "cp $query_dir/$pir_file $work_dir\n";	
		`cp $query_dir/$pir_file $work_dir`;	
		my $idx = rindex($pir_file, ".");
		if ($idx > 0)
		{
			$prefix = substr($pir_file, 0, $idx);
		}
		else
		{
			$prefix = $pir_file
		}
		#generate alignments between query and templates in $tfile.
		system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $work_dir $pir_file $num_model_simulate 2>/dev/null");
		$model_name = "$query_name.pdb"; 

		if (-f $model_name)
		{
			`mv $model_name $query_dir/$prefix.pdb`;
			print "model $prefix.pdb is generated.\n"; 
		}
		`rm *.D00000* *.V9999* 2>/dev/null`;
	}

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
		&create_feature("$full_path/$thread_dir$i", $modeller_dir, $atom_dir, $query_dir, "lib$i.list", $num_model_simulate, $query_name);
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

		#remove thread dir
	}

}
END:
#	`rm -r -f $full_path/$thread_dir$i`;
