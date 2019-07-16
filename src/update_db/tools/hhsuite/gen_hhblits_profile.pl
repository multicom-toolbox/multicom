#!/usr/bin/perl -w
#######################################################################
#Generate hhblits profile (both a3m and hmm) for a list of sequences
#Input: hhsuite dir, #cpu cores, database, input fasta file, output dir
#output: name.a3m and name.hmm
#Author: Jianlin Cheng
#Date: Jan. 27, 2011
#######################################################################

if (@ARGV != 6)
{
	die "need five parameters: hhsuite dir, # cpu cores, secondary structure dir, hhblits database, input file (in fasta format), output dir.\n";
}

$hhsuite_dir = shift @ARGV;
$cpu_num = shift @ARGV;
$ss_dir = shift @ARGV; 
$hhblits_db = shift @ARGV;
$input_file = shift @ARGV;
$output_dir = shift @ARGV;

-d $hhsuite_dir || die "can't find $hhsuite_dir.\n";
-d $output_dir || die "can't find $output_dir.\n";
-d $ss_dir || die "can't find $ss_dir.\n";

$ENV{HHLIB}="$hhsuite_dir/lib/hh";


open(INPUT, $input_file) || die "can't open $input_file.\n";
@fasta = <INPUT>;
close INPUT;

$seq_num = 0; 
while (@fasta)
{
	$name = shift @fasta;
	$seq = shift @fasta;

	chomp $name;
	$name = substr($name, 1);
	#check if the output file exist. if so, nothing needs to be done.		
	if (-f "$output_dir/$name.a3m" && -f "$output_dir/$name.hhm")
	{
		warn "The hhblits profile files for $name exist. Skip.\n";
		next;
	}
	$seq_num++; 
	print "Generate hhblits profile for $seq_num: $name\n";

	open FASTA, ">$name.fasta" || "cannot create $name.fasta\n";
	print FASTA ">$name\n$seq";
	close FASTA;

	#generate a3m multiple sequence alignment 
#	print("$hhsuite_dir/bin/hhblits -cpu $cpu_num -i $name.fasta -d $hhblits_db -oa3m $output_dir/$name.a3m -n 2\n");
	system("$hhsuite_dir/bin/hhblits -cpu $cpu_num -i $name.fasta -d $hhblits_db -oa3m $output_dir/$name.a3m -n 2");


	#generate profile
	if (-f "$output_dir/$name.a3m")
	{
		system("$hhsuite_dir/bin/hhmake -i $output_dir/$name.a3m -o $output_dir/$name.hhm");  
		`rm $name.hhr $name.fasta`; 
	}
	else
	{
		next;
	}

	#get ss file
	$ss_file = "$ss_dir/$name.seq";
	if (-f $ss_file)
	{
	

		$seq_file = $ss_file;
		$hhm_file = "$output_dir/$name.hhm";

		open(SEQ, $seq_file) || die "can't read $seq_file.\n";
		<SEQ>;
		<SEQ>;
		<SEQ>;
		<SEQ>;
		<SEQ>;
		<SEQ>;
		$ss = <SEQ>;
		chomp $ss;
		close SEQ;

		#remove blank
		$ss =~ s/ //g;
		#replace . with C.
		$ss =~ s/\./C/g;

		open(HHM, $hhm_file) || die "can't read $hhm_file.\n";
		@hhm = <HHM>;
		close HHM;

		open(SHHM, ">$output_dir/$name.shhm");

		while (@hhm)
		{
			$line = shift @hhm;
			print SHHM $line;
			if ($line =~ /^SEQ/)
			{
				#get length of secondary structure	
				$len = length($ss);			

				print SHHM ">ss_dssp\n";
				for ($i = 1; $i <= $len; $i++)
				{
					print SHHM substr($ss, $i-1, 1);
					if ($i % 100 == 0 || $i == $len)
					{
						print SHHM "\n";
					}
				}

				print SHHM ">ss_pred\n";
				$ss =~ s/[GI]/H/g;
				$ss =~ s/B/E/g;
				$ss =~ s/[TS]/C/g;
				for ($i = 1; $i <= $len; $i++)
				{
					print SHHM substr($ss, $i-1, 1);
					if ($i % 100 == 0 || $i == $len)
					{
						print SHHM "\n";
					}
				}

				print SHHM ">ss_conf\n";
				for ($i = 1; $i <= $len; $i++)
				{
					print SHHM "9";
					if ($i % 100 == 0 || $i == $len)
					{
						print SHHM "\n";
					}
				}

			}	
		}


		`mv $output_dir/$name.shhm $output_dir/$name.hhm`; 

	}
		
}

