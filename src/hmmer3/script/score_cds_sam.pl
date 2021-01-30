#!/usr/bin/perl -w
###############################################################
#align each sequence in a dataset to sam models
#report the top models (ranked by e-value)
#Inputs: input sequence file, model dir, output file
#Author: Jianlin Cheng
#Date: 1/25/2008
############################################################### 
#return: -1: less, 0: equal, 1: more
sub comp_evalue
{
	my ($a, $b) = @_;
	#get format of the evalue
	if ( $a =~ /^[\d\.]+$/ )
	{
		$formata = "num";
	}
	elsif ($a =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formata = "exp";
		$a_prev = $1;
		$a_next = $2;  
		if ($1 eq "")
		{
			$a_prev = 1; 
		}
	#	if ($a_next > 0)
#		{
	#		die "exponent must be negative or 0: $a\n"; 
#		}
	}
	else
	{
		die "evalue format error: $a";	
	}

	if ( $b =~ /^[\d\.]+$/ )
	{
		$formatb = "num";
	}
	elsif ($b =~ /^([\.\d]*)e([-\+]\d+)$/)
	{
		$formatb = "exp";
		$b_prev = $1;
		$b_next = $2;  
		if ($1 eq "")
		{
			$b_prev = 1; 
		}
	#	if ($b_next > 0)
	#	{
	#		die "exponent must be negative or 0: $b\n"; 
	#	}
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
			#return $a <=> $b_prev * (10**$b_next); 
			return $a <=> $b_prev * (2.72**$b_next); 
		}
	}
	else
	{
		if ($formatb eq "num")
		{
			#a is smaller
			#return -1; 
			#return $a_prev * (10 ** $a_next) <=> $b; 
			return $a_prev * (2.72 ** $a_next) <=> $b; 
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
if (@ARGV != 2)
{
	die "need two parameters: input sequence file (FASTA foramt), family HMM model dir\n";
}

$seq_file = shift @ARGV;
$model_dir = shift @ARGV;

use Cwd 'abs_path';
$model_dir = abs_path($model_dir);

$sam = "/data/marc/sam3.5.i686-linux/bin/hmmscore  ";

opendir(MODEL, $model_dir) || die "can't read $model_dir.\n";
@files = readdir MODEL;
closedir MODEL;

@models = ();
while (@files)
{
	$file = shift @files;

	if ($file =~ /.+\.mod$/)
	{
		push @models, "$model_dir/$file";
	}
}

open(SEQ, $seq_file) || die "can't read $seq_file.\n";
@seq = <SEQ>;
close SEQ;

while (@seq)
{
	$name = shift @seq;
	chomp $name;

#	print "Sequence = $name\n";

	$name =~ /^>(.+)/ || die "fasta format error.\n";
	$name =~ s/\s//g;

	$sequence = "";
	while (@seq)
	{
		$line = shift @seq;	
		if ( @seq == 0 || (@seq > 0 && $seq[0] =~ /^>/) )
		{
			$sequence .= $line;
			$file_name = substr($name, 1);				
			open(FASTA, ">$file_name");
			print FASTA "$name\n";
			print FASTA $sequence;
			close FASTA;
			
			@evalues = ();
			@sel_models = ();	
			for($i = 0; $i < @models; $i++)
			{
				$model = $models[$i];
			#	print("$sam $file_name$i -calibrate 1 -i $model -db $file_name -sw 2\n");

				system("$sam $file_name$i -calibrate 1 -i $model -db $file_name -sw 2 >/dev/null 2>/dev/null");
				if (! open(DIST, "$file_name$i.dist"))
				{
					warn "fail to score $file_name to $model.\n";
					next;
				}
				@dist = <DIST>;
				$score = pop @dist;
				chomp $score;
				if ($score =~ /^$file_name/)
				{
					@fields = split(/\s+/, $score);
					$evalue = $fields[4];	
					
					if ($evalue =~ /nan/)
					{
						warn "$file_name $model, evalue is nan\n";
						next;
				
					}

					push @evalues, $evalue;

					$idx1 = rindex($model, "/");
					$idx2 = rindex($model, ".");
					push @sel_models, substr($model, $idx1+1, $idx2-$idx1-1);

				}			
				else
				{
					warn "scoring output format for seq = $file_name and model = $model is wrong.\n";
					next;
				}
				
				close DIST;
				`rm ${file_name}$i.dist`;
				`rm ${file_name}$i.mlib`;
			}	
			`rm $file_name`;
			
			#sort models by evalue

			$num = @evalues;
			for ($m = $num - 1; $m > 0; $m--)
			{
				for ($n = 0; $n < $m; $n++)
				{
					if (&comp_evalue($evalues[$n], $evalues[$n+1]) == 1)
					{

						$value = $evalues[$n];
						$evalues[$n] = $evalues[$n+1];
						$evalues[$n+1] = $value;

						$value = $sel_models[$n];
						$sel_models[$n] = $sel_models[$n+1];
						$sel_models[$n+1] = $value;
					}	

				}
			}

			print "Transcription Factor = $file_name\n";
			for ($m = 0; $m < @evalues; $m++)
			{
				print $sel_models[$m];
				$len = length($sel_models[$m]);
				for ($k = 0; $k < 60 - $len; $k++)
				{
					print " ";
				}
				print $evalues[$m], "\n";
				if ($m == 9)
				{
					last;
				}
			}


			print "\n\n";
				
			last;
		}

		$sequence .= $line;
	}
	
}





