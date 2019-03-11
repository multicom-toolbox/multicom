#!/usr/bin/perl -w
##############################################################################################
#Parse compass alignment output file
#Input: compass result file, output local alignment file.
#Output format:
#Line 1: query_name, match_columns(or sequence length), number_of_seqs in query hhm, number of hhm in database
#Line 2: blank
#Following lines are local alignments if available (four lines per entry) and each entry is separated by blank
#line 1: template name, length of template HMM, match prob, e-value, p-value, score, ss_score, number of alignment matched columns
#line 2: query start, query end, template start, template end
#line 3: query sequence
#line 4: template sequence
#Author: Jianlin Cheng
#Date: 1/1/2008
##############################################################################################


if (@ARGV != 2)
{
	die "need two inputs: compass result file, output file.\n";
}

$compass_file = shift @ARGV;

$align_file = shift @ARGV;

open(COMPASS, $compass_file) || die "can't read $compass_file.\n";
@com = <COMPASS>;
close COMPASS;

$qname = "";
while (@com)
{
	$line = shift @com;
	if ($line =~ /^Query= (.+)\./)
	{
		$qname = $1;
	}
	if ($line =~ /^Profiles producing significant alignments:/ )
	{
		$idx = 0;
		@rank = ();
		@align = ();
		
		while (@com)
		{
			$line = shift @com;
			if ($line =~ /^\s+$/)
			{
				last;
			}	
			chomp $line;
			($path, $score, $evalue) = split(/\s+/, $line);

			if ($path =~ /^\//)
			{
				$idx++;
				#get template id
				$pos = rindex($path, "/");
				$tname = substr($path, $pos+1, 5);
				push @rank, "$idx\t$tname\t$evalue\t$score";
			}
			else
			{
				die "format error: $line\n";
			}
		}

		$line = shift @com;
#		print $line;
		$first = 0;
		while (@com)
		{
			$line = shift @com;
			if ($first == 0)
			{
				$first = 1;
				$line =~ /^Subject= \// || die "$line: alignment is not found.\n";
			}
			if ($line =~ /^Parameters:/)
			{
				last;
			}
			push @align, $line;
		}	

	}

}

print "parse alignments...\n";

#parse alignments
@table = ();

while (@align)
{
	$line = shift @align;		
	chomp $line;
	if ($line =~ /^Subject= .+\/(.+)\.al/)
	{
		$tname = $1;
	}
	else
	{
		die "$line format error.\n";
	}
	$line = shift @align;
	chomp $line;
	if ($line =~ /^length=(\d+)\s+/)
	{
		$length = $1;
	}
	else
	{
		die "$line format error.\n";
	}
	$line = shift @align;
	chomp $line;
	if ($line =~ /^Smith-Waterman score = (\d+)\s+Evalue = (.+)/)
	{
		$score = $1;
		$evalue = $2;
	}
	else
	{
		die "$line format error.\n";
	}

	shift @align;

	$first = 0;
	$qalign = "";
	$talign = "";
	while (@align)
	{
		$line = shift @align;

		if ($line =~ /^Subject=/)
		{
			#push back and start it over
			@tmp = ();
			push @tmp, $line;
			push @tmp, @align;
			@align = @tmp;
			last;
		}
		chomp $line;
		if ($first == 0)
		{
			$first = 1;
			($name, $qstart, $qsegment) = split(/\s+/, $line);
			$name eq $qname || die "query name does not match.\n";
			$qsegment =~ s/=/-/g;
			$qsegment =~ s/~/-/g;
			$qalign .= $qsegment;

			shift @align;
			shift @align;
			shift @align;
			$line = shift @align;
			chomp $line;

			($name, $tstart, $tsegment) = split(/\s+/, $line);
			$tsegment =~ s/=/-/g;
			$tsegment =~ s/~/-/g;
			$talign .= $tsegment;
			shift @align;
			shift @align;
		}
		else
		{
			($name, $qsegment) = split(/\s+/, $line);
			$name eq $qname || die "query name does not match.\n";
			$qsegment =~ s/=/-/g;
			$qsegment =~ s/~/-/g;
			$qalign .= $qsegment;

			shift @align;
			shift @align;
			shift @align;
			$line = shift @align;
			chomp $line;

			($name, $tsegment) = split(/\s+/, $line);
			$tsegment =~ s/=/-/g;
			$tsegment =~ s/~/-/g;
			$talign .= $tsegment;
			shift @align;
			shift @align;
		
		}
	}
	#get the end positions
	$qalign1 = $qalign;
	$qalign1 =~ s/-//g;
	$qend = $qstart + length($qalign1) - 1;

	$talign1 = $talign;
	$talign1 =~ s/-//g;
	$tend = $tstart + length($talign1) - 1;

	$qalign = uc($qalign);
	$talign = uc($talign);

	push @table, "$tname\t$length\t$score\t$evalue\n$qstart\t$qend\t$tstart\t$tend\n$qalign\n$talign\n";

}

open(ALIGN, ">$align_file") || die "can't create $align_file.\n";
print ALIGN "$qname\n\n";
print ALIGN join("\n", @table);
close ALIGN;

