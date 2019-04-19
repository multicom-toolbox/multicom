#!/usr/bin/perl -w
#########################################################################
#Compute the palign profile alignment score (with or without ss info)
#Currently, does not support SS. 
#Input: script_dir, psiblast dir, query file(fasta), query chk file, 
# target file(fasta), output file
#Output: score, evalue, and alignments (local alignments)
#depend on: cm_parse_blast.pl
#Author: Jianlin Cheng
#Date: 5/4/2005
#bug fix: logarithm of 0.
#9/6/2005, Jianlin Cheng.
#########################################################################
if (@ARGV != 6)
{
	die "need six parameters: script_dir, blast dir, query file(fasta), query chk file, target file(fasta), ouptut file.\n";
}
$script_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";

$blast_dir = shift @ARGV;
-d $blast_dir || die "can't find palignp dir.\n";
if (!-f "$blast_dir/blastpgp")
{
	die "can't find blastpgp executable file.\n";
}

$query_fasta = shift @ARGV;
-f $query_fasta || die "can't find query fasta file.\n";
open(QUERY, $query_fasta);
$code1 = <QUERY>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY;
$query_length = length($seq1);

$query_chk = shift @ARGV;
-f $query_chk || die "can't find query chk file.\n";

$target_fasta = shift @ARGV;
-f $target_fasta || die "can't find target fasta file.\n";

open(TARGET, $target_fasta);
$code2 = <TARGET>;
chomp $code2; 
$code2 = substr($code2, 1);
$seq2 = <TARGET>;
chomp $seq2; 
close QUERY;
$out_file = shift @ARGV;


#create target database using target fasta file
system("$blast_dir/formatdb -i $target_fasta");


#do prof-seq alignment using psiblast 
#we set a very larget e-value, so it always return something
system("$blast_dir/blastpgp -i $query_fasta -R $query_chk -o $out_file.blast -e 1000 -d $target_fasta 2>/dev/null");
#print("$blast_dir/blastpgp -i $query_fasta -R $query_chk -o $out_file.blast -e 1000 -d $target_fasta\n");

#read and parse alignment results here : $out_file.blast
system("$script_dir/cm_parse_blast.pl $out_file.blast $out_file.local");
open(LOCAL, "$out_file.local") || die "can't read blast local alignments.\n";
@local = <LOCAL>;
if (@local < 3)
{

	print "feature num: 5\n";
	print "0", " ", "10", " ", "0", " ", "0", " ", "0", " ", "\n\n"; 
	print  join("", @local); 

	#for each aligned segment: 
	open(OUT, ">$out_file") || die "can't create output file.\n";
	print OUT "feature num: 5\n";
	print OUT "0", " ", "10", " ", "0", " ", "0", " ", "0", " ", "\n\n"; 
	#print OUT $score/$query_length, " ", $evalue, " ", $align_len / $query_length, " ", $int_rate, " ", $pos_rate, " ", "\n\n"; 
	
	print OUT join("", @local); 

#cleanup
	`rm $target_fasta.phr $target_fasta.pin $target_fasta.psq`; 
	`rm $out_file.blast $out_file.local`; 
	die "no local alignments are generated from blast, use default values.\n";
}
close LOCAL;
shift @local;
shift @local;
$max = $local[0]; 
chomp $max;
$tname = $tlen = $gap_rate = "";
($tname, $tlen, $score, $evalue, $align_len, $int_rate, $pos_rate, $gap_rate) = split(/\s+/, $max);
#take a log on evalue
if ($evalue =~ /^e-(\d+)/)
{
	$evalue = "-" . $1; 
}
elsif ($evalue =~ /([\d\.]+)e-(\d+)/)
{
	$evalue = log($1);
	$evalue -= $2; 
}
elsif ($evalue =~ /([\d\.]+)/)
{
	if ($1 > 0)
	{
		$evalue = log($1);
	}
	else  #evalue is 0
	{
		$evalue = -200; 
	}
}
else
{
	die "unknown format of evalue\n"; 
}

print "feature num: 5\n";
print $score/$query_length, " ", $evalue, " ", $align_len / $query_length, " ", $int_rate, " ", $pos_rate, " ", "\n\n"; 
print  join("", @local); 

#for each aligned segment: 
open(OUT, ">$out_file") || die "can't create output file.\n";
print OUT "feature num: 5\n";
print OUT $score/$query_length, " ", $evalue, " ", $align_len / $query_length, " ", $int_rate, " ", $pos_rate, " ", "\n\n"; 
	
print OUT join("", @local); 

#cleanup
`rm $target_fasta.phr $target_fasta.pin $target_fasta.psq`; 
`rm $out_file.blast $out_file.local`; 
`rm formatdb.log`; 

