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
	die "need six parameters: spicker program, psi-pred dir, model dir file, model rank file, FASTA sequence, and output dir.\n";
}

$spicker = shift @ARGV;
$psipred_dir = shift @ARGV;
$model_dir = shift @ARGV;
$model_rank_file = shift @ARGV;
$fasta_file = shift @ARGV;
$out_dir = shift @ARGV;

-f $spicker || die "$spicker is not found.\n";
-d $psipred_dir || die "can't find $psipred_dir.\n";
-d $model_dir || die "can't find $model_dir.\n";

-f $model_rank_file || die "can't find $model_rank_file.\n";
-f $fasta_file || die "can't find $fasta_file.\n";
-d $out_dir || die "can't find $out_dir.\n";

#change to absoluate path
use Cwd 'abs_path';
$spicker = abs_path($spicker);
$psipred_dir = abs_path($psipred_dir);
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

print "predict secondary structure...\n";
system("$psipred_dir/runpsipred $fasta_file");
$horiz = "$name.horiz";
open(SS, $horiz) || die "can't read $horiz.\n";
$ss_pred = "";
$ss_conf = "";

while ($line = <SS>)
{
	if ($line =~ /^Conf:\s+(\d+)/)
	{
		$ss_conf .= $1;
	}
	elsif ($line =~ /^Pred:\s+(\S+)/)
	{
		$ss_pred .= $1;
	}
}

length($ss_conf) == length($ss_pred) || die "length of secondary structure is not equivalent to that of confidence.\n";
$ss_pred =~ s/C/1/g;
$ss_pred =~ s/H/2/g;
$ss_pred =~ s/E/3/g;

length($ss_pred) == length($seq) || die "length of secondary structure is not equal to that of sequence.\n";

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
	$sec = substr($ss_pred, $i, 1);  
	$cscore = substr($ss_conf, $i, 1);

	printf SEQ "%5d%6s%5d%5d\n", $ord, $aaa, $sec, $cscore;
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

for ($i = 0; $i < $num; $i++)
{
	$line = $rank[$i];
	chomp $line;
	($model, $score) = split(/\s+/, $line);
	
	$model_file = "$model_dir/$model";
		
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

	printf REP "%8d%10d%8d%8d\n", $slen, $score*100+0.1, $i+1, $i+1; 

	for ($j = 0; $j < $slen; $j++)
	{
		printf REP "%10.3f%10.3f%10.3f\n", $ca_x[$j], $ca_y[$j], $ca_z[$j]; 
	}
	
}

close REP;

#cluster models
system("$spicker");

#############################################################################






