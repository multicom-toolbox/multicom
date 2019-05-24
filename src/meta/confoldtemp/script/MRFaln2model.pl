#!/usr/bin/perl -w
#perl /home/casp13/test/MRFaln2model.pl /home/casp13/test/T0859_146220581027331/full_length_hard/raptorx/3ptwA-T0859.fasta  ./ T0859  ./3ptwA-T0859.pir

our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;

$numArgs = @ARGV;
if($numArgs != 5)
{   
	print "the number of parameters is not correct!\n";
	exit(1);
}

$alignf		= "$ARGV[0]";	#the target sequence file
$RaptorXout		= "$ARGV[1]";	#output folder
$targetid		= "$ARGV[2]";	#target ID
$pirout		= "$ARGV[3]";	#alignment out
$pvalue		= "$ARGV[4]";	#pvalue



print "Processing $alignf\n";
open(TMP,$alignf) || die "Failed to open file $alignf\n";
open(TMPOUT,">$RaptorXout/tmpalign") || die "Failed to open file $RaptorXout/tmpalign\n";
while(<TMP>)
{
	$line = $_;
	chomp $line;
	if(substr($line,0,1) eq '>')
	{
		print TMPOUT $line."\t";
	}else{
		print TMPOUT $line."\n";
	}
	
}
close TMP;
close TMPOUT;
open(TMP,"$RaptorXout/tmpalign") || die "Failed to open file $RaptorXout/tmpalign\n";
$template = ();
$query = ();
$template_name = "";
while(<TMP>)
{
	$line = $_;
	chomp $line;
	if(substr($line,0,1) ne '>')
	{
		next;
	}
	@temp = split(/\t/,$line);
	$id = substr($temp[0],1);
	$seq = $temp[1];
	if(index($id,$targetid) >=0)
	{
		$query{$id} = $seq;
	}else{
		$template{$id} = $seq;
		$template_name = $id;
	}
	
}
close TMP;
#$pirout = $RaptorXout."/".$template_name."_".$targetid.".pir";
$top1_pdb = "/home/casp13/tools/RaptorX4/CNFsearch1.66/databases/pdb_BC100/".$template_name.'.pdb';
if(-e $top1_pdb)
{
	print "Checking template structure file\n";
}else{
	die "Structure file for $template_name doesn't exist!\n";
}

open INPUTPDB, $top1_pdb or die "ERROR! Could not open $top1_pdb";
@lines_PDB2 = <INPUTPDB>;
close INPUTPDB;
$chainidStart = "";
$chainidnameStart = "";
$chainidEnd = "";
$chainidnameEnd = "";
$resnum = "";
$ATOMseq = "";
$index_row = 0;
%res_CA = ();
foreach (@lines_PDB2) {
	next if $_ !~ m/^ATOM/;
	#print $_."\n";
	$row = $_;
	$index_row++;
	$chainid = substr($row,21,1);
	$chainid =~ s/\s+//g;
	$resnum = substr($row,22,5);
	$resnum =~ s/\s+//g;
	$aaname = substr($row,12,4);
	$aaname =~ s/\s+//g;
	$resname = substr($row,17,3);
	$resname =~ s/\s+//g;
	if($index_row == 1)
	{
		$chainidStart = $resnum;
		$chainidnameStart = $chainid;
	}else{
		$chainidEnd = $resnum;
		$chainidnameEnd = $chainid;
	}
	if($aaname eq 'CA')
	{
		if(!exists($res_CA{$resnum}))
		{
			$ATOMseq .=$AA3TO1{$resname};
			$res_CA{$resnum} = $AA3TO1{$resname};
		}
	}
}			

$aligntmp = $RaptorXout.'/'.$template_name.'_seq_pdb_align.fa';
open(TMP,">$aligntmp") || die "Failed to open file $aligntmp\n";
print TMP ">ATOMSEQ\n$ATOMseq\n";

foreach $id (keys %template)
{
	$templatealignment_seq = $template{$id};
	print TMP ">$id\n$templatealignment_seq\n";
}	
close TMP;

## align the template sequence with its atom sequence 
system("/home/casp13/deepsf_3d/deepsf3d_tools/clustalw1.83/clustalw $aligntmp");
$aligntmpout = $RaptorXout.'/'.$template_name.'_seq_pdb_align.aln';
if(!(-e $aligntmpout))
{
	die "Failed to generate $aligntmpout\n";
}
open(INFILE,"$aligntmpout") || die "Failed to generate $aligntmpout\n";
$atom_aln = "";
$newtemplate_aln = "";
while(<INFILE>)
{
	$line = $_;
	if(index($line,'ATOMSEQ') >=0)
	{
		@content = split(/\s+/,$line);
		$atom_aln .=  $content[1];
	}
	if(index($line,$template_name) >=0)
	{
		@content = split(/\s+/,$line);
		$newtemplate_aln .=  $content[1];
	}
}
close INFILE;
if(length($newtemplate_aln) != length($atom_aln))
{
	die "atom/template align doesn't match $newtemplate_aln  --- $atom_aln\n";
}
## checking the match 
$query_seq = $query{$targetid};
if(length($newtemplate_aln) <= length($templatealignment_seq))
{
	$leng = length($templatealignment_seq);
}else{
	$leng = length($newtemplate_aln);
}
$final_atom_aln = $atom_aln;
for($i=0;$i<$leng;$i++)
{
	$atomaln_res = substr($final_atom_aln,$i,1);
	$newaln_res = substr($newtemplate_aln,$i,1);
	$oldaln_res = substr($templatealignment_seq,$i,1);
	$query_res = substr($query_seq,$i,1);
	if($newaln_res eq $oldaln_res)
	{
		next;
	}elsif($newaln_res eq '-')
	{
		$templatealignment_seq = substr($templatealignment_seq,0,$i).'-'.substr($templatealignment_seq,$i);
		$query_seq = substr($query_seq,0,$i).'-'.substr($query_seq,$i);
	}elsif($oldaln_res eq '-')
	{
		$final_atom_aln = substr($final_atom_aln,0,$i).'-'.substr($final_atom_aln,$i);
	}
	
}

## make upper case name in order to get consensus template statistics
open(TMP,">$pirout") || die "Failed to open file $pirout\n";
$pid = uc($template_name);
print TMP "C;cover size:0; local alignment length=0 (original info = $pid 0 0 $pvalue 0)\n";
print TMP ">P1;".$pid."\nstructureN:$pid: $chainidStart: $chainidnameStart: $chainidEnd: $chainidnameEnd: : : :\n".$final_atom_aln."*\n\n";

print TMP "C;query\n>P1;".$targetid."\n : : : : : : : : : \n".$query_seq."*\n";
close TMP;


`rm $aligntmp $aligntmpout $RaptorXout/*dnd $RaptorXout/tmpalign`;