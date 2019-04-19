use strict;
open(IN, "../T0388_casp8.seq");
while(<IN>){
	my $line = $_;
	$line =~ s/\n//;
	$line =~ s/\s+$//;
	my $length = length($line);
	print $length."\n";
}
close(IN);
