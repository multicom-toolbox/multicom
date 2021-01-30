#!/usr/bin/perl -w

if (@ARGV != 6)
{
	die "need six parameters: model cluster script dir, spicker program, casp model dir, fasta file, model scoring file (ave by eva and energy), output dir.\n";
}

use Cwd 'abs_path';

$model_cluster_script_dir = shift @ARGV;
-d $model_cluster_script_dir || die "can't find model cluster script dir.\n";
$model_cluster_script_dir = abs_path($model_cluster_script_dir);

$spicker = shift @ARGV;
-f $spicker || die "can't find spicker program.\n";
$spicker = abs_path($spicker);

$casp_model_dir = shift @ARGV;
-d $casp_model_dir || die "can't find $casp_model_dir";
$casp_model_dir = abs_path($casp_model_dir);

$fasta_file = shift @ARGV;
-f $fasta_file || die "can't find $fasta_file.\n";
$model_score = shift @ARGV;
-f $model_score || die "can't find $model_score.\n";
$output_dir = shift @ARGV;
-d $output_dir || die "can't find $output_dir.\n";

#########################################################################
system("$model_cluster_script_dir/consensus_qa_global.pl $model_cluster_script_dir $spicker $casp_model_dir $model_score $fasta_file $fasta_file.con"); 

#only use full-length models
open(SCORE, $model_score) || die "can't read $model_score.\n";
@fmodels = ();
while (<SCORE>)
{
	$line = $_;
	if ($line =~ /^PFRMAT / || $line =~ /^TARGET / || $line =~ /^MODEL / || $line =~ /^QMODE / || $line =~ /^END/)
	{
		next;
	}
	@fields = split(/\s+/, $line); 
	push @fmodels, $fields[0]; 
}
close SCORE;

$model_score = "$fasta_file.con";
open(SCORE, $model_score) || die "fail to read $fasta_file.con.\n"; 
@nmodels = <SCORE>;
close SCORE;

open(SCORE, ">$model_score");
while (@nmodels)
{
	$line = shift @nmodels;
	if ($line =~ /^PFRMAT / || $line =~ /^TARGET / || $line =~ /^MODEL / || $line =~ /^QMODE / || $line =~ /^END/)
	{
		print SCORE $line;		
		next;
	}
	@fields = split(/\s+/, $line);		
	$found = 0;		
	foreach $entry (@fmodels)
	{
		if ($entry eq $fields[0])
		{
			$found = 1;
			last;
		}
	}
	if ($found == 1)
	{
		print SCORE $line;
	}
}
close SCORE;

#########################################################################

open(FASTA, $fasta_file) || die "can't read $fasta_file.\n";
$name = <FASTA>;
close FASTA;
chomp $name;
$name = substr($name, 1);

$count = 1;
while ($count <= 5)
{
	print "generate model $count...\n";
	`cp $model_score $name.score`;
	if ($count > 1)
	{
		open(SCORE, $model_score);	
		@score = <SCORE>;
		close SCORE;
		
		for ($i = 0; $i < @score; $i++)
		{
			$line = $score[$i];
			if ($line =~ /^PFRMAT / || $line =~ /^TARGET / || $line =~ /^MODEL / || $line =~ /^QMODE / || $line =~ /^END/ || $line =~ /^AUTHOR / || $line =~ /^METHOD /)
			{
				;
			}
			else
			{
				last;
			}
		}
	
		#exchange models
		$cur = $i;
		$tar = $i + $count - 1;
		$tmp = $score[$cur];
		$score[$i] = $score[$tar];
		$score[$tar] = $tmp;
		
		open(SCORE, ">$name.score");
		print SCORE join("", @score);
		close SCORE;
	}

	print "do model combination...\n";

	#system("/home/chengji/casp8/model_cluster/script/stx_model_comb_global.pl /home/chengji/software/tm_score/TMscore_32 $casp_model_dir $name.score $fasta_file $output_dir/$name.pir 3.5 0.8 0.5");
	system("/home/chengji/casp8/model_cluster/script/stx_model_comb_global.pl /home/chengji/software/tm_score/TMscore_32 $casp_model_dir $name.score $fasta_file $output_dir/$name.pir 4 0.8 0.5");

	open(PIR, "$output_dir/$name.pir") || die "can't read $output_dir/$name.pir\n";
	@pir = <PIR>;
	close PIR;
	$length = 80;
	$gdt = 0.5;
	
	while (@pir < 10)
	{
		print "Less than two templates, do local model combination...\n";
		#system("/home/chengji/casp8/model_cluster/script/stx_model_comb.pl /home/chengji/software/tm_score/TMscore_32 $casp_model_dir $name.score $fasta_file $output_dir/$name.pir 2.5 $length $gdt");
		system("/home/chengji/casp8/model_cluster/script/stx_model_comb.pl /home/chengji/software/tm_score/TMscore_32 $casp_model_dir $name.score $fasta_file $output_dir/$name.pir 3 $length $gdt");

		open(PIR, "$output_dir/$name.pir") || die "can't read $output_dir/$name.pir\n";
		@pir = <PIR>;
		close PIR;

		$length -= 5;
		$gdt -= 0.02;
		if ($length <= 0 || $gdt <= 0)
		{
			print "not able to get a local alignment.\n";
			last;
		}
	}

	print "generate model...\n";
	system("/home/chengji/casp8/model_cluster/script/pir2ts_energy.pl /home/chengji/software/prosys/modeller7v7/ $casp_model_dir $output_dir $output_dir/$name.pir 9");

		

	`mv $output_dir/$name.pir $output_dir/$name-$count.pir`;
	`mv $output_dir/$name.pdb $output_dir/$name-$count.pdb`;
	
	#using scwrl (disable scwrl)
	#system("/home/chengji/software/scwrl/scwrl3 -i $output_dir/$name-$count.pdb -o $output_dir/$name-$count-s.pdb >/dev/null");

	#clash check
	system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $output_dir/$name-$count.pdb > $output_dir/clash$count.txt"); 
	system("/home/chengji/casp8/model_cluster/script/pdb2casp.pl $output_dir/$name-$count.pdb $count $name $output_dir/casp$count.pdb");

	$count++;

	`rm $name.score`;
}




