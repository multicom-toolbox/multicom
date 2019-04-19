#!/usr/bin/perl -w
#######################################################################
#Cluster a banch of models ranked by model_check or model_energy
#Input: spicker program, psi-pred dir, model dir file, model rank file
#FASTA sequence, output dir
#Date: 11/15/2007.
#Author: Jianlin Cheng
#######################################################################

if (@ARGV != 6)
{
	die "need six parameters: model cluster script dir, spicker program, model dir file, model rank file, FASTA sequence, and output dir.\n";
}

$cluster_dir = shift @ARGV;
use Cwd 'abs_path';
$cluster_dir = abs_path($cluster_dir);

$spicker = shift @ARGV;
$model_dir = shift @ARGV;
$model_rank_file = shift @ARGV;
$fasta_file = shift @ARGV;
$out_dir = shift @ARGV;

-d $cluster_dir || die "can't open $cluster_dir.\n";
-f $spicker || die "$spicker is not found.\n";
-d $model_dir || die "can't find $model_dir.\n";

-f $model_rank_file || die "can't find $model_rank_file.\n";
-f $fasta_file || die "can't find $fasta_file.\n";
-d $out_dir || die "can't find $out_dir.\n";

$pulchar = "$cluster_dir/pulchar";
-f $pulchar || die "can't find $pulchar.\n";
$modeller = "$cluster_dir/pir2ts_energy.pl";
-f $modeller || die "can't find $modeller.\n";
$clash = "$cluster_dir/clash_check.pl ";

#change to absoluate path
use Cwd 'abs_path';
$spicker = abs_path($spicker);
$model_dir = abs_path($model_dir);
$model_rank_file = abs_path($model_rank_file);
$fasta_file = abs_path($fasta_file);

#create a sequence file for clustering
open(FASTA, $fasta_file) || die "$fasta_file is not found.\n";
@fasta = <FASTA>;
close FASTA;
$name = $fasta[0];
chomp $name;
$name = substr($name, 1);
$seq = $fasta[1];
chomp $seq;
close FASTA;

`cp $fasta_file $out_dir/$name.fasta`;

chdir $out_dir;

open(RANK, $model_rank_file) || die "can't open $model_rank_file.\n";
@rank = <RANK>;
close RANK;

shift @rank; shift @rank; shift @rank; shift @rank; 
pop @rank;

#set the number of models to cluster
$num = int(@rank / 2);

#predict secondary structure
#$idx = rindex($fasta_file, ".");
#if ($idx > 0)
#{
#	$filename = substr($fasta_file, 0, $idx);
#}
#else
#{
#	$filename = $fasta_file;
#}

open(SEQ, ">seq.dat") || die "can't create seq.dat";
$slen = length($seq);

%amino=();
$amino{"A"} = "ALA";
$amino{"C"} = "CYS";
$amino{"D"} = "ASP";
$amino{"E"} = "GLU";
$amino{"F"} = "PHE";
$amino{"G"} = "GLY";
$amino{"H"} = "HIS";
$amino{"I"} = "ILE";
$amino{"K"} = "LYS";
$amino{"L"} = "LEU";
$amino{"M"} = "MET";
$amino{"N"} = "ASN";
$amino{"P"} = "PRO";
$amino{"Q"} = "GLN";
$amino{"R"} = "ARG";
$amino{"S"} = "SER";
$amino{"T"} = "THR";
$amino{"V"} = "VAL";
$amino{"W"} = "TRP";
$amino{"Y"} = "TYR";

for($i = 0; $i < $slen; $i++)
{
		
	$ord = $i+1;
	$aa = substr($seq, $i, 1);
	$aaa = $amino{$aa};

	printf SEQ "%5d%6s%5d%5d\n", $ord, $aaa, "1", 0;
}
close SEQ;

#create rmsinp file
open(RMSINP, ">rmsinp") || die "can't create rmsinp\n";
print RMSINP "1  $slen\n";
print RMSINP "$slen\n";
print RMSINP "$name\n";
close RMSINP; 

#create trajectory file
open(TRA, ">tra.in") || die "can't create trajectory file.\n";
print TRA " 1\n";
print TRA "rep1.tra1\n";
close TRA;

open(REP, ">rep1.tra1");

