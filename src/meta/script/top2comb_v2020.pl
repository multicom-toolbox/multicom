#!/usr/bin/perl -w
###################################################################
#Check the orginal top ranked model with combined model (casp1.pdb)
#In the model dir. If the GDT-TS score is less than 0.9
#Revert to the top ranked model
#Author: Jianlin Cheng
#Date: 2/5/2020 
###################################################################
if (@ARGV != 4)
{
	die "need four parameters: option file, combined model dir, rank file, GDT-TS score threshold (0.9).\n";
}

$option_file = shift @ARGV;
-f $option_file || die "can't find option file: $option_file.\n";

open(OPTION, $option_file) || die "can't read option file.\n";
while (<OPTION>)
{
        $line = $_;
        chomp $line;
        if ($line =~ /^tm_score/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $tm_score = $value;
        }
        if ($line =~ /^scwrl_program/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $scwrl_program = $value;
        }
        if ($line =~ /^multicom_dir/)
        {
                ($other, $value) = split(/=/, $line);
                $value =~ s/\s//g;
                $multicom_dir = $value;
        }

}
close OPTION; 

$comb_dir = shift @ARGV;
-d $comb_dir || die "can't find $comb_dir.\n";
$rank_file = shift @ARGV;
open(RANK, $rank_file) || die "can't read $rank_file.\n";
@rank = <RANK>;
close RANK; 
shift @rank;
$model = shift @rank;
@fields = split(/\s+/, $model);
$mname = $fields[0]; 


$threshold = shift @ARGV; 

chdir $comb_dir;

#get the model file name
$mname .= ".atm";

-f $mname || die "can't find $mname\n";

#compare the model with casp1.pdb (the combined model)
-f $tm_score || die "can't find $tm_score\n";
system("$tm_score $mname casp1.pdb > casp1_$mname");
#get GDT-TS score of two cores		
open(RES, "casp1_$mname") || die "can't read casp1_$mname.\n";
@res = <RES>;
close RES;
$sim_score = 0; 
foreach $record (@res)
{
	if ($record =~ /GDT-score\s+=\s+(.+) \%.+\%.+\%.+\%.+/)
	{
		$sim_score = $1; 
	}	
}	

-f $scwrl_program || die "can't find $scwrl_program\n";
-d $multicom_dir || die "can't find $multicom_dir\n";

if ($sim_score < $threshold)
{
	warn "The similarity between the combined model (casp1.pdb) and the top ranked model ($mname) is $sim_score. Revert back to $mname.\n";
	open(CASP, "casp1.pdb") || die "can't read casp1.pdb\n";	
	<CASP>;
	$target = <CASP>;
	chomp $target;
	@fields = split(/\s+/, $target);
	$tname = $fields[1]; 
	close CASP; 
	
	`mv casp1.pdb casp1.pdb.comb`; 

	`$scwrl_program -i $mname -o $mname.scw`;
	`$multicom_dir/script/pdb2casp.pl $mname.scw 1 $tname casp1.pdb`;
}
else
{
	print "The similarity between casp1.pdb and $mname is $sim_score. No reversion.\n";
}
	
