#!/usr/bin/perl -w
#######################################################################################
#select five models for three groups and convert them into CASP format: 
#no model combination, with refinement
#no model combination, no refinement
#model combination, no  refinement
#Implement MULTICOM-CLUSTER model selection method or MULTICOM model selection method (to do)
#Three level model selection: 
# (1) identify & coverage (easy) (and pairwise score - top pairwise score > ?) 
# (2) template frequency (and pairwise score - top pairwise score > ?)
# (3) pairwise comparison (TBM) (and mcheck score - top mcheck score > ?) 
# (4) ab initio+reference (hard case, ab initio)
#Inputs:model dir, ranked dashboard file, query/target fasta file, 
#       output dir.
#Author: Jianlin Cheng
#Re-design start date: 2/10/2010
##############################################################################

if (@ARGV != 3)
{
	die "need three parameters: model dir, dashboard score file, output dir.\n";
}

$model_dir = shift @ARGV;
-d $model_dir || die "can't find model dir: $model_dir.\n";

$dash_file = shift @ARGV;
-f $dash_file || die "can't find dashboard file: $dash_file.\n";

$output_dir = shift @ARGV;
-d $output_dir || `mkdir $output_dir`; 

#read dashboard file
open(DASH, $dash_file) || die "can't find $dash_file.\n";
@dash = <DASH>;
close DASH; 
shift @dash; 

foreach $record (@dash)
{
	#fields: Name(0),Method(1),Temp(2),Freq(3),Ident(4),Cov(5),Evalue(6),max(7),gdt(8),tm(9),qsco(10),mch(11),rank(12),rcla(13),scla(14)
	@fields = split(/\s+/, $record);
	if ($fields[1] eq "No" && $fields[2] eq "alignment" && $fields[3] eq "information")
	{
		push @rank, {
			name => "$fields[0]",
			method => "ab_initio",
			template => "unknown",
			frequency => 0,
			identity => 0,
			coverage => 0,
			evalue => "unknown",
			max => $fields[4],
			gdt => $fields[5],
			tm => $fields[6],
			qscore => $fields[7],
			mcheck => $fields[8],
			rank => $fields[9],
			rclash => $fields[10],
			sclash => $fields[11]
		}; 
	
	}
	else
	{	
		push @rank, {
			name => "$fields[0]",
			method => $fields[1],
			template => $fields[2],
			frequency => $fields[3],
			identity => $fields[4],
			coverage => $fields[5],
			evalue => $fields[6],
			max => $fields[7],
			gdt => $fields[8],
			tm => $fields[9],
			qscore => $fields[10],
			mcheck => $fields[11],
			rank => $fields[12],
			rclash => $fields[13],
			sclash => $fields[14]
		}; 
	}

}

#sort by different criteria 
@rank = sort {$a->{"rclash"} <=> $b->{"rclash"}} @rank;
@rank = sort {$a->{"sclash"} <=> $b->{"sclash"}} @rank;

@rank = sort {$b->{"coverage"} <=> $a->{"coverage"}} @rank;
#$highest_coverage = $rank[0]->{"coverage"}; 
@rank = sort {$b->{"qscore"} <=> $a->{"qscore"}} @rank;
@rank = sort {$b->{"mcheck"} <=> $a->{"mcheck"}} @rank;
$highest_mcheck = $rank[0]->{"mcheck"};
@rank = sort {$a->{"rank"} <=> $b->{"rank"}} @rank;
#$lowest_rank = $rank[0]->{"rank"}; 
@rank = sort {$b->{"max"} <=> $a->{"max"}} @rank;
@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
$highest_gdt = $rank[0]->{"gdt"}; 
@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;
$highest_freq = $rank[0]->{"frequency"}; 
@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
#$highest_identity = $rank[0]->{"identity"}; 
@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;


#do multi-level model selection
@select = (); 
$identity_thresh = 0.55; 
$coverage_threshold = 0.7; 
#$frequency_threshold = 6; 
#$frequency_threshold = 5; 
$frequency_threshold = 10; 

#$pairwise_diff_th = -0.10; 
$pairwise_diff_th = -0.03; 
#$pairwise_diff_th = -0.013; 
$mcheck_diff_th = -0.20; 
$freq_diff_th = -5; 

@rank = sort {$a->{"rclash"} <=> $b->{"rclash"}} @rank;
@rank = sort {$a->{"sclash"} <=> $b->{"sclash"}} @rank;
@rank = sort {$b->{"mcheck"} <=> $a->{"mcheck"}} @rank;
@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;
@rank = sort {$a->{"rank"} <=> $b->{"rank"}} @rank;
@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;
@rank = sort {$b->{"max"} <=> $a->{"max"}} @rank;
@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;

#select by identity and coverage
$ident_significant = 0;
for ($i =0; $i < @rank; $i++)
{
	if ($rank[$i]->{"identity"} >= 0.38 && $rank[$i]->{"coverage"} >= $coverage_threshold)
	{
		$ident_significant = 1;
	}
	
	if ($rank[$i]->{"identity"} >= $identity_thresh)
	{

		if ($rank[$i]->{"coverage"} >= $coverage_threshold && $rank[$i]->{"gdt"} - $highest_gdt >= $pairwise_diff_th)
		{
			print "Select models by identity... ", $rank[$i]->{"template"}, " ", $rank[$i]->{"identity"}, " ", $rank[$i]->{"gdt"}, " $highest_gdt", "\n";

#temporarily disable it because of the problem of sthread models recently introduced.
			push @select, $rank[$i]; 
		}	
	}
} 