$idx = 0; 
for ($i = 0; $i < $num; $i++)
{
	$line = $rank[$i];
	chomp $line;
	($model, $score) = split(/\s+/, $line);
	
	$model_file = "$model_dir/$model";
	-f $model_file || next; 
		
	@atoms = ();
	open(MODEL, $model_file) || die "can't read $model_file.\n";
	@atoms = <MODEL>;	
	close MODEL;

	print "process model $model_file...\n";

	@ca_x = ();
	@ca_y = ();
	@ca_z = ();

	while (@atoms)
	{
		$line = shift @atoms;

#		print $line, "\n";
#		print "pressy any key to continue...";
#		<STDIN>;	
	
		if ($line =~ /^ATOM/)
		{
			$type = substr($line, 12, 4);	
			$xc = substr($line, 30, 8);
                        $xc =~ s/\s//g;
                        $yc = substr($line, 38, 8);
                        $yc =~ s/\s//g;
                        $zc = substr($line, 46, 8);
                        $zc =~ s/\s//g;
			if ($type =~/CA/)
			{
				push @ca_x, $xc;
				push @ca_y, $yc;
				push @ca_z, $zc;
			}
		}	
	}

	@ca_x == $slen || die "sequence length does not match with the number of CA atoms.\n";

	#printf REP "%8d%10d%8d%8d\n", $slen, $score*100+0.1, $i+1, $i+1; 
	printf REP "%8d%10d%8d%8d\n", $slen, $score*100+0.1, $idx+1, $idx+1; 

	for ($j = 0; $j < $slen; $j++)
	{
		printf REP "%10.3f%10.3f%10.3f\n", $ca_x[$j], $ca_y[$j], $ca_z[$j]; 
	}
	$idx++;
	
}

close REP;

#cluster models
system("$spicker");

#optimize five models
for ($i = 1; $i <= 5; $i++)
{
	if (-f "combo$i.pdb")
	{
		system("$pulchar combo$i.pdb");
		`mv combo$i.pdb combo$i.ct`;	
		`mv combo$i.pdb.rebuilt combo$i`;
	}
} 

#futher optimize by modeller
$max_iter = 10; 

$path = abs_path(".");

for ($i = 1; $i <= 5; $i++)
{
	$count = 1; 
	while ($count < $max_iter)
	{
		$model = "combo$i";
		if (! -f $model)
		{
			last;
		}
	
		#clash check
		system("$clash $fasta_file $model > $model.clash");
		open(CLASH, "$model.clash") || die "can't open $model.clash\n";  
		@clashes = <CLASH>;
		close CLASH;
		$opt = 0;
		$tot = @clashes;

		if (@clashes >= length($seq) * 0.02)
		{
			print "$model has $tot clashes, to optimize, iteration $count.\n";
			$opt = 1;
		}
		foreach $line (@clashes)
		{
			if ($line =~ /^servere/)
			{
				print "$model has server clashes, to optimize, iteration $count.\n";
				$opt = 2;
			}
		}	
		
		if ($opt > 0)
		{
			`mkdir $i 2>/dev/null`;
			$len = length($seq);
			$pir = "$i.pir";
			open(PIR, ">$pir");
			print PIR "C; self alignments\n";
			print PIR ">P1;comboa$i\n";
			print PIR "structureX:combo$i: 1: : $len: : : : : \n";
			print PIR "$seq*\n\n";
			print PIR ">P1;combob$i\n";
			print PIR "> : : : : : : : : : \n";
			print PIR "$seq*\n";
			close PIR;

			#do self modeling
			`cp $model atom`;
			system("$modeller /home/chengji/software/prosys/modeller7v7/ $path $i $pir 3");
			if (-f "$i/combob$i.pdb")
			{
				`mv $i/combob$i.pdb combo$i`;
			}
		}	
		else
		{
			print "$model: no optimization is necessary.\n";
			last;
		}
	
		#clash check
		system("$clash $fasta_file $model > $model.clash");
		open(CLASH, "$model.clash") || die "can't open $model.clash\n";  
		@clashes = <CLASH>;
		close CLASH;
		$tot = @clashes;
		print "$model, total number of clashes is $tot after optimization.\n";

		$count++;

	}

	#convert the model using scwrl
	if (-f $model)
	{
		#re-pack side chain
		system("/home/chengji/software/scwrl/scwrl3 -i $model -o $model-s >/dev/null");
		#convert the model into FASTA format
		if (-f "$model-s")
		{
			system("/home/chengji/casp8/model_cluster/script/pdb2casp.pl $model-s $i $name casp$i.pdb");
		}
		else
		{
			system("/home/chengji/casp8/model_cluster/script/pdb2casp.pl $model $i $name casp$i.pdb");
		}
	}

}


#run pulchar again to optimze again???
#can't do this because it may introduce chain broken and servere clashes as on T0301

#run scwrl to repack side chain? 

#############################################################################


