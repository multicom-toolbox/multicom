#!/usr/bin/perl 
###########################################################################
#Do EASIEST HOMOLOGY MODELING, BLAST ONLY, NO COMBINATION
#Date: 6/17/2006.
#Author: Jianlin Cheng
###########################################################################
sub comp_evalue
{
	my ($a, $b) = @_;
	#get format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		$formata = "num";
	}
	elsif ($a =~ /^([\d]*)e(-\d+)$/)
	{
		$formata = "exp";
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
		if ($a_next >= 0)
		{
			die "exponent must be negative: $a\n"; 
		}
	}
	else
	{
		die "evalue format error: $a";	
	}

	if ( $b =~ /^[\d\.]+$/ )
	{
		$formatb = "num";
	}
	elsif ($b =~ /^([\d]*)e(-\d+)$/)
	{
		$formatb = "exp";
		$b_prev = $1;
		$b_next = $2;  
		if ($1 eq "")
		{
			$b_prev = 1; 
		}
		if ($b_next >= 0)
		{
			die "exponent must be negative: $b\n"; 
		}
	}
	else
	{
		die "evalue format error: $b";	
	}
	if ($formata eq "num")
	{
		if ($formatb eq "num")
		{
			return $a <=> $b
		}
		else  #bug here
		{
			#a is bigger
			#return 1; 	
			return $a <=> $b_prev * (10**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			#return -1; 
			return $a_prev * (10 ** $a_next) <=> $b; 
		}
		else
		{
			if ($a_next < $b_next)
			{
				#a is smaller
				return -1; 
			}
			elsif ($a_next > $b_next)
			{
				return 1; 
			}
			else
			{
				return $a_prev <=> $b_prev; 
			}
		}
	}
}
########################End of compare evalue################################

###########################################################################
sub get_exponent 
{
	my $a = $_[0];
	#print "evalue: $a\n";
	$exponent = 0;

	#get the format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		if ($a <= 0) #evalue is 0
		{
			$exponent = -1000; 
		}
		else
		{
			$exponent = 0; 
		}
	}
	elsif ($a =~ /^([\d]*)e(-\d+)$/)
	{
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
		if ($a_next >= 0)
		{
			die "exponent must be negative: $a\n"; 
		}
		$exponent = $a_next; 
	}
	else
	{
		die "evalue format error: $a";	
	}
	return $exponent; 
}
########################End of compare evalue################################

if (@ARGV != 10)
{
	die "need 8 or 9 parameters: script dir, query file(fasta), local alignment file(blast format), min cover size(20), stop gap size(20), max_linker_size(>=0: use advanced combination, <0: use simple combination), evalue_threshold(0:0, -1:e-1, -2:e-2,...), join max size(for advance comb only,e.g. 5), cm_evalue_diff (10), and output file prefix (index as 1, 2, ...).\n";
}

$script_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";

$query_file = shift @ARGV;
$local_align_file = shift @ARGV;

$min_cover_size = shift @ARGV;
$min_cover_size > 0 || die "parameter min_cover_size must be bigger than 0.\n";

$stop_gap_size = shift @ARGV;
#$stop_gap_size >0 || die "parameter stop_gap_size must be bigger than 0.\n";

$max_linker_size = shift @ARGV;
$align_comb_method = "";


$evalue_th = shift @ARGV;

if ($evalue_th =~ /^(-\d+)$/)
{
	#convert it to scientific format
	$evalue_th = "1e$evalue_th";
}
elsif ($evalue_th != 0) #evalue can't be positive
{
	die "evalue threshold must be 0 or negative integer";
}

$align_comb_method = "advanced";

$join_max_size = shift @ARGV;

#$join_max_size = -1; 

$cm_evalue_diff = 0;
$cm_evalue_diff = shift @ARGV;

$output_file = shift @ARGV;


#read query file.
open(QUERY, $query_file) || die "can't read query file: $query_file.\n";
$qname = <QUERY>;
chomp $qname;
if ($qname =~ /^>(.+)$/)
{
	$qname = $1; 
}
else
{
	die "query file is not in fasta format.\n";
}
$qseq = <QUERY>;
chomp $qseq;
close QUERY;

#read local alignment file
open(LOCAL, $local_align_file) || die "can't read local alignment file.\n";
@local = <LOCAL>;
close LOCAL;

$title = shift @local;
@fields = split(/\s+/, $title);
#check if query name matches.
$fields[0] eq $qname || die "query name doesn't match with local alignment file.\n";
$fields[1] == length($qseq) || die "query length doesn't match with local alignment file.\n";

@temps = ();

$min_exponent = 10000; 

$idx  = 1; 
while (@local > 4)
{
	shift @local;
	$info = shift @local;
	$range = shift @local;
	$qseg = shift @local;
	$tseg = shift @local;

	@fields = split(/\s+/, $info);
	$tname = $fields[0];
	$evalue = $fields[3]; 

	$times = 0;
	for($i = 0; $i < @temps; $i++)
	{
		if ($tname eq $temps[$i])
		{
			$times++;
		}
	}
	push @temps, $tname;
	if ($times > 0)
	{
		$tname .= $times;
	}

	@pos = split(/\s+/, $range);
	$qstart = $pos[0];
	$qend = $pos[1];
	$qtest = $qseg;
	chomp $qtest;
	$qtest =~ s/-//g;
	$qtest eq substr($qseq, $qstart - 1, $qend-$qstart+1) || die "local alignment sub string is not found in the query.\n";

	#print "create a temporary file\n";
	#create a temporay file for this template
	open(TMP, ">$output_file.localx") || die "can't create temporay file.\n"; 
	#The format is consistent with palign format.
	print TMP "$title$info$range$qname\n$qseg$tname\n$tseg";
	close TMP;

	#print "convert local to pir\n";

	system("$script_dir/local2pir.pl $query_file $output_file.localx 0 0 $output_file$idx.pir");
	`rm $output_file.localx`; 

	$idx++; 


	#`cp $output_file.pir $output_file`; 
	#`rm $output_file.pir`; 
	#last;
}

