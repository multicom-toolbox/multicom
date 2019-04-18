#!/usr/bin/perl -w
#perl /home/casp11/casp12/scripts/evaluate_casp_target.pl  T0761  /home/jh7x3/protein_structure/CASP12/TEST6/TOP5  /home/jh7x3/protein_structure/CASP12/TEST6/CHECK/ /home/jh7x3/protein_structure/CASP12/TEST6/CHECK/MODEL_NATIVE_TMscore.txt
$numArgs = @ARGV;
if($numArgs != 5)
{   
	print "the number of parameters is not correct!";
	exit(1);
}

#$in2 = "$ARGV[0]";	#alignment ID 
#$out = "$ARGV[1]";
#$inf = "$ARGV[2]";
#$mod = "$ARGV[3]";
$targetid = "$ARGV[0]";	# target id 
$native_file = "$ARGV[1]";	# target id 
$inf0 = "$ARGV[2]";	#T0859/rosetta_results_T0859/top_models
$outf = "$ARGV[3]";	#T0859/rosetta_results_T0859/ folder
$outfile = "$ARGV[4]";	#outfile

if(!(-d $outf))
{
	`mkdir $outf`;
}
chdir($outf);
open(OUT1, ">$outfile") || die("Couldn't open file $outfile\n"); 


$filtered_pdb=$native_file;

print OUT1 "ID\tGDT-TS\tTM\tRMSD\n";
opendir (DIR3, "$inf0" ) || die "Error in opening dir $inf0\n";
$checknum=0;
my @models;
while($checkmod = readdir(DIR3))
{
	if (substr($checkmod,length($checkmod)-4) eq '.pdb')
	{
		$checknum++;
		push @models,$checkmod;
	}
}
$index=0;

$gdt_best=0;
$tmscore_best=0;
$rmsd_best=0;
foreach $checkmod (sort @models )
{
	$index++;
	$premodel=$inf0.'/'.$checkmod;
	$t_f=$outf.'/'.$targetid."_".$checkmod.".pdb";

	if(-e $premodel and -e $filtered_pdb)
	{
		print "Evaluate predicted model <$checkmod> to native structure <$targetid>\n";
	}elsif(!(-e $filtered_pdb))
	{
		die  "<$filtered_pdb> is not found\n";
	}
	else{
		print "Predicted model <$checkmod> is not found\n";
		next;
	}
	
	`perl /home/casp13/dncon2-Rosetta/scripts/eva_scripts/pre2zhang.pl $premodel $filtered_pdb $t_f`;
			
	open(TMP, ">./${targetid}_tmp") || die("Couldn't open file ${targetid}_tmp\n");
	my $command2="/home/jh7x3/tools/TMscore $t_f $filtered_pdb";
	my @result2=`$command2`;

	foreach $j (@result2) 
	{
		print $j;
		print TMP $j;
	}
	close TMP;
	`rm $t_f`;
	print "\n\n";

	open(TMP, "./${targetid}_tmp") || die("Couldn't open file ${targetid}_tmp\n"); 
	@arr1=<TMP>;
	close TMP;
	$tmscore=0;
	$gdt=0;

	foreach $line3 (@arr1) 
	{
		chomp($line3);
		if ("GDT-TS-score" eq substr($line3,0,12)) 
		{
			$s1=substr($line3,index($line3,"=")+2);
			$s1=substr($s1,0,index($s1,"%")-1);
			$gdt=1*$s1;
		}
		if ("TM-score" eq substr($line3,0,8)) 
		{
			$s1=substr($line3,index($line3,"=")+2);
			$s1=substr($s1,0,index($s1,"(")-2);
			$tmscore=1*$s1;
		}
		if ("GDT-HA-score" eq substr($line3,0,12))
		{
			$s1=substr($line3,index($line3,"=")+2);
			$s1=substr($s1,0,index($s1," "));
			$gdthascore=1*$s1;
		}
		if ("MaxSub-score" eq substr($line3,0,12))
		{
			$s1=substr($line3,index($line3,"=")+2);
			$s1=substr($s1,0,index($s1," "));
			$maxscore=1*$s1;
		}
		if ("RMSD of  the common residues" eq substr($line3,0,28))
		{
			$s1=substr($line3,index($line3,"=")+1);
			while (substr($s1,0,1) eq " ") {
				$s1=substr($s1,1);
			}
			$rmsd=1*$s1;
		}
	}
	`rm ${targetid}_tmp`;

	print OUT1 "${targetid}\t${checkmod}\t$gdt\t$tmscore\t$rmsd\n";
	
	if($tmscore_best <$tmscore )
	{
		$gdt_best = $gdt;
		$tmscore_best = $tmscore;
		$rmsd_best = $rmsd;
	}
	
}
#print OUT1 "----------------------------------------------------------------------------\n";
print  "ID\tgdt_best\ttmscore_best\trmsd_best\tchecknum\n";
print  "${targetid}_Best\t$gdt_best\t$tmscore_best\t$rmsd_best\t$checknum\n";
print OUT1 "${targetid}_Best\t$gdt_best\t$tmscore_best\t$rmsd_best\t$checknum\n";
	
close OUT1;
