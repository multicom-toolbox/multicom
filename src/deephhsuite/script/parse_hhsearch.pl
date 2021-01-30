#!/usr/bin/perl -w
##############################################################################################
#Parse HHSearch alignment output file
#Input: hhsearch result file, output local alignment file.
#Output format:
#Line 1: query_name, match_columns(or sequence length), number_of_seqs in query hhm, number of hhm in database
#Line 2: blank
#Following lines are local alignments if available (four lines per entry) and each entry is separated by blank
#line 1: template name, length of template HMM, match prob, e-value, p-value, score, ss_score, number of alignment matched columns
#line 2: query start, query end, template start, template end
#line 3: query sequence
#line 4: template sequence
#Author: Jianlin Cheng
#Date: 10/17/2007
##############################################################################################


if (@ARGV != 2)
{
	die "need two inputs: hhsearch result file, output file.\n";
}

$hhsearch_file = shift @ARGV;

$align_file = shift @ARGV;

open(HHSEARCH, $hhsearch_file) || die "can't read $hhsearch_file.\n";
@hhsearch = <HHSEARCH>;
close HHSEARCH;

open(ALIGN, ">$align_file") || die "can't create $align_file.\n";

$line = shift @hhsearch;
chomp $line;
if ($line =~ /Query\s+(.+)/)
{
	$query_name = $1;
}
else
{
	die "1. hhsearch format error.\n";
}

$line = shift @hhsearch;
chomp $line;
if ($line =~ /Match_columns\s+(\d+)/)
{
	$query_length = $1; 
}

$line = shift @hhsearch;
chomp $line;
if ($line =~ /No_of_seqs\s+(\d+)/)
{
	$query_seq_num = $1;	
}
else
{
	die "2. hhsearch format error.\n";
}

shift @hhsearch;


$line = shift @hhsearch;
chomp $line;

if ($line =~ /Searched_HMMs\s+(\d+)/)
{
	$db_size = $1; 
}
else
{
	die "3. hhsearch format error.\n";
}

shift @hhsearch;
shift @hhsearch;

print ALIGN "$query_name $query_length $query_seq_num $db_size\n\n";

if (@hhsearch < 5)
{
	goto END;
}

shift @hhsearch;

#read the hit list
$line = shift @hhsearch; 
if ($line !~ /No Hit/)
{
	die "4. hhsearch format error.\n";
}

@temp_ids = ();
%temp_names = (); 
%temp_lens = ();
%temp_evas = ();
%query_range = ();
%temp_range = ();

while (@hhsearch)
{
	$line = shift @hhsearch;

	

	if ($line =~ /^\s*\n$/)
	{
		last;
	}
	#remove annotation information (for hhpred only)
	if (length($line) > 35)
	{
		$line = substr($line, 0, 10) . "                         " . substr($line, 35);  
	} 
	
	               # 1.id   2.name  3.prob     4.evalue  pvalue 5.score   6.ss-score  cols  7.qs-qe 8.ts-te  9.length
	#if ($line =~ /\s*(\d+)\s+(\S+)\s+([\d\.]+)\s+(\S+)\s+\S+\s+([\d\.]+)\s+([-\d\.]+)\s+\d+\s+(\S+)\s+(\S+)\s+\((\d+)\)/)
	# special case T0355, hit 1OFDA.
	if ($line =~ /\s*(\d+)\s+(\S+)\s+([\d\.]+)\s+(\S+)\s+\S+\s+([-\d\.]+)\s+([-\d\.]+)\s+\d+\s+(\S+)\s+(\S+)\s*\((\d+)\)/)
	{
		$id = $1; 		
		$temp_name = $2;
		$temp_evalue = $4;
		$temp_len = $9;

		push @temp_ids, $id;

		$temp_names{$id} = $temp_name;
		$temp_lens{$id} = $temp_len;
		$temp_evas{$id} = $temp_evalue;		
		$query_range{$id} = $7;
		$temp_range{$id} = $8; 

	}
	else
	{
		print "$line\n";
		die "5. hhsearch format error.\n";
	}
}

#print "generate alignments: @temp_ids\n";

@table = ();

for ($i = 0; $i < @temp_ids; $i++)
{
	$id = $i+1;
	$line = shift @hhsearch;
#	print "$line";
	if ($line !~ /No $id/)
	{
		die "6. hhsearch format error.\n";
	}
#	print "process template $id\n";

	$temp_name = $temp_names{$id};
	$temp_len = $temp_lens{$id};
	$temp_evalue = $temp_evas{$id};		
	$q_range = $query_range{$id};
	($qstart, $qend) = split(/-/, $q_range);
	$t_range = $temp_range{$id}; 
	($tstart, $tend) = split(/-/, $t_range);
	
	$entry = "$temp_name\t$temp_len";
	$q_align = "";
	$t_align = "";
	#print "$line,$hhsearch[0]";
	while (@hhsearch)
	{
		$line = shift @hhsearch;

		#check if reach the next one.		
		$next_id = $id + 1; 
		if ($line =~ /No $next_id/)
		{
			print "alignment $id is corrupted. skipped.\n";
			@new_set = ();
			push @new_set, $line;
			push @new_set, @hhsearch;
			@hhsearch = @new_set;
			last;
		}
		
	
		chomp $line;
		if ($line =~ /^>(\S+)\s*$/)
		{
			$1 eq $temp_name || die "$line\ntemplate name (id = $id, $1, $temp_name) does not match.\n";	
		}
		if ($line =~ /Probab=([\d\.]+)\s+E-value=(\S+)\s+Score=([-\d\.]+)\s+Aligned_cols=(\d+)\s+Identities=(\S+)%/)
		{
			$prob = $1; 
			$evalue = $2; 
			$evalue =~ s/E/e/g;
			$score = $3;
			$aligned = $4;
			$identity = $5;
		}
		                                   #alignment
		if ($line =~ /Q $query_name\s+\d+\s+(\S+)\s+(\d+)\s+/)
		{
			$q_align .= $1;
			$q_last = $2; 
		}

		if ($line =~ /T $temp_name\s+\d+\s+(\S+)\s+(\d+)\s+/)
		{
			$t_align .= $1;

			$t_last = $2; 

			#check if the entry is finished
			if ($q_last == $qend && $t_last == $tend)
			{
				#entry is done.
				$entry .= "\t$score\t$evalue\t$aligned\t$identity\t$prob\n";
				$entry .= "$qstart\t$qend\t$tstart\t$tend\n";
				$entry .= "$q_align\n";
				$entry .= "$t_align\n";
				push @table, $entry;

				#skip the rest of the entry
				while (@hhsearch)
				{
					$line = shift @hhsearch;
					if ($line =~ /^\s*\n/)
					{
						last;
					}
				}
				shift @hhsearch;
				
				last;
			}
			
		}
		
	}
}

print ALIGN join("\n", @table);	

END:
close ALIGN;

