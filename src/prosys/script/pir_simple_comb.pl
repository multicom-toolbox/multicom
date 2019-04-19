#!/usr/bin/perl -w
#######################################################################
#Combine a list of pir alignments using simple gap-driven approach
#Input: script_dir, alignmnet_list_file, min_cover_size, stop_gap_size,
#       number_alignments_to_generate, output_prefix(can include full path)
#Author: Jianlin Cheng
#Date: 9/15/2005.
########################################################################
if (@ARGV != 6)
{
	die "need 6 parameters: script_dir, alignment_list_file, min_cover_size(20), stop_gap_size(20), number_alignments_to_generate(5), output_prefix.\n";
}

$script_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";
$align_list = shift @ARGV;
$min_cover_size = shift @ARGV;
$stop_gap_size = shift @ARGV;
$num_comb = shift @ARGV;
$out_prefix = shift @ARGV;

#read all alignment pir files
open(LIST, $align_list) || die "can't read alignment list file: $align_list\n";
@ali_list = <LIST>;
close LIST;
@ali_list >= 1 || die "no alignments in the alignment list.\n";

$num = 1;  #index of  the start alignment 
$real = 1; #index of the composite alignment 
while  ($real <= $num_comb && $num <= @ali_list)
{
	#starting alignment
	$current_align = $ali_list[$num - 1];
	chomp $current_align;

	if (!-f $current_align)
	{
		warn "alignment $current_align doesn't exist, not used.\n";
		$num++;
		next; 
	}

	$out_file = $out_prefix . $real . ".pir";
	`cp $current_align $out_file`; 
	$current_align = $out_file; 

	#combine alignments if necessary
	for ($i = $num; $i < @ali_list; $i++)
	{
		$this_align = $ali_list[$i];
		chomp $this_align; 
		-f $this_align || next; 
		#analyze the current alignment	
		system("$script_dir/analyze_pir_align.pl $current_align > $current_align.state");
		open(STATE, "$current_align.state") || die "can't read $current_align.state\n";
		$bits = <STATE>;
		chomp $bits;
		$stats = <STATE>;
		chomp $stats;
		close STATE;
		`rm $current_align.state`; 
		if ($stats =~ /length=(\d+)\s+covered=(\d+)/)
		{
			$length = $1;
			#$cover = $2; 
		}
		else
		{
			die "fail to analyze the alignment: $current_align\n";
		}

		##################get the biggest gap size in the bit string#################
		length($bits) == $length || die "the length of bit string doesn't match with length of seq.\n";
		$max_gap = 0; 
		$gap_size = 0; 
		for ($j = 0; $j < $length; $j++)
		{
			$bit = substr($bits, $j, 1); 
			if ($bit eq "0")
			{
				$gap_size++; 
				if ($j == $length - 1 && $gap_size > $max_gap)
				{
					$max_gap = $gap_size; 
				}
			}
			else
			{
				if ($gap_size > $max_gap)
				{
					$max_gap = $gap_size; 
				}
				$gap_size = 0; 
			}
		}
		################end of getting the biggest gap size#####################

		if ($max_gap < $stop_gap_size)
		{
			#enough!
			last;
		}

		#combine the current alignment with this  alignment
		#here: current_align will be overwritten.
		system("$script_dir/simple_gap_comb.pl $script_dir $current_align $this_align $min_cover_size $current_align >/dev/null");
	}
	$num++;
	$real++; 
}

$size = @ali_list;
$real--; 
print "total number of templates: $size, total number of composite alignmnets generated: $real\n";

#done!
