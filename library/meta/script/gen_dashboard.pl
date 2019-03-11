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
$meta_eva = $model_dir . "/meta.eva";
open(EVA, $meta_eva) || die "can't read $meta_eva.\n";
@eva = <EVA>;
close EVA; 
shift @eva;

%model2eva = (); 
foreach $record (@eva)
{
	chomp $record;
	@fields = split(/\s+/, $record);
	@fields == 13 || die "the format of $meta_eva is wrong.\n";				
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

#read qscore, tm score, max score, gdt-ts score 
%model2qscore = &get_score("$model_dir/$query_name.q");
%model2gdt = &get_score("$model_dir/$query_name.gdt");
%model2max = &get_score("$model_dir/$query_name.max");
%model2tm = &get_score("$model_dir/$query_name.tm");

#check the size of eva, align, max, qscore

#(keys %model2eva == keys %model2align) && (keys %model2eva == keys %model2qscore) && (keys %model2qscore == keys %model2max) || die "the number of models in eva, align, qscore, max is not equal.\n"; 

(keys %model2eva == keys %model2qscore) && (keys %model2qscore == keys %model2max) || die "the number of models in eva, align, qscore, max is not equal.\n"; 

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
	$mcheck_score = $fields[7]; 
	$ave_rank = $fields[11]; 

	if (exists $model2qscore{$model_name})
	{
		$qscore = $model2qscore{$model_name}; 
		$qscore = int($qscore * 1000) / 1000; 
	}
	else
	{
		die "Q_score is not found for $model_name in $query_name.q.\n";
	}

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


	push @model_info, {
		name => $model_name,
		align => $align_info,  
		mcheck_score => $mcheck_score,  
		gdt => $gdt,
		max => $max,
		tm => $tm,
		qscore => $qscore,
		ave_rank => $ave_rank,
		r_clash => $regular_clash,
		s_clash => $severe_clash
	}

}

#rank all the models by max score
@model_info = sort { $b->{"qscore"} <=> $a->{"qscore"}} @model_info; 
@model_info = sort { $b->{"tm"} <=> $a->{"tm"}} @model_info; 
@model_info = sort { $b->{"gdt"} <=> $a->{"gdt"}} @model_info; 
@model_info = sort { $b->{"mcheck_score"} <=> $a->{"mcheck_score"}} @model_info; 
@model_info = sort { $a->{"ave_rank"} <=> $b->{"ave_rank"}} @model_info; 
@model_info = sort { $a->{"r_clash"} <=> $b->{"r_clash"}} @model_info; 
@model_info = sort { $a->{"s_clash"} <=> $b->{"s_clash"}} @model_info; 
@model_info = sort { $b->{"max"} <=> $a->{"max"}} @model_info; 
$num = @model_info; 
#print out the dashboard
open(OUT, ">$output_file") || die "can't create file $output_file.\n";
printf(OUT "%-20s%-10s%-10s%-5s%-10s%-10s%-10s%-6s%-6s%-6s%-6s%-6s%-6s%-6s%-6s\n", "Name", "Method", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "qsco", "mch", "rank", "rcla", "scla");
for ($i = 0; $i < $num; $i++)
{
	printf(OUT "%-20s",  $model_info[$i]->{"name"});  		
	printf(OUT $model_info[$i]->{"align"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"max"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"gdt"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"tm"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"qscore"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"mcheck_score"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"ave_rank"});  		
	printf(OUT "%-6s",  $model_info[$i]->{"r_clash"});  		
	printf(OUT "%-6s\n",  $model_info[$i]->{"s_clash"});  		
}
close OUT; 




