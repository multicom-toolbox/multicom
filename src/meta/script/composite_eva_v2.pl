#!/usr/bin/perl -w
#######################################################################################
#Combine multiple complementary score measures to rank models 
#Method 1: add pairwise GDT score and model_eva score together
#Method 2: add pairwise GDT score, model eva score, coverage * identity
#For ab initio models, coverage * identity is set to 0 (to customize later)
#In version 2, for hard cases with ab initio models, identity * coverage is disabled. 
#Author: Jianlin Cheng
#5/10/2012
#######################################################################################

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

$hard = 0;
foreach $record (@dash)
{
	@fields = split(/\s+/, $record);
	if ($fields[1] eq "No" && $fields[2] eq "alignment" && $fields[3] eq "information")
	{
		$hard = 1; 
		last;
	}
	
}

foreach $record (@dash)
{
	#fields: Name(0),Method(1),Temp(2),Freq(3),Ident(4),Cov(5),Evalue(6),max(7),gdt(8),tm(9),qsco(10),mch(11),rank(12),rcla(13),scla(14)
	@fields = split(/\s+/, $record);
	if ($fields[1] eq "No" && $fields[2] eq "alignment" && $fields[3] eq "information")
	{
		#$compo1 = $fields[5] + $fields[8]; 
		$compo1 = $fields[5] + $fields[8] + $fields[4] + $fields[6]; 
		$compo2 = $fields[5] + $fields[8]; 
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
			sclash => $fields[11],
			compo1 => $compo1, 
			compo2 => $compo2 
		}; 
	
	}
	else
	{	
		#$compo1 = $fields[8] + $fields[11]; 
		$compo1 = $fields[8] + $fields[11] + $fields[7] + $fields[9]; 
		if ($hard == 0)
		{
			$compo2 = $fields[8] + $fields[11] + int($fields[4] * $fields[5] * 1000) / 1000; 
		}
		else
		{
			$compo2 = $fields[8] + $fields[11]; 
		}
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
			sclash => $fields[14],
			compo1 => $compo1, 
			compo2 => $compo2 
		}; 
	}

}

@select = sort {$b->{"compo1"} <=> $a->{"compo1"}} @rank;
open(OUT, ">$output_dir/compoa.eva");
printf(OUT "%-25s%-10s%-6s%-6s%-9s%-5s%-6s%-6s%-10s%-6s%-6s%-6s%-6s%-6s%-6s%-6s\n", "Name", "Method", "Comp1", "Comp2", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "mch", "rank", "rcla", "scla");
for ($i = 0; $i < @rank; $i++)
{
	
	printf(OUT "%-25s",  $select[$i]->{"name"});  		
	printf(OUT "%-10s",  $select[$i]->{"method"});  		


	printf(OUT "%-6s",  $select[$i]->{"compo1"});  		
	printf(OUT "%-6s",  $select[$i]->{"compo2"});  		

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
	
	if ($i <= 4)
	{
		$idx = $i + 1; 	

		`cp $model_dir/$select[$i]->{"name"}.pdb $output_dir/compoa_$idx.pdb`; 
		$pir_file = $model_dir . "/" . $select[$i]->{"name"} . ".pir";
		if (-f $pir_file)
		{
			`cp $pir_file $output_dir/compoa_$idx.pir`; 
		}
	}
}
close OUT;

@select = sort {$b->{"compo2"} <=> $a->{"compo2"}} @rank;
open(OUT, ">$output_dir/compob.eva");
printf(OUT "%-25s%-10s%-6s%-6s%-9s%-5s%-6s%-6s%-10s%-6s%-6s%-6s%-6s%-6s%-6s%-6s\n", "Name", "Method", "Comp1", "Comp2", "Temp", "Freq", "Ident", "Cov", "Evalue", "max", "gdt", "tm", "mch", "rank", "rcla", "scla");
for ($i = 0; $i < @rank; $i++)
{
	
	printf(OUT "%-25s",  $select[$i]->{"name"});  		
	printf(OUT "%-10s",  $select[$i]->{"method"});  		


	printf(OUT "%-6s",  $select[$i]->{"compo1"});  		
	printf(OUT "%-6s",  $select[$i]->{"compo2"});  		

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
	
	if ($i <= 4)
	{
		$idx = $i + 1; 

		`cp $model_dir/$select[$i]->{"name"}.pdb $output_dir/compob_$idx.pdb`; 
		$pir_file = $model_dir . "/" . $select[$i]->{"name"} . ".pir";
		if (-f $pir_file)
		{
			`cp $pir_file $output_dir/compob_$idx.pir`; 
		}
	}
}
close OUT;

