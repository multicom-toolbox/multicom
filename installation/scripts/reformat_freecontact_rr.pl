$num = @ARGV;
if($num !=2)
{
	die "The parameter is not correct!\n";
}

$infile = $ARGV[0];
$outfile = $ARGV[1];

open(IN,$infile) || die "Failed to open file $infile\n";
open(OUT,">$outfile") || die "Failed to open file $outfile\n";
%rr_hash = ();
while(<IN>)
{
	$li = $_;
	chomp $li;
	@tmp = split(/\s+/,$li);
	if(@tmp != 6)
	{
		next;
	}
	$score = $tmp[5];
	if($score < 0)
	{
		$score =0;
	}
	$rr_hash{$tmp[0]." ".$tmp[2]." 0 8 ".$score} = $score;
}
foreach $line (sort { $rr_hash{$b} <=> $rr_hash{$a} } keys %rr_hash) {
	chomp $line;
	print OUT "$line\n";
}
close OUT;
