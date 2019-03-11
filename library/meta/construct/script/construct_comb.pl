#!/usr/bin/perl -w
###########################################################################
#Combine construction alignments for very hard target such as T0529
#Starting from consruct 0, 1, 2, 3, ..., until the target is almost fully
#aligned. 
#Author: Jianlin Cheng
#Date: 5/10/2010
###########################################################################

if (@ARGV != 3)
{
	die "need 3 parameters: prosys_dir, model dir (full_length),  and output file name\n";
}

$prosys_dir = shift @ARGV;
-d $prosys_dir || die "can't find $prosys_dir.\n";

$model_dir = shift @ARGV;
-d $model_dir || die "can't find $model_dir.\n";

$construct_dir = $model_dir . "/construct";
-d $construct_dir || die "can't find $construct_dir.\n";

$output_file = shift @ARGV;

$min_cover_size = 30; 	
$max_linker_size = 15; 
$join_max_size = 35; 

$count = 10; 

#write a function to identify the longest template fragment separated by less 
#than 11 gaps   

$max_gap = 10; 

$script_dir = "$prosys_dir/script";

$i = 0; 
while ($i < $count)
{
	$construct_file = $construct_dir . "/construct$i.pir";  
	open(PIR, $construct_file) || die "can't open $construct_file.\n";
	@pir = <PIR>;
	close PIR; 

	$t_range = $pir[2];  
	$t_align = $pir[3]; 

	chomp $t_align; 
	chop $t_align;

	#identify the start and end positions of the longest fragment in 
	#template alignment	
	$longest_start = -1; 
	$longest_end = -1; 

	$start = -1; 
	$end = -1; 

	$in_fragment = 0; 
	$gap_count = 0; 

	for ($k = 0; $k < length($t_align); $k++)
	{
		$aa = substr($t_align, $k, 1);
		
		if ($aa ne "-")
		{
			if ($in_fragment == 0)
			{
				$in_fragment = 1;
				$start = $k; 
				$end = $k; 
			}	
			else
			{
				$end = $k; 	
			}
			$gap_count = 0; 	
		}
		else
		{
			$gap_count++; 		
		}

		#check 
		if ($gap_count > $max_gap)
		{
			if ($end - $start > $longest_end - $longest_start)
			{
				$longest_end = $end; 
				$longest_start = $start; 
			}
			$in_fragment = 0; 
		}
		
	}

	#get the template start and end position
	@fields = split(/:/, $t_range); 
	$t_start = $fields[2]; 
	$t_end = $fields[4]; 
	
	$front_count = 0; 	
	for ($k = 0; $k < $longest_start; $k++)
	{
		$aa = substr($t_align, $k, 1);
		if ($aa ne "-")
		{
			$front_count++; 
		}
	}

	$middle_count = 0; 
	for ($k = $longest_start; $k <= $longest_end; $k++)
	{
		$aa = substr($t_align, $k, 1);
		if ($aa ne "-")
		{
			$middle_count++; 
		}
	}

	$t_start += $front_count; 
	$t_end = $t_start + $middle_count - 1;  

	$fields[2] = $t_start; 
	$fields[4] = $t_end; 
	$pir[2] = join(":", @fields);  
	
	#set unwanted regions to -
	@aas = (); 
	for ($k = 0; $k < length($t_align); $k++)
	{
		$aa = substr($t_align, $k, 1);  
		if ($k < $longest_start || $k > $longest_end)
		{
			push @aas, "-";
		}	
		else
		{
			push @aas, $aa; 
		}
	} 
	$t_align = join("", @aas); 

	$pir[3] = "$t_align*\n";

	open(TRIM, ">$construct_file.trim") || die "can't create $construct_file.trim\n";
	print TRIM join("", @pir);
	close TRIM; 


	if ($i == 0)
	{
		`cp $construct_file.trim $output_file`; 
	}
	else
	{

	
	`$script_dir/combine_pir_align_adv_join_v2.pl $script_dir $output_file $construct_file.trim $min_cover_size $max_linker_size $join_max_size $output_file`;
	#`$script_dir/simple_gap_comb.pl $script_dir $output_file $construct_file.trim 0 $output_file >/dev/null`;



	}

	$i++; 
}

#combine with alignments in other directory: hhsearch1.5, compass, spem.

