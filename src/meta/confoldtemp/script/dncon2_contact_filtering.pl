#!/usr/bin/perl -w
use POSIX;
#use strict;
#use warnings;
use Carp;
use Cwd 'abs_path';
#use File::Basename;
#use Getopt::Long;
if (@ARGV != 2) {
  print "Usage: <input> <output>\n";
  exit;
}

#perl /home/casp13/test/dncon2_contact_filtering.pl /home/casp13/MULTICOM_package/test/1JQE-A4_hard/dncon2/1JQE-A.dncon2.rr /home/casp13/MULTICOM_package/test/1JQE-A4_hard/dncon2/1JQE-A.dncon2_filtering.rr 




my $contact_file = $ARGV[0]; # /storage/htc/bdm/Collaboration/jh7x3/Abinitio_casp13/Benchmark_dataset/CASP11/input/CONSIP2
my $template_rr_file = $ARGV[1]; # /storage/htc/bdm/Collaboration/jh7x3/Abinitio_casp13/Benchmark_dataset/CASP11/input/Domain_CONSIP2
my $contact_output_file = $ARGV[1]; # /storage/htc/bdm/Collaboration/jh7x3/Abinitio_casp13/Benchmark_dataset/CASP11/input/Domain_CONSIP2


my $seq = seq_rr($contact_file);
## opeining files
# contact map
open(IN2,"<$contact_file") or die "Couldn't open rr file file, $!";
@content3=<IN2>;
close IN2;
open(OUT1,">$contact_output_file")or die "Couldn't write SS file file, $!";
my %residues2prob=();
foreach $line (@content3)
{
	chomp $line;
	@string2=split(' ',$line);
	if(@string2 != 5 or index($line,'REMARK')>=0)
	{
	  next;
	}

	$S=$string2[0];
	$F=$string2[1];
	$prob=$string2[4];
	$diff=abs($S-$F);
	if($diff<6){
	  next
	}
	else {
		$line=join " ",@string2;
		$residues2prob{$line} = $prob;
		#push(@residues, "$line");
		 #print OUT1 "$line\n";
	}         
}

@num_contact = keys %residues2prob;
$inx=0;
$batch_quantity = @num_contact / 10;
print OUT1 "REMARK Quantile Res1_pos Res1 Res2_pos Res2 Score\n";
print OUT1 "PFRMAT RR\n";
# print OUT1 "TARGET $protein\n";
print OUT1 "MODEL 1\n";
print OUT1 "$seq\n";
foreach $line (sort {$residues2prob{$b} <=> $residues2prob{$a}}  keys %residues2prob)
{
	$inx++;
	$batch_indx = int($inx / $batch_quantity)+1;
	if($batch_indx>10)
	{
		$batch_indx=10;
	}
	print OUT1 $batch_indx." ".$line."\n";
}
print OUT1 "END\n";
close OUT1;

sub seq_rr{
	my $rr_file = shift;
	confess "ERROR! Input file $rr_file does not exist!" if not -f $rr_file;
	my $seq;
	open RR, $rr_file or confess "ERROR! Could not open $rr_file! $!";
	while(<RR>){
		chomp $_;
		$_ =~ s/\r//g; # chomp does not remove \r
		$_ =~ s/^\s+//;
		$_ =~ s/\s+//g;
		next if ($_ =~ /^>/);
		next if ($_ =~ /^PFRMAT/);
		next if ($_ =~ /^TARGET/);
		next if ($_ =~ /^AUTHOR/);
		next if ($_ =~ /^SCORE/); 
		next if ($_ =~ /^REMARK/);
		next if ($_ =~ /^METHOD/);
		next if ($_ =~ /^MODEL/); 
		next if ($_ =~ /^PARENT/);
		last if ($_ =~ /^TER/);   
		last if ($_ =~ /^END/);
		# Now, I can directly merge to RR files with sequences on top
		last if ($_ =~ /^[0-9]/);
		$seq .= $_;
	}
	close RR;
	if(not defined $seq)
	{
		$seq='NULL';
	}
	confess "Input RR file does not have sequence row!\nRR-file : $rr_file\nPlease make sure that all input RR files have sequence headers!" if not defined $seq;
	return $seq;

}
sub wrap_seq{
	my $seq = shift;
	confess ":(" if !$seq;
	my $seq_new = "";
	while($seq){
		if(length($seq) <= 50){
			$seq_new .= $seq;
			last;
		}
		$seq_new .= substr($seq, 0, 50)."\n";
		$seq = substr($seq, 50);
	}
	return $seq_new;
}

