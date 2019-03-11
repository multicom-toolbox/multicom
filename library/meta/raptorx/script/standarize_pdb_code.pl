#!/usr/bin/perl -w
#######################################################################
#Convert the template names of other databases into standard format
#Input: input pir file, output pir file
#Author: Jianlin Cheng
#Date: 12/3/2012
#######################################################################

if (@ARGV != 2)
{
	die "need two parameters: input pir file, output pir file.\n";
}

$in_pir = shift @ARGV;
$out_pir = shift @ARGV;

open(INPIR, "$in_pir") || die "can't read $in_pir.\n";
@inpir = <INPIR>;
close INPIR;

open(OUTPIR, ">$out_pir") || die "can't create $out_pir.\n";
while (@inpir > 4)
{
	$line = shift @inpir;
	if ($line =~ />P/)
	{
		$front = substr($line, 0, 4);
		$end = substr($line, 4);	
		$code = substr($end, 0, 4);
		if (length($end) == 6)
		{
			$code .= substr($end, 5, 1);
		}
		else
		{
			$code .= "A";
		}
		$code = uc($code);
		$line = $front . $code . "\n";
	}
	print OUTPIR $line; 
}

while (@inpir)
{
	$line = shift @inpir;
	print OUTPIR $line; 
}

close OUTPIR;


