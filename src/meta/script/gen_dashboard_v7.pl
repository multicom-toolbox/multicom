#!/usr/bin/perl -w
################################################################################
#Generate a comprehensive view of all the models in a directory 
#information includes: alignment information (method, template, freq, identity, coverage
#evalue of the top template)
#, model evaluator score, average ranks of
#model evaluator and model energy, max, tm, gdt-ts, q-score. Ab intio models
#do not have alignment information
#Author: Jianlin Cheng
#Date: 2/7/2009
################################################################################

if (@ARGV != 3)
{
	die "need three parameters: model dir, query sequence name, output file.\n";
}

$model_dir = shift @ARGV;
$query_name = shift @ARGV;
$output_file = shift @ARGV;

#read meta.eva
$meta_eva = $model_dir . "/$query_name.eva";
open(EVA, $meta_eva) || die "can't read $meta_eva.\n";
@eva = <EVA>;
close EVA; 
shift @eva;

%model2eva = (); 
foreach $record (@eva)
{
	chomp $record;
	@fields = split(/\s+/, $record);
	@fields == 8 || die "the format of $meta_eva is wrong.\n";				
	$model_name = shift @fields;
	
	#remove the suffix name (.pdb) from the model name
	$pos = rindex($model_name, ".");
	$model_name = substr($model_name, 0, $pos);
		
	$model2eva{$model_name} = join(" ", @fields);
}

#read alignment information 
$align_info = $model_dir . "/$query_name.align";
open(ALIGN, $align_info) || die "can't read $align_info.\n";
@align = <ALIGN>;
close ALIGN;
shift @align;

%model2align = (); 
foreach $record (@align)
{
	chomp $record;
	@fields = split(/\s+/, $record);
	@fields == 7 || die "the format of $align_info is wrong.\n";				
	$model_name = shift @fields;
	
	#remove the suffix name (.pir) from the model name
	$pos = rindex($model_name, ".");
	$model_name = substr($model_name, 0, $pos);
		
	#here, hard coded, assume the first 25 spaces in the alignment info file is
	#used for model name
	#$model2align{$model_name} = join(" ", @fields);
	$model2align{$model_name} = substr($record, 25);
}

#read qscore, tm score, max score, gdt-ts score 
sub get_score
{
	#my $q_score = $model_dir . "/$query_name.q";

	my $score_file = $_[0]; 
	open(SCORE, $score_file) || die "can't read $score_file.\n";
	my @score = <SCORE>;
	close SCORE;
	#remove title and ends
	shift @score;
	shift @score;
	shift @score;
	shift @score;
	pop @score;

	my %model2score = (); 
	
	foreach $record (@score)
	{
		chomp $record;
		my @fields = split(/\s+/, $record);
		@fields == 2 || die "the format of $score_file is wrong.\n";				
		my $model_name = $fields[0];
	
		#remove the suffix name (.pir) from the model name
		my $pos = rindex($model_name, ".");
		$model_name = substr($model_name, 0, $pos);
		$model2score{$model_name} = $fields[1];
	}
	
	return %model2score;
}

#read sbrod score, distance score, and average rank 
sub get_score2
{
	#my $q_score = $model_dir . "/$query_name.q";

	my $score_file = $_[0]; 
	open(SCORE, $score_file) || die "can't read $score_file.\n";
	my @score = <SCORE>;
	close SCORE;

	my %model2score = (); 
	
	foreach $record (@score)
	{
		chomp $record;
		my @fields = split(/\s+/, $record);
		@fields >= 2 || die "the format of $score_file is wrong.\n";				
		my $model_name = $fields[0];
	
		#remove the suffix name (.pir) from the model name
		my $pos = rindex($model_name, ".");
		$model_name = substr($model_name, 0, $pos);
		$model2score{$model_name} = $fields[1];
	}
	
	return %model2score;
}

