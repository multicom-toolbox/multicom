#!/usr/bin/perl -w
##############################################################
#analyze cm pir format alignments for one query
#to report covered and uncovered bit string (01...)
#0: uncovered, 1: covered.
#Input: alignment file, output string.
#Author: Jianlin Cheng
#Date: 8/30/2005
###############################################################
if (@ARGV != 1)
{
	die "need 1 parameter: input pir alignment file for one query\n";
}
$pir_file = shift @ARGV;
open(PIR, $pir_file) || die "can't read pir file.\n";
@pir = <PIR>;
close PIR; 

#the last four lines are query
$qseq = pop @pir;
pop @pir;
#skip title
pop @pir;
pop @pir; 

chomp $qseq; 
#chop the last *
chop $qseq; 
$length = length($qseq);
@flags = ();
for ($i = 0; $i < $length; $i++)
{
	if ( substr($qseq, $i, 1) ne "-" ) 
	{
		push @flags, 0;  
	}
}

$cover = 0;
$size = @flags; 
while (@pir)
{
	shift @pir;
	shift @pir; 
	shift @pir; 
	$tseq = shift @pir;
	chomp $tseq; 
	#chop the last *
	chop $tseq; 
	$idx = 0;
	for ($i = 0; $i < $length; $i++)
	{
		if ( substr($qseq, $i, 1) ne "-")
		{
			if (substr($tseq, $i, 1) ne "-" && $flags[$idx] == 0) 
			{
				$flags[$idx] = 1;   
				$cover++; 
			}
			$idx++;
		}
	}

	shift @pir; 
}

print join("", @flags), "\n";
print "length=$size covered=$cover\n";

