#!/usr/bin/perl -w
#######################################################################################
#Combine the models of multiple regions of a protein together
#Inputs: fasta file, dom dir 1, dom dir 2, ..., overlap (5), main output dir
#Assumption: the domain directory name is the same as domain name
#Author: Jianlin Cheng
#Date: 5/11/2010
#############################domain combination########################################
$cm_model_num = 5; 
$modeller_dir = "/home/jh7x3/multicom_beta1.0/tools/modeller9v7/"; 
$prosys_dir = "/home/jh7x3/multicom_beta1.0/src/prosys/";
$final_model_num = 5; 
$pdb2casp2 = "/home/jh7x3/multicom_beta1.0/src/meta/script/pdb2casp.pl";

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
$comb_dir = $output_dir . "/new_comb/";
$atom_dir = $comb_dir . "atom/";
`mkdir $comb_dir $atom_dir`; 
use Cwd 'abs_path'; 
$atom_dir = abs_path($atom_dir); 

#@servers = ("refine", "cluster", "novel", "construct"); 
#@rank_files = ("/full_length/meta/meta.eva", "/full_length/meta/$query_name.sov", "/select/multi_leve.eva", "/cluster/construct.txt"); 
#@destination = ("$output_dir/mcomb/", "$output_dir/cluster/", "$output_dir/cluster/", "$output_dir/select/"); 

@servers = ("construct", "novel", "cluster", "refine", "short"); 

@source_dirs = ("cluster","select",  "cluster", "mcomb", "short"); 

@prefixes = ("con_casp", "casp", "casp", "casp", "casp"); 

@destination = ("$output_dir/cluster/","$output_dir/select/",  "$output_dir/cluster/", "$output_dir/mcomb/", "$output_dir/short"); 

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


	for ($i = 0; $i < $final_model_num; $i++)
	{
		#generate pir alignment for each combination	
		$idx = $i + 1; 
		$pir_file = $comb_dir . "$server$idx.pir";

		open(PIR, ">$pir_file") || die "can't create pir file $pir_file.\n";
		for ($j = 0; $j < $domain_num; $j++)
		{
			print PIR "C;combination $i, domain $j\n";

			$domain_dir = "$domain_dirs[$j]" . "/$source_dirs[$m]";
			$prefix = $prefixes[$m]; 
			$model_file = "$domain_dir/$prefix$idx.pdb";
			$model_name = substr($model_file, rindex($model_file, "/") + 1, rindex($model_file, ".") - rindex($model_file, "/") -1);   			
			$model_name .= "_dom$j";
			$model_name .= "_$server";

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

			system("/home/jh7x3/multicom_beta1.0/tools/scwrl4/Scwrl4 -i $comb_dir/$server$idx.pdb -o $comb_dir/$server$idx.pdb.scw >/dev/null");
			system("/home/jh7x3/multicom_beta1.0/src/meta/model_cluster/script/clash_check.pl $fasta_file $comb_dir/$server$idx.pdb.scw > $comb_dir/$server-clash$idx.txt");


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

