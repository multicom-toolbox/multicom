#!/usr/bin/perl -w
####################################################################
#compare the true casp targets (formated by zhang) to prdiction 
#assmuption: the pdb sequnces in two domains are exactly same
#input: getGDT_TS.pl path, predicted domains, true casp domains
#output: GDT-TS scores for each pair
#Author: Jianlin Cheng
#Date: 9/9/2006
####################################################################

if (@ARGV != 2)
{
	die "need two parameters: zhang pdb dir, predict dir\n";
}

$zhang_dir = shift @ARGV;
$casp_dir = shift @ARGV;


opendir(ZHANG, $zhang_dir) || die "can't read zhang dir.\n";
@targets = readdir ZHANG;
closedir ZHANG;

opendir(CASP, $casp_dir) || die "can't read casp dir.\n";
@casp = readdir CASP;
closedir CASP;

@tfiles = ();
while (@targets)
{
	$tfile = shift @targets;
	if ($tfile eq "." || $tfile eq "..")
	{
		next;
	}
	push @tfiles, $tfile;
}

@cfiles = ();
while (@casp)
{
	$cfile = shift @casp;
	if ($cfile eq "." || $cfile eq "..")
	{
		next;
	}
	push @cfiles, $cfile;
}

# do evaluations
@tfiles = sort @tfiles;
$total  = 0;
while (@tfiles)
{
	$tfile = shift @tfiles;
	$tid = substr($tfile, 0, 5);
	#find the corresponding predicted model file
	for($i =0; $i <@cfiles; $i++)
	{
		$cfile = $cfiles[$i];
		if ($cfile =~ /$tid/)
		{
			print "$tid-$cfile\n";
			system("/home/chengji/work/eval_casp7/gdt/gdt_ts/get_lga.pl /home/chengji/work/eval_casp7/gdt/gdt_ts/ $casp_dir/$cfile $zhang_dir/$tfile -3 -atom:CA -d:4 > gdt_score");
			open(GDT, "gdt_score");
			$score = <GDT>;
			chomp $score;
			close GDT;
			print "$score\n";
			$total += $score;
			print "\n";
		}	
	}		
}

print "total gdt score = $total\n";


