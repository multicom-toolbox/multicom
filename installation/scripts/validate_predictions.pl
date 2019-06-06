#!/usr/bin/perl -w
#perl /home/jh7x3/multicom/installation/scripts/validate_predictions.pl  T0993s2  /home/jh7x3/multicom/test_out/T0993s2_csiblast_052419 /home/jh7x3/multicom//installation/benchmark
if (@ARGV != 3) {
  print "Usage: structure1  structure2\n";
  exit;
}
$targetid = $ARGV[0];
$test_dir = $ARGV[1];
$benchmark_dir = $ARGV[2];

$GLOBAL_PATH="/home/jh7x3/multicom/";

opendir(DIR,"$test_dir") || die "Failed to open directory $test_dir\n";
@subdirs = readdir(DIR);
closedir(DIR);

foreach $subdir (@subdirs)
{
	if($subdir eq '.' or $subdir eq '..' or index($subdir,$targetid) < 0)
	{
		next;
	}
	@tmp = split(/\_/,$subdir);
	if(@tmp <3)
	{
		next;
	}
	$server = $tmp[1];
	
	$modeldir = "$test_dir/$subdir/$server";
	if(!(-d $modeldir))
	{
		next;
	}
	
	print "\n---------------------------------------------------------------------------------------------------\n";
	print "Evaluating $server:\n";
	opendir(FILES,"$modeldir") || die "Failed to open directory $modeldir\n";
	@files = readdir(FILES);
	closedir(FILES);
	foreach $file (@files)
	{
		if($file eq '.' or $file eq '..' or index($file,'.pdb') < 0)
		{
			next;
		}	
		
		$predict_file = "$modeldir/$file";
		$benchmark_file = "$benchmark_dir/$targetid/meta_$file";
		
		if(!(-e $benchmark_file))
		{
			next;
		}
		
		### evaluate two pdb
		$command1="$GLOBAL_PATH/tools/tm_score/TMscore_32 $predict_file $benchmark_file";
		@result1=`$command1`;


		$tmscore=0;
		$maxscore=0;
		$gdttsscore=0;
		$rmsd=0;
		foreach $ln2 (@result1){
			chomp($ln2);
			if ("RMSD of  the common residues" eq substr($ln2,0,28)){
				$s1=substr($ln2,index($ln2,"=")+1);
				while (substr($s1,0,1) eq " ") {
					$s1=substr($s1,1);
				}
				$rmsd=1*$s1;
			}
			if ("TM-score" eq substr($ln2,0,8)){
				$s1=substr($ln2,index($ln2,"=")+2);
				$s1=substr($s1,0,index($s1," "));
				$tmscore=1*$s1;
			}
			if ("MaxSub-score" eq substr($ln2,0,12)){
				$s1=substr($ln2,index($ln2,"=")+2);
				$s1=substr($s1,0,index($s1," "));
				$maxscore=1*$s1;
			}
			if ("GDT-score" eq substr($ln2,0,9)){
				$s1=substr($ln2,index($ln2,"=")+2);
				$s1=substr($s1,0,index($s1," "));
				$gdttsscore=1*$s1;
			}
		}

		print "\t$predict_file -> GDT-TS: $gdttsscore	TM-score: $tmscore	RMSD: $rmsd\n";

	}
	
	print "done\n";
	print "---------------------------------------------------------------------------------------------------\n\n";
	sleep(1);
}




