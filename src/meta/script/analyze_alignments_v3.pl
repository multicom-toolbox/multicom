#!/usr/bin/perl -w
##########################################################################################
#Get alignment information for each pir alignment used to generate models
#The information includes: method, top 1 template code, identity, 
#                          coverage, e-value(if available)
#Input parameters: alignment dir, output file
#Author: Jianlin Cheng
#Start date: Feb. 5, 2010
##########################################################################################

if (@ARGV != 2)
{
	die "need two parameters: alignment dir and output file.\n";
}

$alignment_dir = shift @ARGV;
$output_file = shift @ARGV;

-d $alignment_dir || die "can't find alignment dir: $alignment_dir.\n";

opendir(ALIGN, $alignment_dir) || die "can't open $alignment_dir.\n";		
@align_files = readdir(ALIGN);
closedir ALIGN;

%temp2freq = (); 

foreach $file (@align_files)
{
	if ($file !~ /\.pir$/)
	{
		next; 
	}

	$method = "";
	if ($file =~ /meta_(\D+)\d+/)
	{
		$method = $1;
	}
	else
	{
		die "unknown alignment methods.\n";
	}

	$pir_file = $alignment_dir . "/" . $file;
	print "Processing $pir_file\n";
	open(PIR, $pir_file) || die "can't read $pir_file.\n";
	@pir = <PIR>;
	close PIR; 
	
	$qtitle = shift @pir; 
	chomp $qtitle;
	$qtemp = shift @pir; 
	chomp $qtemp;
	
	$qtemp = substr($qtemp, 4);
	
	if (! exists $temp2freq{$qtemp} )
	{
		#avoid double counting
		if ($file !~ /construct/ && $file !~ /star/ && $file !~ /center/ && $file !~ /hstar/ && $file !~ /ap/ && $file !~ /sthread/ && $file !~ /super/)
		{
			$temp2freq{$qtemp} = 1; 
		}
	}	
	else
	{
		#avoid double counting of templates in construct, start, center (5/24/2010)
		#if ($file !~ /construct/ && $file !~ /star/ && $file !~ /center/)
		if ($file !~ /construct/ && $file !~ /star/ && $file !~ /center/ && $file !~ /hstar/ && $file !~ /ap/ && $file !~ /sthread/ && $file !~ /super/)
		{
			$temp2freq{$qtemp}++; 
		}
	
	}
	shift @pir;
	$qalign = shift @pir; 
	chomp $qalign;
	chop $qalign; #remove the last *
	$talign = pop @pir; 
	chomp $talign; 
	chop $talign; #remove the last *
	
	#calculate coverage and identity rate
	$len = length($talign);	
	$coverage = 0;
	$identity = 0; 
	$total = 0; 
	for ($i = 0; $i < $len; $i++)
	{
		$taa = substr($talign, $i, 1); 	
		$qaa = substr($qalign, $i, 1); 
		
		if ($taa ne "-")
		{
			++$total; 
			if ($qaa ne "-")
			{
				++$coverage;
				if ($taa eq $qaa)
				{
					++$identity;
				}
			}
		}	
			
	}

	if ($total != 0)
	{

		$identity /= $total;
		$coverage /= $total;
	}
	else
	{
		warn "$pir_file, sequence length is 0. Skipped\n";
	}

	#parse the query title to get evalue
	@fields = split(/\(/, $qtitle);
	if (@fields > 1)
	{
		$e_info = $fields[1]; 	
		@fields = split(/\s+/, $e_info);
		if (@fields >= 7)
		{
			$evalue = $fields[6]; 
		}
		else
		{
			$evalue = "unknown";
		}
	}
	else
	{
		$evalue = "unknown";
	}

	#truncate numbers
	$identity = int($identity * 1000) / 1000; 
	$coverage = int($coverage * 1000) / 1000; 

	if ($total > 0)
	{

		push @align_info, {
			name => $file, 
			method => $method,
			template => $qtemp,  
			identity => $identity,
			coverage => $coverage,		
			evalue => $evalue
		};

	}

}

#process construct, start, and center alignments
foreach $file (@align_files)
{
	if ($file !~ /\.pir$/)
	{
		next; 
	}

	$pir_file = $alignment_dir . "/" . $file;

	open(PIR, $pir_file) || die "can't read $pir_file.\n";
	@pir = <PIR>;
	close PIR; 
	
	$qtitle = shift @pir; 
	chomp $qtitle;
	$qtemp = shift @pir; 
	chomp $qtemp;
	
	$qtemp = substr($qtemp, 4);
	
	if (! exists $temp2freq{$qtemp} )
	{
		$temp2freq{$qtemp} = 1; 
	}	
}

#sort alignments by identity

#print out the alignment information
$num = @align_info;
@align_info = sort {$b->{"coverage"} <=> $a->{"coverage"}} @align_info; 
@align_info = sort {$b->{"identity"} <=> $a->{"identity"}} @align_info; 
open(OUT, ">$output_file") || die "can't create file $output_file.\n";
printf(OUT "%-25s%-10s%-10s%-5s%-10s%-10s%-10s\n", "Name", "Method", "Temp", "Freq", "Ident", "Cov", "Evalue");
for ($i = 0; $i < $num; $i++)
{
	printf(OUT "%-25s",  $align_info[$i]->{"name"});  		
	printf OUT "%-10s", $align_info[$i]->{"method"};  		
	$temp = $align_info[$i]->{"template"}; 



	$freq = $temp2freq{$temp};	
	#get the frequence of the most frequent template in the file
	$align_file = "$alignment_dir/" . $align_info[$i]->{"name"}; 
	open(PIR, $align_file) || die "can't read $pir_file.\n";
	@pir = <PIR>;
	close PIR; 
	$initial_coverage = $align_info[$i]->{"coverage"}; 

	$talign = pop @pir; 
	chomp $talign; 
	chop $talign; #remove the last *

	while (@pir > 5)
	{
	
		$qtitle = shift @pir; 
		chomp $qtitle;
		$qtemp = shift @pir; 
		chomp $qtemp;
		$qtemp = substr($qtemp, 4);
		shift @pir;
		$qalign = shift @pir;
		chomp $qalign;
		chop $qalign; #remove the last *
		shift @pir;

		if (exists $temp2freq{$qtemp})
		{ 
			if ($temp2freq{$qtemp} > $freq)
			{

				#calculate coverage and identity rate
				$len = length($talign);	
				$coverage = 0;
				$total = 0; 
				for ($ii = 0; $ii < $len; $ii++)
				{
					$taa = substr($talign, $ii, 1); 	
					$qaa = substr($qalign, $ii, 1); 
		
					if ($taa ne "-")
					{
						++$total; 
						if ($qaa ne "-")
						{
							++$coverage;
						}
					}	
			
				}

				if ($total != 0)
				{

					$coverage /= $total;
				}
				else
				{
					$coverage = -1; 
				}



				if ($coverage >= $initial_coverage)
				{
					$freq = $temp2freq{$qtemp}; 
					$temp = $qtemp;
				}
			}
		}
	}
	#printf OUT "%-10s", $align_info[$i]->{"template"};  		
	printf OUT "%-10s", $temp;  		

	printf OUT "%-5s", $freq; 
	printf OUT "%-10s", $align_info[$i]->{"identity"};  		
	printf OUT "%-10s", $align_info[$i]->{"coverage"};  		
	if ($align_info[$i]->{"evalue"} =~ /^\s+$/)
	{
		printf OUT "%-10s\n", "unknown";  		
	}
	else
	{
		printf OUT "%-10s\n", $align_info[$i]->{"evalue"};  		
	}
}

close OUT; 