#get contact precision from drank file
sub get_contact_precision
{
	my $score_file = $_[0]; 
	open(SCORE, $score_file) || die "can't read $score_file.\n";
	my @score = <SCORE>;
	close SCORE;

	my %model2score = (); 
	
	foreach $record (@score)
	{
		chomp $record;
		my @fields = split(/\s+/, $record);
		@fields >= 4 || die "the format of $score_file is wrong.\n";				
		my $model_name = $fields[0];
	
		my $pos = rindex($model_name, ".");
		$model_name = substr($model_name, 0, $pos);
		$model2score{$model_name} = $fields[2];
	}
	
	return %model2score;
}

#get contact recall from drank file
sub get_contact_recall
{
	my $score_file = $_[0]; 
	open(SCORE, $score_file) || die "can't read $score_file.\n";
	my @score = <SCORE>;
	close SCORE;

	my %model2score = (); 
	
	foreach $record (@score)
	{
		chomp $record;
		my @fields = split(/\s+/, $record);
		@fields >= 4 || die "the format of $score_file is wrong.\n";				
		my $model_name = $fields[0];
	
		my $pos = rindex($model_name, ".");
		$model_name = substr($model_name, 0, $pos);
		$model2score{$model_name} = $fields[4];
	}
	
	return %model2score;
}

#read qscore, tm score, max score, gdt-ts score 
%model2gdt = &get_score("$model_dir/$query_name.gdt");
%model2max = &get_score("$model_dir/$query_name.max");
%model2tm = &get_score("$model_dir/$query_name.tm");

#get sbrod score, distance score, and average rank
%model2sbrod = &get_score2("$model_dir/$query_name.sbrod");
%model2drank = &get_score2("$model_dir/$query_name.drank");

$cluster_file = "$model_dir/$query_name.cluster";
if (-f $cluster_file)
{
	%model2cluster = &get_score2($cluster_file);
}

%model2contact = &get_contact_precision("$model_dir/$query_name.drank");
%model2recall = &get_contact_recall("$model_dir/$query_name.drank");
%model2ave = &get_score2("$model_dir/$query_name.ave");

#check the size of eva, align, max, qscore

#(keys %model2eva == keys %model2align) && (keys %model2eva == keys %model2qscore) && (keys %model2qscore == keys %model2max) || die "the number of models in eva, align, qscore, max is not equal.\n"; 

(keys %model2eva == keys %model2gdt) && (keys %model2gdt == keys %model2max) || die "the number of models in eva, align, qscore, max is not equal.\n"; 

opendir(MDIR, $model_dir) || die "can't read $model_dir.\n";
@files = readdir(MDIR);
closedir MDIR;

