#!/usr/bin/perl -w

#Perl library for prosys system
#Author: Jianlin Cheng

sub round
{
	#round to 3 digits
	my $value = $_[0];
	$value *= 1000;
	$value = int($value + 0.5);
	$value /= 1000; 
	return $value; 
}

#call: $value = &cosine(\@x,\@y)
sub cosine
{
	my ($x, $y) = @_;
	my $res = 0; 
	my $x_ave = 0;
	my $y_ave = 0;
	my $xy = 0; 
	my $size = @$x; 
	if ($size != @$y) { die "size of two profiles doesn't equal in cosine.\n"; }; 
	my $x_len = 0;
	my $y_len = 0; 
	for (my $i = 0; $i < $size; $i++)
	{
		$x_ave += $x->[$i]; 	
		$y_ave += $y->[$i]; 
		$xy += $x->[$i] * $y->[$i]; 
	}
	$x_ave /= $size; $y_ave /= $size; 
	for (my $i = 0; $i < $size; $i++)
	{
		#$x_len += ($x->[$i] - $x_ave) * ($x->[$i] - $x_ave); 
		#$y_len += ($y->[$i] - $y_ave) * ($y->[$i] - $y_ave); 
		$x_len += ($x->[$i] * $x->[$i]); 
		$y_len += ($y->[$i] * $y->[$i]); 
	}
	$x_len = sqrt($x_len); 
	$y_len = sqrt($y_len); 
	if ($x_len * $y_len == 0)
	{
		$res = 0; 
	}
	else
	{
		$res = $xy / ($x_len * $y_len); 
	}
	if ($res < 0)
	{
		$res = 0; 
	}
	if ($res > 1)
	{
		$res = 1; 
	}
	return $res; 

}

#call: $value = &dotproduct(\@x,\@y)
sub dotproduct 
{
	my ($x, $y) = @_;
	my $xy = 0; 
	my $size = @$x; 
	if ($size != @$y) { die "size of two profiles doesn't equal in cosine.\n"; }; 
	for (my $i = 0; $i < $size; $i++)
	{
		$xy += $x->[$i] * $y->[$i]; 
	}
	return $xy; 

}

#call: $value = &correlation(\@x,\@y)
sub correlation
{
	my ($x, $y) = @_;
	my $res = 0; 
	my $x_ave = 0;
	my $y_ave = 0;
	my $xy = 0; 
	my $size = @$x; 
	if ($size != @$y) { die "size of two profiles doesn't equal in correlation.\n"; }; 
	my $x_len = 0;
	my $y_len = 0; 
	for (my $i = 0; $i < $size; $i++)
	{
		$x_ave += $x->[$i]; 	
		$y_ave += $y->[$i]; 
	}
	$x_ave /= $size; $y_ave /= $size; 
	for (my $i = 0; $i < $size; $i++)
	{
		$x_len += ($x->[$i] - $x_ave) * ($x->[$i] - $x_ave); 
		$y_len += ($y->[$i] - $y_ave) * ($y->[$i] - $y_ave); 
		$xy += ($x->[$i] - $x_ave) * ($y->[$i] - $y_ave); 
	}
	$x_len = sqrt($x_len); 
	$y_len = sqrt($y_len); 

	if ($x_len * $y_len == 0)
	{
		$res = 0; 
	}
	else
	{
		$res = $xy / ($x_len * $y_len); 
	}
	if ($res < -1)
	{
		$res = -1; 
	}
	if ($res > 1)
	{
		$res = 1; 
	}
	return $res; 
}

#entropy for a vector 
#call: &entropy(\@x);
sub entropy
{
	my $x = $_[0];
	my $ent = 0; 
	for (my $i = 0; $i < @$x; $i++)
	{
		my $prob = $x->[$i]; 
		if ($prob > 0)
		{
			$ent -= ($prob * log($prob));  
		}
	}
	return $ent; 
}

#compute e-value
#call: $value = &expdist(\@x,\@y)
sub expdist
{
	my ($x, $y) = @_;
	my $res = 0; 
	my $size = @$x; 
	if ($size != @$y) { die "size of two profiles doesn't equal in correlation.\n"; }; 
	my $dist = 0;
	for (my $i = 0; $i < $size; $i++)
	{
		$dist += ($x->[$i] - $y->[$i])** 2; 
	}
	my $edist = exp(-sqrt($dist));
}

$aa_str = "ACDEFGHIKLMNPQRSTVWY";

