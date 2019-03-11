#!/usr/bin/perl -w
########################################################################
#Add structure information(method/resolution) for templates.
#Remove the low resolution redudant templates
#Input: pir alignment file, stx info file, deta resolution, output file
#delta rank: if redudant template has lower resolution than delta, discard it. 
#Assumption: the pir alignment has been sorted by evalue/resolution.
#Author: Jianlin Cheng
#Date: 11/13/2005
########################################################################

if (@ARGV != 4)
{
	die "need 4 parameters: pir alignment file, stx info file, delta resolution(2), output file.\n";
}
$pir_file = shift @ARGV;
$stx_info_file = shift @ARGV;
$delta_reso = shift @ARGV;
$delta_reso > 0 || die "delta resolution must be bigger than 0.\n";
$out_file = shift @ARGV;

#read stx information file
open(INFO, $stx_info_file) || die "can't read stx information file.\n";
%map_reso = ();
%map_match = ();
$map_method = ();
while (<INFO>)
{
	$line = $_;
	chomp $line;
	($code, $reso, $match, $method) = split(/\s+/, $line);
	$map_reso{$code} = $reso;
	$map_match{$code} = $match;
	$map_method{$code} = $method;
}
close INFO;

#read pir alignment file
open(PIR, $pir_file) || die "can't read rank file: $pir_file\n";
@pir = <PIR>;
close PIR;

if (@pir < 9) #less than one alignments
{
	`cp $pir_file $out_file`;
	die "There are less than one alignment in pir file. Stop by making a copy.\n";
}

#get the first alignment
$comm = shift @pir;
$id = shift @pir;
$stx = shift @pir;
$align = shift @pir;
shift @pir;

$new_id = $stx;
chomp $new_id;
@fields = split(/:/, $new_id);
$code = $fields[1];
$reso = $map_reso{$code};
$method = $map_method{$code};
if (!defined $reso || !defined $method)
{
	`cp $pir_file $out_file`;
	print "$reso, $method\n";
	die "Can't find resolution and method for $code. Stop by making a copy.\n";
}


push @temps, {
	comm => $comm,
	id => $id,
	stx => $stx,
	align => $align,
	reso => $reso,
	method => $method
	};




#get the query
$qalign = pop @pir;
$qstx = pop @pir;
$qid = pop @pir;
$qcomm = pop @pir;


if (@pir % 5 != 0)
{
	
	`cp $pir_file $out_file`;
	die "pir file format error. Stop by making a copy.\n";
}

while (@pir)
{
	$comm = shift @pir;
	$id = shift @pir;
	$stx = shift @pir;
	$align = shift @pir;
	shift @pir;

	$new_id = $stx;
	chomp $new_id;
	@fields = split(/:/, $new_id);
	$code = $fields[1];
	$reso = $map_reso{$code};
	$method = $map_method{$code};
	if (!defined $reso || !defined $method)
	{
		`cp $pir_file $out_file`;
		die "Can't find resolution and method for $code. Stop by making a copy.\n";
	}

	#check if it is redundant comparing with previous alignment
	$redundant = 0; 
	for ($i = 0; $i < @temps; $i++)
	{
		$old_align = $temps[$i]{"align"}; 
		if (length($align) != length($old_align))
		{
			`cp $pir_file $out_file`;
			die "alignment length doesn't match. Stop by making a copy.\n";
		}

		$novel = 0; 
		for ($j = 0; $j < length($align); $j++)
		{
			$aa1 = substr($align, $j, 1);
			$aa2 = substr($old_align, $j, 1);
			if ( $aa1 ne "-" && $aa2 eq "-")
			{
				$novel = 1;
				last;
			}
		}
		if ($novel == 0)
		{
			$old_id = $temps[$i]{"stx"};
			chomp $old_id;
			@fields = split(/:/, $old_id);
			$old_code = $fields[1];
			$old_reso = $map_reso{$old_code};

			$redundant = 1; 

			last;
		}

	}

	if ( ($redundant == 1 && $reso - $old_reso <= $delta_reso) || $redundant == 0 )
	{

		push @temps, {
			comm => $comm,
			id => $id,
			stx => $stx,
			align => $align,
			reso => $reso,
			method => $method
			}
		
	}
	else
	{
		print "discard low resolution redundant template: $id\n";
	}
}

#output 
open(OUT, ">$out_file") || die "can't create output file.\n";
for ($i = 0; $i < @temps; $i++)
{
	print OUT $temps[$i]{"comm"};  
	print OUT $temps[$i]{"id"};  
	$method = $temps[$i]{"method"};
	$reso = $temps[$i]{"reso"};
	$stx = $temps[$i]{"stx"};
	@fields = split(/:/, $stx);
	if ($method eq "O")
	{
		$fields[0] = "structureN";
	}
	else
	{
		$fields[0] = "structureX";
	}
	$fields[8] = $reso;
	print OUT join(":", @fields);
	print OUT $temps[$i]{"align"};
	print OUT "\n";
}
print OUT "$qcomm$qid$qstx$qalign";
close OUT;
