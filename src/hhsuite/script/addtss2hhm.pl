#!/usr/bin/perl -w
##################################################################
#Add true secondary structure into HHSearch HMM model
#Input: 12-line seq format (line 7 is SS), HMM model name
#Output: to std: a new HMM with SS info.
#Author: Jianlin Cheng
#Date: 10/10/2007
##################################################################

if (@ARGV != 2)
{
	die "need two parameters: 12-line seq file, hhsearch HMM model file.\n";
}

$seq_file = shift @ARGV;
$hhm_file = shift @ARGV;

open(SEQ, $seq_file) || die "can't read $seq_file.\n";
<SEQ>;
<SEQ>;
<SEQ>;
<SEQ>;
<SEQ>;
<SEQ>;
$ss = <SEQ>;
chomp $ss;
close SEQ;

#remove blank
$ss =~ s/ //g;
#replace . with C.
$ss =~ s/\./C/g;

open(HHM, $hhm_file) || die "can't read $hhm_file.\n";
@hhm = <HHM>;
close HHM;

while (@hhm)
{
	$line = shift @hhm;
	print $line;
	if ($line =~ /^SEQ/)
	{
		#get length of secondary structure	
		$len = length($ss);			

		print ">ss_dssp\n";
		for ($i = 1; $i <= $len; $i++)
		{
			print substr($ss, $i-1, 1);
			if ($i % 100 == 0 || $i == $len)
			{
				print "\n";
			}
		}

		print ">ss_pred\n";
		$ss =~ s/[GI]/H/g;
		$ss =~ s/B/E/g;
		$ss =~ s/[TS]/C/g;
		for ($i = 1; $i <= $len; $i++)
		{
			print substr($ss, $i-1, 1);
			if ($i % 100 == 0 || $i == $len)
			{
				print "\n";
			}
		}

		print ">ss_conf\n";
		for ($i = 1; $i <= $len; $i++)
		{
			print "9";
			if ($i % 100 == 0 || $i == $len)
			{
				print "\n";
			}
		}

	}	
}