sub gen_compo
{
	#support degree 1, 2
	my ($seq, $degree) = @_; 
	$seq = uc($seq); 
	my $len = length($seq);
	my @comp = ();
	if ($degree == 1)
	{
		for (my $i = 0; $i < 20; $i++)
		{
			$comp[$i] = 0; 
		}
		for (my $i = 0; $i < $len; $i++)
		{
			my $aa = substr($seq, $i, 1);
			my $idx = index($aa_str, $aa);
			if ($idx >= 0)
			{
				$comp[$idx] += (1/$len);
			}
		}
		return @comp;
	}
	elsif ($degree == 2)
	{
		#there are 400 possibility (direction is important)
		for (my $i = 0; $i < 400; $i++)
		{
			$comp[$i] = 0; 
		}

		#from N to C terminal
		for (my $i = 1; $i < $len; $i++)
		{
			my $amer = substr($seq, $i-1, 1);
			my $idxa = index($aa_str, $amer);
			my $bmer = substr($seq, $i, 1);	
			my $idxb = index($aa_str, $bmer);

			if ($idxa >= 0 && $idxb >= 0)
			{
				$idx = $idxa * 20 + $idxb; 
				$comp[$idx] += (1 / ($len - 1)); 
			}
		}
		return @comp; 
	}
}

#support format: fasta, nine, ten, cmap, bmap
sub read_seq
{
	my ($file, $format) = @_;
	open(FILE, $file) || die "can't read file: $file\n";
	my $seq = ""; 
	if ($format eq "fasta")
	{
		<FILE>;
		$seq = <FILE>;
		chomp $seq;
	}
	elsif ($format eq "nine" or $format eq "ten")
	{
		<FILE>;
		<FILE>;
		$seq = <FILE>;
		chomp $seq;
		$seq =~ s/\s//g;
	}
	elsif ($format eq "cmap" || $format eq "bmap")
	{
		<FILE>;
		$seq = <FILE>;
		chomp $seq; 
	}
	else
	{
		close FILE;
		die "unsupported format.\n";
	}
	close FILE;
	return $seq; 
}

sub read_msa
{
	my ($seq, $msa_file) = @_;
	my @msa = (); 
	open(MSA, $msa_file) || die "can't read msa file: $msa_file\n";
	my @set = <MSA>;
	close MSA;
	my $num = shift @set;
	if ($num != @set)
	{
		die "number of msa doesn't match.\n";
	}
	push @msa, $seq;
	my $entry = "";
	foreach $entry (@set)
	{
		chomp $entry;
		$entry =~ s/\.//g;
		my $is_found = 0;
		my $record = "";
		foreach $record (@msa)
		{
			if ($entry eq $record)
			{
				$is_found = 1; 
				last;
			}
		}
		if ($is_found == 0)
		{
			push @msa, $entry; 	
		}
	}
	return @msa; 
}

#gen_fam_compo(\@msa, degree)
sub gen_fam_compo
{
	my ($msa, $degree) = @_;

	#number of sequence in msa
	my $size = @$msa; 

	#total length of sequences in  msa
	my $total = 0;
	for (my $i = 0; $i < $size; $i++)
	{
		$total += length($msa->[$i]);
	}
	my @comp = ();
	if ($degree == 1)
	{
		for (my $i = 0; $i < 20; $i++)
		{
			$comp[$i] = 0; 
		}
	}
	elsif ($degree == 2)
	{
		#there are 400 possibility (direction is important)
		for (my $i = 0; $i < 400; $i++)
		{
			$comp[$i] = 0; 
		}
	}
	else
	{
		die "unsupported degree.\n";
	}
	my $seq = ""; 
	foreach $seq (@$msa)
	{
		$seq = uc($seq); 
		my $len = length($seq);
		if ($degree == 1)
		{
			for (my $i = 0; $i < $len; $i++)
			{
				my $aa = substr($seq, $i, 1);
				my $idx = index($aa_str, $aa);
				if ($idx >= 0)
				{
					$comp[$idx] += (1/$total);
				}
			}
		}
		elsif ($degree == 2)
		{
			for (my $i = 1; $i < $len; $i++)
			{
				my $amer = substr($seq, $i-1, 1);
				my $idxa = index($aa_str, $amer);
				my $bmer = substr($seq, $i, 1);	
				my $idxb = index($aa_str, $bmer);

				if ($idxa >= 0 && $idxb >= 0)
				{
					$idx = $idxa * 20 + $idxb; 
					$comp[$idx] += (1 / ($total - $size)); 
				}
			}
		}
	}

	return @comp; 
}

#support format: fasta, nine, ten, cmap, bmap
#get_seq(\@content, $format)
sub get_seq
{
	my ($content, $format) = @_;

	my $seq = ""; 
	if ($format eq "fasta")
	{
		$seq = $content->[1];
		chomp $seq;
	}
	elsif ($format eq "nine" or $format eq "ten")
	{
		$seq = $content->[2];
		chomp $seq;
		$seq =~ s/\s//g;
	}
	elsif ($format eq "cmap" || $format eq "bmap")
	{
		$seq = $content->[1];
		$seq = <FILE>;
		chomp $seq; 
	}
	else
	{
		die "unsupported format.\n";
	}
	return $seq; 
}


#return value
1;
