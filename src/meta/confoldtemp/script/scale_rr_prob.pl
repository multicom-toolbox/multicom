#!/usr/bin/perl -w
use POSIX;
#use strict;
#use warnings;
use Carp;
use Cwd 'abs_path';
#use File::Basename;
#use Getopt::Long;
if (@ARGV != 3) {
  print "Usage: <input> <output>\n";
  exit;
}

#perl /home/casp13/test/dncon2_contact_filtering.pl /home/casp13/MULTICOM_package/test/1JQE-A4_hard/dncon2/1JQE-A.dncon2.rr /home/casp13/MULTICOM_package/test/1JQE-A4_hard/dncon2/1JQE-A.dncon2_filtering.rr 

#perl /home/casp13/test/scale_rr_prob.pl /home/casp13/MULTICOM_package/test/1JQE-A4_hard/dncon2/1JQE-A.dncon2.rr /home/casp13/MULTICOM_package/test/1JQE-A4_hard/dncon2/1JQE-A.dncon2_filtering.rr 


my $contact_file = $ARGV[0]; # 
my $template_rr_file = $ARGV[1]; # 
my $contact_output_file = $ARGV[2]; # 

my $seq = seq_rr($contact_file);


open(IN2,"<$contact_file") or die "Couldn't open rr file file, $!";
@content3=<IN2>;
close IN2;
my %dncon2_batch2prob=();
my %dncon2_batch2prob_num=();
foreach $line (@content3)
{
	chomp $line;
	@string2=split(' ',$line);
	if(@string2 != 6 or index($line,'Quantile')>=0 or index($line,'REMARK')>=0)
	{
	  next;
	}

	$batch=$string2[0];
	$prob=$string2[5];

	if(exists($dncon2_batch2prob{$batch}))	
	{
		$dncon2_batch2prob{$batch} += $prob;
		$dncon2_batch2prob_num{$batch} += 1;
	}else{
		$dncon2_batch2prob{$batch} = $prob;
		$dncon2_batch2prob_num{$batch} = 1;
	}
}



open(IN2,"<$template_rr_file") or die "Couldn't open rr file file, $!";
@content3=<IN2>;
close IN2;
my %template_batch2prob=();
my %template_batch2prob_num=();
foreach $line (@content3)
{
	chomp $line;
	@string2=split(' ',$line);
	if(@string2 != 6 or index($line,'Quantile')>=0 or index($line,'REMARK')>=0)
	{
	  next;
	}

	$batch=$string2[0];
	$prob=$string2[5];

	if(exists($template_batch2prob{$batch}))	
	{
		$template_batch2prob{$batch} += $prob;
		$template_batch2prob_num{$batch} += 1;
	}else{
		$template_batch2prob{$batch} = $prob;
		$template_batch2prob_num{$batch} = 1;
	}
}

%dncon2_batch2prob_avg = ();
foreach $batch (keys %dncon2_batch2prob)
{
	$prob_sum = $dncon2_batch2prob{$batch};
	$prob_num = $dncon2_batch2prob_num{$batch};
	#print  "dncon2 --> $batch\n";
	$dncon2_batch2prob_avg{$batch} = $prob_sum/$prob_num;
}

%template_batch2prob_avg = ();
foreach $batch (keys %template_batch2prob)
{
	$prob_sum = $template_batch2prob{$batch};
	$prob_num = $template_batch2prob_num{$batch};
	#print  "template --> $batch\n";
	$template_batch2prob_avg{$batch} = $prob_sum/$prob_num;
}





open(OUT1,">$contact_output_file")or die "Couldn't write SS file file, $!";
open(IN2,"<$template_rr_file") or die "Couldn't open rr file file, $!";
@content3=<IN2>;
close IN2;
print OUT1 "REMARK Quantile Res1_pos Res1 Res2_pos Res2 Score\n";
print OUT1 "PFRMAT RR\n";
# print OUT1 "TARGET $protein\n";
print OUT1 "MODEL 1\n";
print OUT1 "$seq\n";
foreach $line (@content3)
{
	chomp $line;
	@string2=split(' ',$line);
	if(@string2 != 6 or index($line,'Quantile')>=0)
	{
	  next;
	}

	$batch=$string2[0];
	$s1=$string2[1];
	$s2=$string2[2];
	$s3=$string2[3];
	$s4=$string2[4];
	$prob=$string2[5];

	if(exists($template_batch2prob_avg{$batch}) and exists($dncon2_batch2prob_avg{$batch}))	
	{
		$prob_scale =  sprintf("%.5f",$prob * $dncon2_batch2prob_avg{$batch})/$template_batch2prob_avg{$batch};
		$line = "$batch $s1 $s2 $s3 $s4 $prob_scale";
		print OUT1 $line."\n";
	}else{
		die "Failed to find batch number $batch\n\n";
	}

  
 
}
print OUT1 "END\n";
close OUT1;


print "\n\nScaling done, saved  $contact_output_file\n\n";
=pod
print OUT1 "PFRMAT RR\n";
# print OUT1 "TARGET $protein\n";
print OUT1 "MODEL 1\n";
print OUT1 "$seq\n";
print OUT1 join("\n",@residues),"\n";
print OUT1 "END\n";
close OUT1;
=cut
#}  
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