while (@files)
{
	$file = shift @files; 
	if ($file !~ /\.pdb$/)
	{
		next;
	}

	my $pos = rindex($file, ".");
	$model_name = substr($file, 0, $pos);

	#gather information for each model

	if (exists $model2align{$model_name})
	{
		$align_info = $model2align{$model_name}; 
	}
	else
	{
		warn "Alignment information is not found for $model_name in $query_name.align.\n";
		$align_info = "No alignment information                               ";
	}

	if (exists $model2eva{$model_name})
	{
		$eva_info = $model2eva{$model_name}; 
	}
	else
	{
		die "Eva information is not found for $model_name in meta.eva.\n";
	}

	@fields = split(/\s+/, $eva_info);
	$regular_clash = $fields[5]; 
	$severe_clash = $fields[6]; 

	#the following two scores are ot used. 
	$mcheck_score = 0; 
	$ave_rank = 0; 
	$qscore = 0; 

	if (exists $model2gdt{$model_name})
	{
		$gdt = $model2gdt{$model_name}; 
		$gdt = int($gdt * 1000) / 1000; 
	}
	else
	{
		die "GDT-TS score is not found for $model_name in $query_name.gdt.\n";
	}

	if (exists $model2max{$model_name})
	{
		$max = $model2max{$model_name}; 
		$max = int($max * 1000) / 1000; 
	}
	else
	{
		die "Max score is not found for $model_name in $query_name.max.\n";
	}

	if (exists $model2tm{$model_name})
	{
		$tm = $model2tm{$model_name}; 
		$tm = int($tm * 1000) / 1000; 
	}
	else
	{
		die "Tm score is not found for $model_name in $query_name.tm.\n";
	}

	if (exists $model2sbrod{$model_name})
	{
		$sbrod = $model2sbrod{$model_name}; 
		$sbrod = int($sbrod * 1000) / 1000; 
	}
	else
	{
		die "Sbrod score is not found for $model_name in $query_name.sbrod.\n";
	}

	if (exists $model2drank{$model_name})
	{
		$drank = $model2drank{$model_name}; 
		$drank = int($drank * 1000) / 1000; 
	}
	else
	{
		die "Distance ranking score is not found for $model_name in $query_name.drank.\n";
	}

	if (exists $model2contact{$model_name})
	{
		$contact_precision = $model2contact{$model_name};
		$contact_precision = int($contact_precision * 1000) / 1000; 
	}
	else
	{
		warn "Contact precison score is not found for $model_name in $query_name.drank.\n";
		$contact_precision = 0; 
	}


	if (exists $model2recall{$model_name})
	{
		$contact_recall = $model2recall{$model_name};
		$contact_recall = int($contact_recall * 1000) / 1000; 
	}
	else
	{
		warn "Contact recall score is not found for $model_name in $query_name.drank.\n";
		$contact_recall = 0; 
	}

	if (exists $model2ave{$model_name})
	{
		$ave = $model2ave{$model_name}; 
		$ave = int($ave * 1000) / 1000; 
	}
	else
	{
		die "Average ranking score is not found for $model_name in $query_name.ave.\n";
	}


	if (exists $model2cluster{$model_name})
	{
		$cluster_num = $model2cluster{$model_name};
	}
	else
	{
		warn "Cluster information is not found for $model_name in $query_name.cluster.\n";
		$cluster_num = -1; 
	}


	push @model_info, {
		name => $model_name,
		align => $align_info,  
		mcheck_score => $mcheck_score,  
		gdt => $gdt,
		max => $max,
		tm => $tm,
		qscore => $qscore,
		ave_rank => $ave_rank,
		sbrod => $sbrod,
		drank => $drank,
		ave => $ave,
		r_clash => $regular_clash,
		s_clash => $severe_clash,
		contact => $contact_precision,
		recall => $contact_recall,
		cluster => $cluster_num
	}

}

#rank all the models by max score
@model_info = sort { $b->{"max"} <=> $a->{"max"}} @model_info; 
@model_info = sort { $a->{"r_clash"} <=> $b->{"r_clash"}} @model_info; 
@model_info = sort { $a->{"s_clash"} <=> $b->{"s_clash"}} @model_info; 
@model_info = sort { $b->{"gdt"} <=> $a->{"gdt"}} @model_info; 
@model_info = sort { $b->{"recall"} <=> $a->{"recall"}} @model_info; 
@model_info = sort { $b->{"sbrod"} <=> $a->{"sbrod"}} @model_info; 

#now all the models are ranked by average tm scores
@model_info = sort { $b->{"tm"} <=> $a->{"tm"}} @model_info; 

$num = @model_info; 
#print out the dashboard
open(OUT, ">$output_file") || die "can't create file $output_file.\n";
printf(OUT "%-20s%-10s%-10s%-5s%-10s%-10s%-10s%-6s%-6s%-6s%-6s%-6s%-8s%-8s%-8s%-8s%-8s%-8s\n", "Name", "Method", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "rcla", "scla","sbrod", "drank", "AveRank", "Prec.", "Recall", "Cluster");
for ($i = 0; $i < $num; $i++)
{
	printf(OUT "%-20s",  $model_info[$i]->{"name"});  		
	printf(OUT $model_info[$i]->{"align"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"max"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"gdt"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"tm"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"r_clash"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"s_clash"});  		
	printf(OUT "%-8s",  $model_info[$i]->{"sbrod"});  		
	printf(OUT "%-8s",  $model_info[$i]->{"drank"});  		
	printf(OUT "%-8s",  $model_info[$i]->{"ave"});  		
	printf(OUT "%-8s",  $model_info[$i]->{"contact"});  		
	printf(OUT "%-8s",  $model_info[$i]->{"recall"});  		
	printf(OUT "%-8s\n",  $model_info[$i]->{"cluster"});  		
}
close OUT; 




