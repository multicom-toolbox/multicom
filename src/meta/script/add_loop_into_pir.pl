#!/usr/bin/perl -w

################################
#

if (@ARGV != 4)
{
	die "need four parametres: input pir file, loop length, output pir file, target name.\n";
}

$input_pir_file = shift @ARGV;
$loop_length = shift @ARGV;
$output_pir_file = shift @ARGV;
$target_name = shift @ARGV;

@comments = ();
@titles = ();

@stx_info = ();
#the position of the first residue in the structure file
@stx_starts = ();
#the position of the last residue in the structure file
@stx_ends = ();

@aligns = (); 
#the position of the first non-gap residue in the alignment
@align_starts = ();
#the position of the last non-gap residue in the alignment
@align_ends = (); 

open(PIR, $input_pir_file) || die "can't read $input_pir_file.\n";
@pir = <PIR>;
close PIR;

@pir > 9 || die "There is less than one template. Stop.\n";

$target_align = pop @pir;
$target_stx_info = pop @pir;
$target_tile = pop @pir;
$target_comment = pop @pir;

while (@pir)
{
	$comment = shift @pir;
	push @comments, $comment;

	$title = shift @pir;
	push @titles, $title;

	$stx = shift @pir;
	push @stx_info, $stx;
	@fields = split(/:/, $stx);
	$start = $fields[2];
	$start =~ s/\s+//;
	push @stx_starts, $start;
	$end = $fields[4];
	$end =~ s/\s+//;
	push @stx_ends, $end;

	$align = shift @pir;
	push @aligns, $align;

	$astart = 0;
	$aend = 0; 
	for ($i = 1; $i <= length($align); $i++)
	{
		$letter = substr($align, $i - 1, 1);
		if ($letter eq "*")
		{
			last;
		}
		if ($letter ne "-")
		{
			if ($astart == 0)
			{
				$astart = $i; 
			}
			$aend = $i; 
		}
	}
	push @align_starts, $astart;
	push @align_ends, $aend; 

	shift @pir;
}

#adjust alignments and start/end positions to create loops 

$num_of_aligns = @aligns;

#adjust the position of alignments, starting from the second one
for ($i = 1; $i < $num_of_aligns; $i++)
{
	$astart = $align_starts[$i];
	$aend = $align_ends[$i]; 	
	$align = $aligns[$i]; 
	$title = $titles[$i]; 

	$front_overlap = 0;
	$back_overlap = 0; 
	
	#check the overlap of the front end
	while ($astart < $aend)	
	{
		#check if the aa match any non
		$match = 0;
		for ($j = 0; $j < $i; $j++)
		{
			$talign = $aligns[$j];	
			if (substr($talign, $astart-1, 1) ne "-")
			{
				$match = 1;
				last;
			}
		
		}	
		if ($match == 1)
		{
			$front_overlap++; 
			$astart++; 
		}
		else
		{
			last;
		}
	}

	$front_shrink = 0;
	if ($front_overlap > 0)
	{
		$front_shrink = $front_overlap + $loop_length;
	}

	while ($aend > $astart)	
	{
		#check if the aa match any non
		$match = 0;
		for ($j = 0; $j < $i; $j++)
		{
			$talign = $aligns[$j];	
			if (substr($talign, $aend-1, 1) ne "-")
			{
				$match = 1;
				last;
			}
		
		}	
		if ($match == 1)
		{
			$back_overlap++; 
			$aend--; 
		}
		else
		{
			last;
		}
	}

	$back_shrink = 0;
	if ($back_overlap > 0)
	{
		$back_shrink = $back_overlap + $loop_length;
	}

	#adjust the alignment and start/end position according to shrink number	
	#adjust alignment, aligentment/start/end positions, stx start/end positions
	#check invariants
	#
	$astart = $align_starts[$i];
	$aend = $align_ends[$i]; 	
	$align = $aligns[$i]; 

	$sstart = $stx_starts[$i];
	$send = $stx_ends[$i]; 	

	$stx_front_shrink = 0; 
	for ($j = 0; $j < $front_shrink; $j++)
	{
		if (substr($align, $astart - 1 + $j, 1) ne "-")
		{
			#substr($align, $astart - 1 + $j, 1, "-");
			$align = substr($align, 0, $astart - 1 + $j) . "-" . substr($align, $astart + $j);
			$stx_front_shrink++; 
		}	
	}
	$astart += $front_shrink; 
	$sstart += $stx_front_shrink; 

	$stx_back_shrink = 0; 
	for ($j = 0; $j < $back_shrink; $j++)
	{
		if (substr($align, $aend - 1 - $j, 1) ne "-")
		{
			#substr($align, $aend - 1 - $j, 1, "-");
			$align = substr($align, 0, $aend - 1 - $j) . "-" . substr($align, $aend - $j); 
			$stx_back_shrink++; 
		}	
	}

	$aligns[$i] = $align; 

	$aend -= $back_shrink;
	$send -= $stx_back_shrink;

	$aend > $astart && $send > $sstart || die "The range of $title is inconsisent after adjustment.\n";
	
	$stx = $stx_info[$i];
	@fields = split(/:/, $stx);
	$fields[2] = " $sstart";
	$fields[4] = " $send";
	$stx = join(":", @fields);
	$stx_info[$i] = $stx;
}

@fields = split(/;/, $target_tile);
$target_title = $fields[0] . ";" . "$target_name\n";


#create the new pir file
open(OUT, ">$output_pir_file") || die "can't create $output_pir_file.\n";

for ($i = 0; $i < @aligns; $i++)
{
	print OUT $comments[$i];
	print OUT $titles[$i];
	print OUT $stx_info[$i];
	print OUT $aligns[$i];
	print OUT "\n";
}

print OUT $target_comment;
print OUT $target_title;
print OUT $target_stx_info;
print OUT $target_align;

close OUT; 
