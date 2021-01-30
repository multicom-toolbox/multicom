#!/usr/bin/perl -w
#######################################################################################
#Combine the models of multiple domains together
#Inputs: fasta file, dom dir 1, dom dir 2, ..., overlap (5), main output dir
#Assumption: the domain directory name is the same as domain name
#Author: Jianlin Cheng
#Date: 5/11/2010
#############################domain combination########################################
$cm_model_num = 3; 
$modeller_dir = "/home/chengji/software/modeller9v7/"; 
$prosys_dir = "/home/chengji/software/prosys/";
$final_model_num = 5; 
$pdb2casp2 = "/home/chengji/casp8/meta/script/pdb2casp.pl";

if (@ARGV < 5)
{
	die "need the following parameters: fasta file, domain dir 1, domain dir 2, ..., overlap (e.g. 5), main output dir.\n";
}

$fasta_file = shift @ARGV;
$output_dir = pop @ARGV;
-d $output_dir || die "can't find main output dir: $output_dir.\n";
$overlap = pop @ARGV;
@domain_dirs = @ARGV;

print "Combine domain model into full-length models...\n";

my $domain_num = @domain_dirs;  
my @domain_models = (); 

open(FASTA, $fasta_file) || die "can't open $fasta_file.\n";
$query_name = <FASTA>;
chomp $query_name;
$query_name = substr($query_name, 1); 
$query_seq = <FASTA>;
chomp $query_seq;
close FASTA; 
$query_length = length($query_seq); 

###############get query sequence, each domain sequence, domain length ###########
#Here, I assume that the directory name is the same as the domain name###########
@domain_seq = (); 
@domain_len = (); 
@domain_names = (); 
for ($i = 0; $i < @domain_dirs; $i++)
{
	#extract domain name
	$dom_dir = $domain_dirs[$i]; 	

	$idx1 = index($dom_dir, "/");
	$idx2 = rindex($dom_dir, "/");
	
	if ($idx1 < 0 && $idx2 < 0)
	{
		$domain_name = $dom_dir; 	
	}	
	elsif ($idx1 >= 0 && $idx2 >= 0)
	{
		$domain_name = substr($dom_dir, $idx1+1, $idx2 - $idx1 - 1);   	
	}
	else
	{
		$idx = $idx1 > $idx2 ? $idx1 : $idx2; 
		if ($idx < length($dom_dir) - 1)
		{
			$domain_name = substr($dom_dir, $idx+1); 
		}
		else
		{
			$domain_name = substr($dom_dir, 0, $idx); 
		}
	}

	push @domain_names, $domain_name; 

	#get the domain file
	$domain_file = $dom_dir . "/full_length/blast/$domain_name.fasta";       
	open(DOM, $domain_file) || die "can't read $domain_file.\n";
	<DOM>;
	$seq = <DOM>;
	chomp $seq; 	
	close DOM; 
	
	push @domain_seq, $seq; 
	push @domain_len, length($seq); 
}

#generate pir alignment for each domain
@pir_seq = (); 
$acc_len = 0; 
for ($i = 0; $i < @domain_seq; $i++)
{
	$pos = $acc_len - $i * $overlap; 				
	$pir = "";	
	for ($j = 1; $j <= $pos; $j++)
	{
		$pir .= "-"; 
	}
	$pir .= $domain_seq[$i]; 
	$pos += $domain_len[$i]; 
	for ($j = $pos + 1; $j <= $query_length; $j++)
	{
		$pir .= "-"; 
	} 

	$acc_len += $domain_len[$i]; 
	push @pir_seq, $pir; 
	
	$ab = length($pir); 
	length($pir) == $query_length || die "length mismatch ($domain_name, $ab, $query_length):\n$pir\n";

#	print "$pir\n";
}

##################################################################################

#generate pir alignments and models for each combination
$comb_dir = $output_dir . "/dcomb/";
$atom_dir = $comb_dir . "atom/";
use Cwd 'abs_path'; 
$atom_dir = abs_path($atom_dir); 
`mkdir $comb_dir $atom_dir`; 

#@servers = ("refine", "cluster", "novel", "construct"); 
#@rank_files = ("/full_length/meta/meta.eva", "/full_length/meta/$query_name.sov", "/select/multi_leve.eva", "/cluster/construct.txt"); 
#@destination = ("$output_dir/mcomb/", "$output_dir/cluster/", "$output_dir/cluster/", "$output_dir/select/"); 

@servers = ("construct", "novel", "cluster", "refine"); 

@rank_files = ("/cluster/construt.txt","/select/multi_level.eva",  "/full_length/meta/$query_name.sov", "/full_length/meta/meta.eva"); 

@destination = ("$output_dir/cluster/","$output_dir/select/",  "$output_dir/cluster/", "$output_dir/mcomb/"); 

@servers = reverse @servers;
@rank_files = reverse @rank_files;
@destination = reverse @destination; 


for ($i = 0; $i < @destination; $i++)
{
	if (! -d $destination[$i])
	{
		`mkdir $destination[$i]`; 
	}
}

