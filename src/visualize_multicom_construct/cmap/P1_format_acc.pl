$num =@ARGV;
if($num != 2)
{
	die "The number of parameter is not correct!\n";
}

$inputfile = $ARGV[0];
$outputfile = $ARGV[1];

open(IN,$inputfile) || die "Failed to open file $inputfile\n";
open(OUT,">$outputfile") || die "Failed to write $outputfile\n";
@content = <IN>;
close IN;
shift @content;
shift @content;
$line = shift @content;
chomp $line;
$results = substr($line,index($line,'(precision)')+length('(precision)'));
$results =~ s/^\s+|\s+$//g;
@tmp = split (/\s+/,$results);
$Top5=$tmp[0];    
$TopL10 =$tmp[1];
$TopL5=$tmp[2];
$TopL2=$tmp[3];
$TopL=$tmp[4];     
$Top2L=$tmp[5];

print OUT "Long-Range Precision\n";
print OUT "TopL/5 $TopL5\n";
print OUT "TopL/2 $TopL2\n";
print OUT "TopL $TopL\n";
print OUT "Top2L $Top2L\n";
