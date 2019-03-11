#!/usr/bin/perl -w
#######################################################################
#score predicted 3D models (cm, fr, and ab)
#Input: option file, target_fasta_file, input / output_dir
#output will be name.score
#Including the following scores: 
#model_name, method, top_template name, coverage, identity,
#blast-evalue, svm_score, hhs score, compress score, ssm score
#ssa match score, clashes, model check score, model energy score
#Author: Jianlin Cheng
#Date: 1/17/2008
#######################################################################
if (@ARGV != 3)
{
	die "need three parameters: option file, target fasta file, input/output dir.\n";
}

$option_file = shift @ARGV;
$fasta_file = shift @ARGV;
$work_dir = shift @ARGV; 


use Cwd 'abs_path';
$fasta_file = abs_path($fasta_file);
$work_dir = abs_path($work_dir);

-d $work_dir || die "can't read $work_dir.\n";

$thread_num = 1;

#read option file
open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
	$line = $_; 
	chomp $line;
	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^model_check_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$model_check_dir = $value; 
	}

	if ($line =~ /^model_energy_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$model_energy_dir = $value; 
	}

	if ($line =~ /^betacon_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$betacon_dir = $value; 
	}

	if ($line =~ /^pspro_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$pspro_dir = $value; 
	}

	if ($line =~ /^betapro_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$betapro_dir = $value; 
	}

	if ($line =~ /^thread_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$thread_num = $value; 
	}

}
-d $prosys_dir || die "can't find $pspro_dir.\n";
-d $model_check_dir || die "can't find $model_check_dir.\n";
-d $model_energy_dir || die "can't find $model_energy_dir.\n";
-d $betacon_dir || die "can't find $betacon_dir.\n";
-d $pspro_dir || die "can't find $pspro_dir.\n";
-d $betapro_dir || die "can't find $betapro_dir.\n";

#read fasta file
open(FASTA, $fasta_file) || die "can't read $fasta_file\n";
$name = <FASTA>;
chomp $name;
$name = substr($name, 1);
$seq = <FASTA>;
chomp $seq;
close FASTA;

-d $work_dir || die "can't find $work_dir.\n"; 


opendir(WORK, $work_dir) || die "can't open $work_dir.\n";
@files = readdir WORK;
closedir WORK;

chdir $work_dir;

$full_path = `pwd`;
chomp $full_path;

`cp $fasta_file $name.FASTA`;

print "generate features for model energy...\n";
system("$model_energy_dir/script/generate_feature.pl $model_energy_dir $pspro_dir $betapro_dir $name.FASTA $name.pxml >/dev/null 2>/dev/null");

print "evaluate models...\n";
@files = sort @files;

@pdb_files = ();
while (@files)
{
	$file = shift @files;
	$file = abs_path($file);
	if ($file =~ /\.pdb$/)
	{
		push @pdb_files, $file;
	}
}

$total = @pdb_files;


if ($total < 2 * $thread_num)
{
	$thread_num = 1;
}

$max_num = int($total / $thread_num) + 1;
$thread_dir = "$name-energy";
for ($i = 0; $i < $thread_num; $i++)
{
	`mkdir $thread_dir$i`;
	open(THREAD, ">$thread_dir$i/lib$i.list");
	for ($j = $i * $max_num; $j < ($i+1) * $max_num && $j < $total; $j++)
	{
		print THREAD "$pdb_files[$j]\n";
	}
	close THREAD;
}

sub energy_model
{

	my ($dest_dir, $model_energy_dir, $pxml_file, $my_list) = @_;
	chdir $dest_dir;
	open(LIST, $my_list) || die "can't open $my_list.\n";
	my @files = <LIST>;
	open(RES, ">$my_list.energy");
	foreach my $file (@files)
	{
		chomp $file;
		my $out = "";

		if ($file =~ /\.pdb$/)
		{
			$out = `$model_energy_dir/script/energy_feature.pl $model_energy_dir $pxml_file $file`;
		}
		else
		{
			next;
		}
		if (!defined $out)
		{
			next;
		}
	
		if ($out !~ /\n/)
		{
			$out .= "\n";
		}

		my @lines = split(/\n+/, $out);

		my $bfound = 0; 

		while (@lines)
		{
			$line = shift @lines;
	
			if ($line =~ /backbone energy/)
			{
				my ($title, $value) = split(/: /, $line);
				if ($value ne "nan")
				{
				#	push @eva_models, $model_name;
				#	push @eva_scores, $value;  
				}

			}
	
			if ($line =~ /total energy/)
			{
				my ($title, $value) = split(/: /, $line);
				if ($value ne "nan")
				{
					print "$file $value\n";   
					$idx = rindex($file, "/");
					$id = substr($file, $idx+1);
					print RES "$id $value\n"; 
				}
				$bfound = 1; 
			}

		}
	}
	close RES;
}


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
		print "start thread $i\n";
#		print "$full_path/$thread_dir$i, $model_energy_dir, $name.pxml lib$i.list \n";
		my $pxml_file = abs_path("$name.pxml"); 
		&energy_model("$full_path/$thread_dir$i", $model_energy_dir, $pxml_file, "lib$i.list");
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

	`>$name.energy`;

	for ($i = 0; $i < $thread_num; $i++)
	{
		#$threads[$i]->join;
		if (defined $thread_ids[$i])
		{
			print "wait thread $i ";
			waitpid($thread_ids[$i], 0);
			$thread_ids[$i] = ""; 
			print "done\n";
			`cat $full_path/$thread_dir$i/lib$i.list.energy >> $name.energy`;
		}

		#remove thread dir
	}

}
END:




