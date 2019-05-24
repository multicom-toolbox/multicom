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



open(IN2,"<$template_rr_file") or die "Couldn't open rr file file, $!";
@content3=<IN2>;
close IN2;
my %template_result=();
foreach $line (@content3)
{
	chomp $line;
	@string2=split(' ',$line);
	if(@string2 != 6 or index($line,'Quantile')>=0 or index($line,'REMARK')>=0)
	{
	  next;
	}
	
	$batch=$string2[0]; #1 23 L 29 H 0.27082
	$res1id=$string2[1];
	$s2=$string2[2];
	$res2id=$string2[3];
	$s4=$string2[4];
	$prob=$string2[5];

	if(exists($template_result{"$res1id $res2id"}))	
	{
		die "Duplicate residue pair <$res1id $res2id> in file $template_rr_file\n";
	}else{
		$template_result{"$res1id $res2id"} = "$res1id $res2id 0 8 $prob";
	}
}


open(OUT1,">$contact_output_file")or die "Couldn't write SS file file, $!";
print OUT1 "REMARK dncon2 contact prediction refined by template\n";
print OUT1 "PFRMAT RR\n";
# print OUT1 "TARGET $protein\n";
print OUT1 "MODEL 1\n";
print OUT1 "$seq\n";

open(IN2,"<$contact_file") or die "Couldn't open rr file file, $!";
@content3=<IN2>;
close IN2;
my %dncon2_result=();


### start modified the dncon2 prediction
$refine_num=0;
%dncon2_result=();
foreach $line (@content3)
{
	chomp $line;
	@string2=split(' ',$line);
	if(@string2 != 6 or index($line,'Quantile')>=0 or index($line,'REMARK')>=0)
	{
	  next;
	}
	
	$batch=$string2[0]; #1 18 32 0 8 0.06554
	$s1=$string2[1];
	$s2=$string2[2];
	$s3=$string2[3];
	$s4=$string2[4];
	$prob=$string2[5];

	
	if(exists($dncon2_result{"$s1 $s2"}))	
	{
		die "Duplicate residue pair <$s1 $s2> in file $contact_file\n";
	}else{
		$dncon2_result{"$s1 $s2"} = "$s1 $s2 $s3 $s4 $prob";
	}
	
	
	if(exists($template_result{"$s1 $s2"}))	
	{
		$info = $template_result{"$s1 $s2"};
		@tmp=split(' ',$info);
		$prob_temp = pop @tmp;
		if($prob_temp > $prob)
		{
			$refine_num ++;
			print "Probability of Residue pair <$s1 $s2> are modified from $prob to $prob_temp\n";
			$prob = $prob_temp;
		}
		
		
	}
	print OUT1 "$s1 $s2 $s3 $s4 $prob\n";
}


### end additional template contact 
foreach $line (keys %template_result)
{
	$info = $template_result{$line};
	
	if(exists($dncon2_result{$line}))	
	{
		next;
	}else{
		print "Probability of Residue pair <$info> from templates are added\n";
		print OUT1 $info."\n";
	}
	
}
print OUT1 "END\n";
close OUT1;


print "\n\n!!! The refined contact are saved in $contact_output_file\n";






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

