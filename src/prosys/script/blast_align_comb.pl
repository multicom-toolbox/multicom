#!/usr/bin/perl -w
###########################################################################
#Combine blast local alignments according gap or evalue
#Input: script dir, query_file(fasta), local_alignment_file(blast format),
#min_cover_size, stop_gap_size, max_linker_size, evalue_threshold,
#and output file.
#Notice 1: if evalue_threshold is 0: which is equivalent to not
#          using redundant templates with lower evalue.
#Notice 2: max_linker_size must be >= 0. However, if is less
#          than zero, it means use SIMPLE combniation instead of ADVANCED.
#Author: Jianlin Cheng
#Date: 9/21/2005.
###########################################################################
#compare evalue
#different format: 0.####, e-####, #e-#### 
#return: -1: less, 0: equal, 1: more
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

if (@ARGV != 8)
{
	die "need 8 parameters: script dir, query file(fasta), local alignment file(blast format), min cover size(20), stop gap size(20), max_linker_size(>=0: use advanced combination, <0: use simple combination), evalue_threshold(0:0, -1:e-1, -2:e-2,...), and output file.\n";
}
$script_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";

$query_file = shift @ARGV;
$local_align_file = shift @ARGV;

$min_cover_size = shift @ARGV;
$min_cover_size > 0 || die "parameter min_cover_size must be bigger than 0.\n";

$stop_gap_size = shift @ARGV;
$stop_gap_size >0 || die "parameter stop_gap_size must be bigger than 0.\n";

$max_linker_size = shift @ARGV;
if ($max_linker_size < 0)
{
	$align_comb_method = "simple";	
}
else
{
	$align_comb_method = "advanced";
}


$evalue_th = shift @ARGV;

#convert evalue
#evalue can be only be 0 or negave integer
if ($evalue_th =~ /^(-\d+)$/)
{
	#convert it to scientific format
	$evalue_th = "1e$evalue_th";
}
elsif ($evalue_th != 0) #evalue can't be positive
{
	die "evalue threshold must be 0 or negative integer";
}

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

#combine alignment file according to evalue and gaps
$first = 0; 
@temps = ();
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

	#check if it is necessary to add index to name to make it uniq. 
	#check if there is same name
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

	#check the consistency with the query.
	@pos = split(/\s+/, $range);
	$qstart = $pos[0];
	$qend = $pos[1];
	$qtest = $qseg;
	chomp $qtest;
	$qtest =~ s/-//g;
	$qtest eq substr($qseq, $qstart - 1, $qend-$qstart+1) || die "local alignment sub string is not found in the query.\n";

	#print "create a temporary file\n";
	#create a temporay file for this template
	open(TMP, ">$output_file.local") || die "can't create temporay file.\n"; 
	#The format is consistent with palign format.
	print TMP "$title$info$range$qname\n$qseg$tname\n$tseg";
	close TMP;

	#print "convert local to pir\n";

	#convert the file into pir format
	#set stop gap size to 0, and min cover size to 0, so that it always to convert.
	system("$script_dir/local2pir.pl $query_file $output_file.local 0 0 $output_file.pir");
	`rm $output_file.local`; 


	#do combination
	if ($first == 0)
	{
		#print "first one: make a copy\n";
		`cp $output_file.pir $output_file`; 
		`rm $output_file.pir`; 
		$first = 1;
		next; 
	}

	if ( &comp_evalue($evalue, $evalue_th) <= 0 )
	{
		#print "combine due to evalue\n";
		#for very significant match, take it, do a simple combination by settting 
		#minimum cover size to 0. 
		system("$script_dir/simple_gap_comb.pl $script_dir $output_file $output_file.pir 0 $output_file >/dev/null");
	}
	elsif ($align_comb_method eq "simple")
	{
		#print "simple combine\n";
		system("$script_dir/simple_gap_comb.pl $script_dir $output_file $output_file.pir $min_cover_size $output_file >/dev/null");
	}
	else 
	{
		#print "advanced combine\n";
		#do the advanced combination
		system("$script_dir/combine_pir_align_adv.pl $script_dir $output_file $output_file.pir $min_cover_size $max_linker_size $output_file");
	}
	`rm $output_file.pir`;

	#check if it needs to stop
	system("$script_dir/analyze_pir_align.pl $output_file > $output_file.ana");
	open(ANA, "$output_file.ana") || die "can't read analysis file of pir alignment.\n";
	<ANA>;
	$len_size = <ANA>;
	close ANA;
	`rm $output_file.ana`; 
	if ($len_size =~ /length=(\d+)\s+covered=(\d+)/)
	{
		$len = $1;
		$cov = $2;
		$gap = $len - $cov;
		if ($gap <= $stop_gap_size)
		{
			
			last;
		}
	}
	else
	{
		die "error in analyzing the combined pir alignment.\n";
	}
}

