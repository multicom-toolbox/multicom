$num = @ARGV;
if($num != 2)
{
	die "The number of parameter is not correct!\n";
}
$inputfile = $ARGV[0];
$outputfile = $ARGV[1];

open(IN, "$inputfile") || die("Couldn't open file $inputfile\n"); 
open(OUT, ">$outputfile") || die("Couldn't open file $outputfile\n"); 
while(<IN>)
{
	$line = $_; #domain 0:1-47
	chomp $line;
	if ($line =~ /^[0-9]/)
	{
		@tmp = split(/\s+/,$line);
		if(abs($tmp[1]-$tmp[0])>= 6)
		{
			print OUT "$line\n";
		}
	}else{
		print OUT "$line\n";
	}
}
close IN;
close OUT;