#select by template frequency
if (@select < 10)
{
	@rank = sort {$a->{"rclash"} <=> $b->{"rclash"}} @rank;
	@rank = sort {$a->{"sclash"} <=> $b->{"sclash"}} @rank;
	@rank = sort {$b->{"mcheck"} <=> $a->{"mcheck"}} @rank;
	@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
	@rank = sort {$a->{"rank"} <=> $b->{"rank"}} @rank;
	if ($ident_significant == 1)
	{
		@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
		#@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;
		@rank = sort {$b->{"max"} <=> $a->{"max"}} @rank;
	}
	else
	{
		@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
		#@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;
		@rank = sort {$b->{"max"} <=> $a->{"max"}} @rank;
	}
	@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;

	
	for ($i =0; $i < @rank; $i++)
	{
		#if ($rank[$i]->{"frequency"} >= $frequency_threshold && $rank[$i]->{"gdt"} - $highest_gdt >= $pairwise_diff_th && $rank[$i]->{"frequency"} - $highest_freq >= $freq_diff_th)
		if ($rank[$i]->{"frequency"} >= $frequency_threshold && $rank[$i]->{"gdt"} - $highest_gdt >= $pairwise_diff_th && $rank[$i]->{"frequency"} == $highest_freq)
		{
			print "Select models by template frequency...\n";
			$found = 0;
			foreach $record (@select)
			{
				if ($record->{"name"} eq $rank[$i]->{"name"})
				{
					$found = 1;
					last;
				}
			}			
			if ($found == 0)
			{
				push @select, $rank[$i]; 
			}
		}
	}

}

#select by pairiwise score 
if (@select < 10)
{
	@rank = sort {$a->{"rclash"} <=> $b->{"rclash"}} @rank;
	@rank = sort {$a->{"sclash"} <=> $b->{"sclash"}} @rank;
	@rank = sort {$b->{"mcheck"} <=> $a->{"mcheck"}} @rank;
	@rank = sort {$b->{"tm"} <=> $a->{"tm"}} @rank;
	@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
	@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
	@rank = sort {$a->{"rank"} <=> $b->{"rank"}} @rank;
	@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;
	@rank = sort {$b->{"max"} <=> $a->{"max"}} @rank;
	
	for ($i =0; $i < @rank; $i++)
	{
		if ( ($rank[$i]->{"mcheck"} - $highest_mcheck >= $mcheck_diff_th) && ($rank[$i]->{"gdt"} - $highest_gdt >= -0.1) )
		{
			print "Select models by GDT-TS score and mcheck score...\n";
			$found = 0;
			foreach $record (@select)
			{
				if ($record->{"name"} eq $rank[$i]->{"name"})
				{
					$found = 1;
					last;
				}
			}			
			if ($found == 0)
			{
				push @select, $rank[$i]; 
			}
		}
	}

}



#select by  ranks 
if (@select < 10)
{
	@rank = sort {$a->{"rclash"} <=> $b->{"rclash"}} @rank;
	@rank = sort {$a->{"sclash"} <=> $b->{"sclash"}} @rank;
	@rank = sort {$b->{"mcheck"} <=> $a->{"mcheck"}} @rank;
	@rank = sort {$b->{"max"} <=> $a->{"max"}} @rank;
	@rank = sort {$b->{"identity"} <=> $a->{"identity"}} @rank;
	@rank = sort {$b->{"frequency"} <=> $a->{"frequency"}} @rank;
	@rank = sort {$b->{"gdt"} <=> $a->{"gdt"}} @rank;
	@rank = sort {$a->{"rank"} <=> $b->{"rank"}} @rank;

	for ($i =0; $i < @rank; $i++)
	{
		if ($rank[$i]->{"gdt"} - $highest_gdt >= $pairwise_diff_th)
		{
			print "Select models by rank...\n";
			$found = 0;
			foreach $record (@select)
			{
				if ($record->{"name"} eq $rank[$i]->{"name"})
				{
					$found = 1;
					last;
				}
			}			
			if ($found == 0)
			{
				push @select, $rank[$i]; 
			}
		}
	}

}

open(OUT, ">$output_dir/multi_level.eva");

printf(OUT "%-25s%-10s%-9s%-5s%-6s%-6s%-10s%-6s%-6s%-6s%-6s%-6s%-6s%-6s\n", "Name", "Method", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "mch", "rank", "rcla", "scla");
$idx = 1; 
for ($i = 0; $i < @select; $i++)
{

	printf(OUT "%-25s",  $select[$i]->{"name"});  		
	printf(OUT "%-10s",  $select[$i]->{"method"});  		
	printf(OUT "%-9s",  $select[$i]->{"template"});  		
	printf(OUT "%-5s",  $select[$i]->{"frequency"});  		
	printf(OUT "%-6s",  $select[$i]->{"identity"});  		
	printf(OUT "%-6s",  $select[$i]->{"coverage"});  		
	printf(OUT "%-10s",  $select[$i]->{"evalue"});  		
	printf(OUT "%-6s",  $select[$i]->{"max"});  		
	printf(OUT "%-6s",  $select[$i]->{"gdt"});  		
	printf(OUT "%-6s",  $select[$i]->{"tm"});  		
	printf(OUT "%-6s",  $select[$i]->{"mcheck"});  		
	printf(OUT "%-6s",  $select[$i]->{"rank"});  		
	printf(OUT "%-6s",  $select[$i]->{"rclash"});  		
	printf(OUT "%-6s\n",  $select[$i]->{"sclash"});  		
	
	if ($idx <= 10)
	{

		`cp $model_dir/$select[$i]->{"name"}.pdb $output_dir/select$idx.pdb`; 
		$pir_file = $model_dir . "/" . $select[$i]->{"name"} . ".pir";
		if (-f $pir_file)
		{
			`cp $pir_file $output_dir/select$idx.pir`; 
		}
	}
	$idx++; 
}
close OUT;


