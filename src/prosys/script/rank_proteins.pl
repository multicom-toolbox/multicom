#!/usr/bin/perl  -w
###################################################
#Rank template proteins by hhs score, com evalue
#prc scores, ssa dot prot, ssa match score
###################################################

if (@ARGV != 2)
{
	die "need two parameters: svm feature file, output prefix.\n";
}

$svm_file = shift @ARGV;
$out_prefix = shift @ARGV;

@hhs = ();
@com = ();
@prc = ();
@ssa = ();
@ssm = ();

#solvent acc match
@sam = ();

#contact num
@con = ();

open(SVM, $svm_file) || die "can't read $svm_file.\n";
while (<SVM>)
{
	$title = $_;
	chomp $title;
	@fields = split(/\s+/, $title);
	$prot = $fields[1];

	$fea = <SVM>;
	chomp $fea;
	@fields = split(/\s+/, $fea);
	@fields == 85 || die "number of features is wrong.\n";

	($hold, $value) = split(/:/, $fields[82]);
	push @hhs, { 
		prot => $prot, 
		score => $value
		};

	($hold, $value) = split(/:/, $fields[84]);
	push @com, { 
		prot => $prot, 
		score => $value
		};

	($hold, $value) = split(/:/, $fields[81]);
	push @prc, { 
		prot => $prot, 
		score => $value
		};

	($hold, $value) = split(/:/, $fields[75]);
	push @ssa, { 
		prot => $prot, 
		score => $value
		};

	($hold, $value) = split(/:/, $fields[39]);
	push @ssm, { 
		prot => $prot, 
		score => $value
		};
	
	($hold, $value) = split(/:/, $fields[40]);
	push @sam, { 
		prot => $prot, 
		score => $value
		};
	
	($hold, $value) = split(/:/, $fields[57]);
	push @con, { 
		prot => $prot, 
		score => $value
		};
}

#sort data

@hhs = sort {$b->{"score"} <=> $a->{"score"}} @hhs;
@com = sort {$a->{"score"} <=> $b->{"score"}} @com;
@prc = sort {$b->{"score"} <=> $a->{"score"}} @prc;
@ssa = sort {$b->{"score"} <=> $a->{"score"}} @ssa;
@ssm = sort {$b->{"score"} <=> $a->{"score"}} @ssm;
@sam = sort {$b->{"score"} <=> $a->{"score"}} @sam;
@con = sort {$b->{"score"} <=> $a->{"score"}} @con;

#output the rank

open(HHS, ">$out_prefix.rank.hhs");
print HHS "Ranked templates \n";
for($i = 0; $i < @hhs; $i++)
{
	print HHS $i+1, "\t";
	print HHS $hhs[$i]{"prot"};
	print HHS "\t";
	print HHS $hhs[$i]{"score"}, "\n";
}
close HHS;

open(COM, ">$out_prefix.rank.com");
print COM "Ranked templates \n";
for($i = 0; $i < @com; $i++)
{
	print COM $i+1, "\t";
	print COM $com[$i]{"prot"};
	print COM "\t";
	print COM $com[$i]{"score"}, "\n";
}
close COM;

open(PRC, ">$out_prefix.rank.prc");
print PRC "Ranked templates \n";
for($i = 0; $i < @prc; $i++)
{
	print PRC $i+1, "\t";
	print PRC $prc[$i]{"prot"};
	print PRC "\t";
	print PRC $prc[$i]{"score"}, "\n";
}
close PRC;

open(SSA, ">$out_prefix.rank.ssa");
print SSA "Ranked templates \n";
for($i = 0; $i < @ssa; $i++)
{
	print SSA $i+1, "\t";
	print SSA $ssa[$i]{"prot"};
	print SSA "\t";
	print SSA $ssa[$i]{"score"}, "\n";
}
close SSA;

open(SSM, ">$out_prefix.rank.ssm");
print SSM "Ranked templates \n";
for($i = 0; $i < @ssm; $i++)
{
	print SSM $i+1, "\t";
	print SSM $ssm[$i]{"prot"};
	print SSM "\t";
	print SSM $ssm[$i]{"score"}, "\n";
}
close SSM;

open(SAM, ">$out_prefix.rank.sam");
print SAM "Ranked templates \n";
for($i = 0; $i < @sam; $i++)
{
	print SAM $i+1, "\t";
	print SAM $sam[$i]{"prot"};
	print SAM "\t";
	print SAM $sam[$i]{"score"}, "\n";
}
close SAM;

open(CON, ">$out_prefix.rank.con");
print CON "Ranked templates \n";
for($i = 0; $i < @con; $i++)
{
	print CON $i+1, "\t";
	print CON $con[$i]{"prot"};
	print CON "\t";
	print CON $con[$i]{"score"}, "\n";
}
close CON;