for ($m = 0; $m < @servers; $m++)
{
	$server = $servers[$m];
	$score_file = $rank_files[$m]; 	

	##################################
	#this line fixed the bug of using same set of models
	@domain_models = ();  	
	#################################
 
	#get the models of each domain
	for ($i = 0; $i < $domain_num; $i++)
	{
		$domain_dir = "$domain_dirs[$i]" . "/full_length/meta/";
		if ($server ne "cluster")
		{
			$rank_file = $domain_dirs[$i] . $score_file;
		}
		else
		{
			$domain_name = $domain_names[$i]; 
			$rank_file = $domain_dir . "$domain_name.sov"; 
		}

		print "Use $rank_file to select domains for combination...\n";

		open(RANK, $rank_file) || die "can't open $rank_file.\n";
		@rank = <RANK>;
		close RANK; 		
		$model = ""; 

		if ($rank_file =~ /meta\.eva/)
		{
			shift @rank; 
			foreach $record (@rank)
			{
				@fields = split(/\s+/, $record); 
				$model_id = $fields[0]; 
				$model .= "$domain_dir$model_id "; 
			}	
		}
		elsif ($rank_file =~ /\.sov/)
		{
			foreach $record (@rank)
			{
				@fields = split(/:/, $record); 
				$model_id = $fields[0]; 
				$model_id =~ s/\s//g; 
				$model .= "$domain_dir$model_id "; 
			}	
		}
		elsif ($rank_file =~ /construt/)
		{
			foreach $record (@rank)
			{
				chomp $record; 
				$slash_idx = rindex($record, "/");
				$model_id = substr($record, $slash_idx+1);  
				$model .= "$domain_dir$model_id "; 
			}	
	
		}
		elsif ($rank_file =~ /multi/)
		{
			shift @rank; 
			foreach $record (@rank)
			{
				@fields = split(/\s+/, $record); 
				$model_id = $fields[0] . ".pdb"; 
				$model .= "$domain_dir$model_id "; 
			}	
	
		}

		push @domain_models, $model; 	
	}

	for ($i = 0; $i < $final_model_num; $i++)
	{
		#generate pir alignment for each combination	
		$idx = $i + 1; 
		$pir_file = $comb_dir . "$server$idx.pir";

		open(PIR, ">$pir_file") || die "can't create pir file $pir_file.\n";
		for ($j = 0; $j < $domain_num; $j++)
		{
			print PIR "C;combination $i, domain $j\n";

			$model_names = $domain_models[$j];   
			@mnames = split(/\s+/, $model_names); 
			$model_file = $mnames[$i]; 

			$model_name = substr($model_file, rindex($model_file, "/") + 1, rindex($model_file, ".") - rindex($model_file, "/") -1);   			
			
			$model_name .= "_dom$j";
			print PIR ">P1;$model_name\n";
			#copy the file to the atom dir
			`cp -f $model_file $atom_dir/$model_name.atom`; 
			`gzip -f $atom_dir/$model_name.atom`; 

			$dlen = $domain_len[$j]; 
			print PIR "structureX:$model_name: 1: : $dlen: : : : : \n"; 
			print PIR "$pir_seq[$j]*\n\n";
		}
		print PIR "C; combination of multiple domains\n"; 
		print PIR ">P1;$server$idx\n";
		print PIR " : : : : : : : : : \n";
		print PIR "$query_seq*\n";
		close PIR; 

		#generate models
		print "Use Modeller to generate models combining multiple domains...\n";
		system("$prosys_dir/script/pir2ts_energy.pl $modeller_dir $atom_dir $comb_dir $pir_file $cm_model_num");  	

		if ( -f "$comb_dir/$server$idx.pdb")
		{
			print "A combined model $comb_dir/$server$idx.pdb is generated.\n";

			system("/home/chengji/software/scwrl4/Scwrl4 -i $comb_dir/$server$idx.pdb -o $comb_dir/$server$idx.pdb.scw >/dev/null");
			system("/home/chengji/casp8/model_cluster/script/clash_check.pl $fasta_file $comb_dir/$server$idx.pdb.scw > $comb_dir/$server-clash$idx.txt");


#			print("$pdb2casp2 $comb_dir/$server$idx.pdb.scw $idx $query_name $comb_dir/$server-casp$idx.pdb");	
			system("$pdb2casp2 $comb_dir/$server$idx.pdb.scw $idx $query_name $comb_dir/$server-casp$idx.pdb");	

			#copy files to the destination
			if ($server =~ /construct/)
			{
				if (-f "$destination[$m]/con_casp$idx.pdb")
				{
					`mv $destination[$m]/con_casp$idx.pdb $destination[$m]/con_casp$idx.pdb.org`; 
					`mv $destination[$m]/con_clash$idx.txt $destination[$m]/con_clash$idx.txt.org`; 
				}
				printf "copy the model to the destination.\n";
				printf "cp $comb_dir/$server-casp$idx.pdb $destination[$m]/con_casp$idx.pdb\n"; 	
				`cp $comb_dir/$server-casp$idx.pdb $destination[$m]/con_casp$idx.pdb`; 	
				`cp $comb_dir/$server-clash$idx.txt $destination[$m]/con_clash$idx.txt`; 	
			}
			else
			{
				printf "copy the model to the destination.\n";
				print "cp $comb_dir/$server-casp$idx.pdb $destination[$m]/casp$idx.pdb\n"; 	
				if (-f "$destination[$m]/casp$idx.pdb")
				{
					`mv $destination[$m]/casp$idx.pdb $destination[$m]/casp$idx.pdb.org`; 
					`mv $destination[$m]/clash$idx.txt $destination[$m]/clash$idx.txt.org`; 
				}
				`cp $comb_dir/$server-casp$idx.pdb $destination[$m]/casp$idx.pdb`; 	
				`cp $comb_dir/$server-clash$idx.txt $destination[$m]/clash$idx.txt`; 	
			}

		}
	
	}

}

