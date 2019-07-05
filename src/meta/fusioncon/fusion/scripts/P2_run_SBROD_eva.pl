#! /usr/bin/perl -w
use Cwd 'abs_path';
use FileHandle;
if(@ARGV !=2)
{
	die "The number of parameter is not correct!\n";
}

$model_dir = $ARGV[0];
$outputdir = $ARGV[1];

if(!(-d $outputdir))
{
	`mkdir $outputdir`;
}

open(OUT,">$outputdir/select.info");

$final_model_number=10;
$output_prefix_name='fusion';

$fusion_starttime = time();
$SBROD_starttime = time();
chdir("/home/jh7x3/multicom_beta1.0/tools/SBROD");

if(!(-e "$outputdir/SBROD_ranking.txt"))
{
	$cmd = "./assess_protein $model_dir/*pdb &> $outputdir/SBROD_ranking.txt";

	print "generating SBROD score\n   $cmd \n\n";
	$ren_return_val=system("$cmd");
	if ($ren_return_val)
	{
		$SBROD_finishtime = time();
		$SBROD_diff_hrs = ($SBROD_finishtime - $SBROD_starttime)/3600;
		print "SBROD modeling finished within $SBROD_diff_hrs hrs!\n\n";
		print "ERROR! SBROD execution failed!";
		exit 0;
	}
}
$SBROD_finishtime = time();
$SBROD_diff_hrs = ($SBROD_finishtime - $SBROD_starttime)/3600;
print "SBROD modeling finished within $SBROD_diff_hrs hrs!\n\n";

#### processing the SBROD ranking 
print "Checking $outputdir/SBROD_ranking.txt\n";
open(TMPF,"$outputdir/SBROD_ranking.txt") || die "Failed to open file $outputdir/SBROD_ranking.txt\n";
open(TMPO,">$outputdir/Final_ranking.txt") || die "Failed to open file $outputdir/Final_ranking.txt\n";
%mod2score=();
while(<TMPF>)
{
	$li = $_;
	chomp $li;
	@info = split(/\s+/,$li);
	$modpath = $info[0];
	$modscore = $info[1];
	@tmpa = split(/\//,$modpath);
	$mod = pop @tmpa;
	$mod2score{$mod} = $modscore;
	
}
close TMPF;
foreach $mod (sort {$mod2score{$b} <=> $mod2score{$a}} keys %mod2score) 
{
	print TMPO "$mod\t".$mod2score{$mod}."\n";
}
close TMPO;

chdir($outputdir);


### running maxcluster 
if(-d "$outputdir/top_models")
{
	`rm -rf $outputdir/top_models/*`;
}else{
	`mkdir $outputdir/top_models/`;
}

@pdb_list;
$rankf = "$outputdir/Final_ranking.txt";
open FEAT, "$rankf" or die $!;
my @rankmodel = <FEAT>;
close FEAT; 
$modid=0;
print "Total lines: ".@rankmodel." in $rankf\n";
foreach (@rankmodel)
{
	$line=$_;
	chomp $line;
	@tmp = split(/\t/,$line);
	$mod = $tmp[0];
	
	if($modid>=$final_model_number)
	{
		last;
	}

	print "Added ".$mod." to top $final_model_number list\n";
	print OUT "Added ".$mod." to top $final_model_number list\n";
	$modelfile = "$model_dir/$mod";
	if(!(-e $modelfile))
	{
		die "Failed to find model $modelfile\n";
	}
	
	
	$modid++;
	push @pdb_list, $mod; 
	print("### cp $modelfile $outputdir/top_models/${output_prefix_name}-$modid.pdb\n");
	system("cp $modelfile $outputdir/top_models/${output_prefix_name}-$modid.pdb");
	system("cp $modelfile $outputdir/${output_prefix_name}-$modid.pdb");
}


print "\n";
print OUT "\n";
print "Rank the ".@pdb_list." models selected [expected = $final_model_number] ..\n";
print OUT "Rank the ".@pdb_list." models selected [expected = $final_model_number] ..\n";
die "Error! Top models could not be found!" if scalar(@pdb_list) < 1;

close OUT;


$fusion_finishtime = time();
$full_diff_hrs = ($fusion_finishtime - $fusion_starttime)/3600;
print "\n####### fusion-dncon2 modeling finished within $full_diff_hrs hrs!\n\n";

