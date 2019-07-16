#!/usr/bin/perl -w
#########################################################################
#check if the profile (.fas) contains all standard amino acids
#########################################################################

if (@ARGV != 1)
{
	die "need: input profile file\n"; 
}
$prof_file = shift @ARGV; 

$stdaa = "ACDEFGHIKLMNPQRSTVWY";

@filter = ();

open(PROF, $prof_file) || die "can't open $prof_file\n";
@prof = <PROF>;
close PROF; 

$name =  shift @prof;
$seq = shift @prof;
push @filter, $name;
push @filter, $seq;

while (@prof)
{
	$name = shift @prof;
	$seq = shift @prof; 

	chomp $seq; 
	@amino_acids = split(//, $seq);	

	#check if each amino acid is a standard one
	$num =  @amino_acids; 

	$illegal = 0; 	
	for ($i = 0; $i < $num; $i++)
	{
		$aa = $amino_acids[$i]; 
		if ($aa ne "-")
		{
			if (index($stdaa, $aa) < 0)
			{
				$illegal = 1; 
				#convert non-standard amino acid to "-"
				$amino_acids[$i] = "-";
			#	last; 
			}	
		}
	}

	if ($illegal == 1)
	{
		$seq = join("", @amino_acids); 
	}

	push @filter, $name;
	push @filter, "$seq\n";
}

open(PROF, ">$prof_file") || die "can't write $prof_file\n";
print PROF @filter;
close PROF; 




