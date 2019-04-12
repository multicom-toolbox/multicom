#!/usr/bin/perl -w
#######################################################################
#generate template files using multiple threads
#1/9/2014
#Jianlin Cheng
#######################################################################
if (@ARGV != 4)
{
	die "need three parameters: option file(option_prep), fasta file(fasta), output dir, thread num\n"; 
}
$option_file = shift @ARGV; 
$fasta_file = shift @ARGV; 
$out_dir = shift @ARGV;
$thread_num = shift @ARGV;

use Cwd 'abs_path';
$option_file = abs_path($option_file);
$fasta_file = abs_path($fasta_file);
$out_dir = abs_path($out_dir);

-d $out_dir || die "can't read $out_dir.\n";

$work_dir = $out_dir;

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^prosys_dir/)
	{
		$other = "";
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

}
-d $prosys_dir || die "can't find $prosys_dir.\n";

#############################
chdir $work_dir;
$full_path = `pwd`;
chomp $full_path;
#############################

open(LIB, $fasta_file) || die "can't read fasta file.\n";
@fasta = <LIB>;
close LIB;


#split template library for threads
$total = @fasta / 2; 
if ($total < 2 * $thread_num)
{
	$thread_num = 1; 
}

$max_num = int($total / $thread_num) + 1; 
$thread_dir = "pthread";
for ($i = 0; $i < $thread_num; $i++)
{
	`mkdir $thread_dir$i`; 	

	open(THREAD, ">$thread_dir$i/lib$i.fasta") || die "can't create template file for thread $i\n";
	#allocate sequences for thread
	for ($j = $i * $max_num; $j < ($i+1) * $max_num && $j < $total; $j++)
	{
		print THREAD $fasta[2*$j];
		print THREAD $fasta[2*$j+1]; 
	}
	close THREAD;
}


#sub gen_temps 
#{

#	my ($gen_program, $t_option_file, $t_fasta_file, $t_out_dir) = @_;
#	`$gen_program $t_option_file $t_fasta_file $t_out_dir`; 	
#}


$post_process = 0; 

for ($i = 0; $i  < $thread_num; $i++)
{
	if ( !defined( $kidpid = fork() ) )
	{
		die "can't create process $i\n";
	}
	elsif ($kidpid == 0)
	{
		#within the child process
		print "start thread $i to generate template profile\n";
		system("$prosys_dir/script/gen_temp_files_original.pl $option_file $work_dir/$thread_dir$i/lib$i.fasta $work_dir/$thread_dir$i");
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
#if there too many files, a direct moving of files will fail. 
			open(LIBFILE, "$work_dir/$thread_dir$i/lib$i.fasta") || die "can't read lib$i.fasta.\n";
			@file_list = <LIBFILE>;
			close LIBFILE;
			while (@file_list)
			{
			        $name = shift @file_list;
			        chomp $name;
			        $name = substr($name,1);
				`mv $work_dir/$thread_dir$i/$name.* $work_dir`; 
			        shift @file_list;
			}

			#`rm $work_dir/$thread_dir$i/lib$i.fasta`; 

			`rm -r $work_dir/$thread_dir$i`; 
		}

		#remove thread dir
	}
}
END:




