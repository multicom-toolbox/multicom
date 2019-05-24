#!/usr/bin/perl -w

## cd /home/casp13/confold2_template/T0859_weak_temp 
## perl /home/casp13/confold2_template/get_weak_template_rr.pl /home/casp13/confold2_template/T0859_weak_temp /home/casp13/confold2_template/T0859_146220581027331/full_length_hard  /home/casp13/confold2_template/T0859_146220581027331/T0859.fasta  T0859

$numArgs = @ARGV;
if($numArgs != 4)
{   
	print "the number of parameters is not correct!\n";
	exit(1);
}
use Carp;
our %AA3TO1 = qw(ALA A ASN N CYS C GLN Q HIS H LEU L MET M PRO P THR T TYR Y ARG R ASP D GLU E GLY G ILE I LYS K PHE F SER S TRP W VAL V);
our %AA1TO3 = reverse %AA3TO1;
$outfolder	= "$ARGV[0]";
$multicom_dir	= "$ARGV[1]";
$seqfile	= "$ARGV[2]";
$targetid	= "$ARGV[3]";

$evalue_cutoff = 100000;

if(!(-d $outfolder))
{
	`mkdir $outfolder`;;
}

open(IN1, $seqfile) || die("Couldn't open file $seqfile\n"); 
@seqarray=<IN1>;
close IN1;
shift @seqarray;
$fasta_seq = shift @seqarray;
chomp $fasta_seq;

$construct_dir = "$multicom_dir/construct";

$rankf2="$construct_dir/construct.rank";
if(!(-e $rankf2))
{
	print "Failed to find folder $rankf2\n";
	exit;
}

#hhblit and hhblit3 has template unmatch, ignore
#@servers = ("hmmer3","hhsuite3","raptorx");
@servers = ("hhsuite","hmmer3","hhsearch15","raptorx");


print "\n**************************************************\n";

### Copy the top 5 model to TOP5/ and named as casp*.pdb

$flag=0;
$c2=0;


###
## Extract the template information in all templates, including evalue, sequence, name for finding the hard region in top 5 models 
###
$validTop5_num = 0;
$alignment_info = []; # multi array to record alignment information $alignment->[1][0]: alignment file, [1][1]: focus on single(e>0.1) or multiple(e<0.1), [1][2]: template info, [1][3]: target info
$c=0;

$tmpfile_check = "$outfolder/CHECK/";
if(-d $tmpfile_check)
{
	system("rm -rf $tmpfile_check/*");
}else{
	system("mkdir $tmpfile_check");
}

$alignment_info = []; # multi array to record alignment information $alignment->[1][0]: alignment file, [1][1]: focus on single(e>0.1) or multiple(e<0.1), [1][2]: template info, [1][3]: target info
foreach $server (@servers) {
    
	$server_dir = "$multicom_dir/$server";
	if(!(-d $server_dir))
	{
		print "Failed to find directory $server_dir\n\n";
		next;
	}
	opendir(DIR,"$server_dir") || die "Failed to open directory $server_dir\n";
	@pirs = readdir(DIR);
	closedir(DIR);
	
	### since raptorx has pdb and sequence alignment issue, need preprocess first 
	
	if( $server eq 'raptorx')
	{
	
		print "!!! Processing raptorx alignments\n\n";
		
		$rank_file = "$server_dir/$targetid.rank";
		open(RANK, $rank_file) || die "can't read $rank_file.\n";
		@rank = <RANK>;
		close RANK;

		%temp2pvalues = (); 
		foreach $rank_line (@rank)
		{	
			chomp $rank_line;
			if(index( $rank_line,'templates')>=0)
			{
				next;
			}
		
			($id, $template_id, $pvalue) = split(/\s+/, $rank_line);
					
			$temp2pvalues{$template_id}=$pvalue;

		}


		$indx=0;
		foreach $pir (@pirs)
		{
			if($pir eq '.' or $pir eq '..' or index($pir,'.fasta') <0 or index($pir,$targetid) <0) #3ua3A-1JQE-A.fasta
			{
				next;
			}
			$model1name=substr($pir,0,index($pir,".fasta"));
			$alignf = $server_dir."/".$model1name.".fasta";
			$cnfpred = $server_dir."/".$model1name.".cnfpred";
			if(!(-e $alignf) or !(-e $cnfpred))
			{
				next;
			}
			
			$tmpid = uc(substr($model1name,0,index($model1name,'-')));
			if(!exists($temp2pvalues{$tmpid}))
			{
				die "Error: $tmpid in $pir should be in $rank_file\n";
			}
			$pvalue = $temp2pvalues{$tmpid};
			
			print "Processing $alignf\n";
			$indx++;
			$pirout = $tmpfile_check."/${server}_raptorx".$indx.".pir";
			$status = system("perl /home/casp13/confold2_template/scripts/MRFaln2model.pl  $alignf $tmpfile_check  $targetid $pirout $pvalue");
			if($status)
			{
				die "failed to run MRFaln2model.pl  $alignf\n";
			}		
		}
		print "\n\n!!! Finish raptorx alignments, loading rest multicom alignments\n\n";
	}
	
	
	foreach $pir (@pirs)
	{
		if($pir eq '.' or $pir eq '..' or substr($pir, length($pir)-4) ne '.pir')
		{
			next;
		}
		
		if($server eq 'hmmer3')
		{
			if(index($pir,'jackhmmer')<0)
			{
				next;
			}
		}elsif($server eq 'hhsuite3')
		{
			if(index($pir,'hhsu')<0)
			{
				next;
			}
		}elsif($server eq 'hhsuite')
		{
			if(index($pir,'hhsuite')<0 and  index($pir,'super')<0)
			{
				next;
			}
		}elsif($server eq 'hhsearch15')
		{
			if(index($pir,'ss')<0)
			{
				next;
			}
		}elsif($server eq 'raptorx')
		{
			next;
			
		}else{
			next;
		}
		$model1pir=$server_dir."/".$pir;
		`cp $model1pir $tmpfile_check/${server}_$pir`;
		
	}
}
opendir(DIR,"$tmpfile_check") || die "Failed to open directory $tmpfile_check\n";
@pirs = readdir(DIR);
closedir(DIR);

foreach $pir (@pirs)
{
	if($pir eq '.' or $pir eq '..' or index($pir,'.pir') <0)
	{
		next;
	}
	$model1name_info=substr($pir,0,index($pir,".pir")); #jackhmmer1.pir
	@array_tmp = split(/\_/,$model1name_info);
	$server = $array_tmp[0];
	$model1name = $array_tmp[1];
	$alignment_info -> [$c2][0] = "$server|".$model1name;

	$alignfile="";
	$aligntarget="";
	$aligntemp="";
	$id="";
	$c=0;
	$k=0;
	
	$template_info = []; # record template information, $template_info->[1][0]: name, [1][1]: evalue, [1][2]: sequence, [1][3]: structure info 

	$model1pir=$tmpfile_check."/".$model1name_info.".pir";
	$alignfile=$model1pir;
	print "\ncheck $model1pir\n";

	open(IN1, $model1pir) || die("Couldn't open file $model1pir\n"); 
	@aalignf=<IN1>;
	close IN1;
	$c=0;
	$tem_id = 0;
=pod
	if(index($model1name,'raptorx')>=0) #muster has no evalue 
	{
		# record the evalue of each template
		$c=0;
		foreach $line (@aalignf){
			chomp($line);
			$c++;
			if ($c%5==1) {
				
				if(index($line,'C;query') >= 0)
				{
					last;
				}else{
					$template_info -> [$tem_id][1]=0.1; # mark raptorx low evalue 
					$alignment_info -> [$c2][1] = 'significant';
					next;
				}
			}
			if ($c%5==2) {
				$id = substr($line,1);
				$id =~ s/\s+//g;
				$template_info -> [$tem_id][0]=$id;
			}
			if ($c%5==3) {
				$template_info -> [$tem_id][3]=$line;
			}
			if ($c%5==4) {
				$align_template = $line;
				$template_info -> [$tem_id][2]=$align_template;
				$tem_id ++;
			}
		}	
		
	#}else
	#{
=cut
		# record the evalue of each template
		$c=0;
		foreach $line (@aalignf){
			chomp($line);
			$c++;
			if ($c%5==1) {
				
				if(index($line,'C;cover') < 0 and index($line,'C;template') < 0)
				{
					last;
				}
				if(index($line,'C;cover') >= 0)
				{
					$info = substr($line,rindex($line,'original info'));
					$info =~ s/[()]//g;
				}elsif(index($line,'C;template') >= 0)
				{
					$info = substr($line,rindex($line,'original info'));
					$info =~ s/[()]//g;
				}
				print "Processing $info\n";
				$info = substr($info,length('original info = '));
				@temp = split(/\t/,$info);
				if(@temp != 5 )
				{
					@temp = split(/\s/,$info); #raptorx/rapt6.pir original info = 3PTWA 0 0 0.01723 0
					if(@temp != 5 )
					{
						print "Warn: wrong format, should have 5 elemens\n";
					}
				}
				$template_name_intitle = $temp[0];
				#$template_name_intitle = substr($template_name_intitle,length('original info = '));
				$info =~ s/\s+//g;
				$evalue = $temp[3];
				if($tem_id == 0 and $evalue >= 0.1)
				{
					$alignment_info -> [$c2][1] = 'hard';
				}elsif($tem_id == 0 and $evalue < 0.1)
				{
					$alignment_info -> [$c2][1] = 'significant';
				}
				$template_info -> [$tem_id][1]=$evalue;
		
			}
			if ($c%5==2) {
				$template_name = $line;
				@temp = split(';',$template_name);
				$id = $temp[1];
				$id =~ s/\s+//g;
				if(index($id,$template_name_intitle)>= 0 ) # because sometime in title, the id is 4fdwA, however, if multiple region in one sequence are in alignment, the second one should be 4fdwA1
				{
					$template_info -> [$tem_id][0]=$id;
				}else{						
					die "The template id name ($id) doesn't match with title $template_name_intitle\n";
				}
			}
			if ($c%5==3) {
				$template_struct = $line;
				$template_info -> [$tem_id][3]=$template_struct;
			}
			if ($c%5==4) {
				$align_template = $line;
				$template_info -> [$tem_id][2]=$align_template;
				$tem_id ++;
			}
		}
	#}
	$c=0;
	foreach $line (@aalignf){
		chomp($line);
		$c++;
		if ($c%5==4) {
			$aligntarget=$line;
		}
	}
	
	$alignment_info -> [$c2][2] = $template_info;
	$alignment_info -> [$c2][3] = $aligntarget;
	$c2++;
}
	
#print @$alignment_info."\n";


%all_templates_list = ();  # this can be used to avoid typo in construct.rank


#$alignment_info = []; multi array to record alignment information $alignment->[1][0]: alignment file, [1][1]: focus on single(e>0.1) or multiple(e<0.1), [1][2]: template info, [1][3]: target sequence
#$template_info = []; record template information, $template_info->[1][0]: name, [1][1]: evalue, [1][2]: sequence
for($i = 0;$i<@$alignment_info;$i++) {  
	$alignment_file = $alignment_info->[$i][0];
	$single_multiple = $alignment_info->[$i][1];
	$template_info = $alignment_info->[$i][2];
	$target_info = $alignment_info->[$i][3];
	for($j = 0;$j<@$template_info;$j++) { 
		$template_name = $template_info->[$j][0];
		$template_evalue = $template_info->[$j][1];
		$template_sequence = $template_info->[$j][2];
		$template_struct = $template_info->[$j][3];
		#print $j.":\t".$template_sequence."\t".$alignment_file."\t".$single_multiple."\t".$template_name."\t".$template_evalue."\t".$template_struct."\n";
	
		$all_templates_list{$template_name}=1;
	}
	#print "\nQ:\t".$target_info."\tTarget\n\n\n";
}

## save the all templates information and sorted them by evalue	
@aid=();
@ap=();
$tem_index=0;
for($ali_id = 0;$ali_id<@$alignment_info;$ali_id++) {  
	$alignment_file = $alignment_info->[$ali_id][0];
	$single_multiple = $alignment_info->[$ali_id][1];
	$template_info = $alignment_info->[$ali_id][2];
	$target_info = $alignment_info->[$ali_id][3];
	for($temp_j = 0;$temp_j<@$template_info;$temp_j++) { 
		$template_name = $template_info->[$temp_j][0];
		$template_evalue = $template_info->[$temp_j][1];
		$template_sequence = $template_info->[$temp_j][2];									
		$template_struct = $template_info->[$temp_j][3];
		$aid[$tem_index] = $alignment_file."\t".$template_name."\t".$template_evalue."\t".$template_sequence."\t".$target_info."\t".$template_struct;
		$ap[$tem_index] = $template_evalue;
		$tem_index++;		
	}
}
#sort
for($tem_i=0;$tem_i<$tem_index-1;$tem_i++)
{
	for($tem_j=$tem_i+1;$tem_j<$tem_index;$tem_j++)
	{
		if($ap[$tem_i]>$ap[$tem_j])
		{
			$t = $ap[$tem_i];
			$ap[$tem_i] = $ap[$tem_j];
			$ap[$tem_j]= $t;
			
			$t = $aid[$tem_i];
			$aid[$tem_i] = $aid[$tem_j];
			$aid[$tem_j]= $t;						
		}
	}
}

$tmpfile_align = "$outfolder/All_templates_rank.txt";
open(ALIGN,">$tmpfile_align") || die "Failed to open file $tmpfile_align\n";
print ALIGN "Alignment_file\tTemplate_name\tTemplate_evalue\tTemplate_align\tTarget_align\tTemplate_structure\n";	
foreach (@aid) {
  print ALIGN "$_\n";
}
close ALIGN; 

### based on the construct.rank and $outfolder/All_templates_rank.txt, 


print "\n\nStart searching construct rank $rankf2\n\n";
open(IN2, "$rankf2") || die("Couldn't open file $rankf2\n"); 
@arank2=<IN2>;
close IN2;


#### need manually add raptorx template 
open(ALIGN,"$tmpfile_align") || die "Failed to open file $tmpfile_align\n";
while(<ALIGN>)
{
	$info = $_;
	chomp $info;
	@tmp2 = split(/\t/,$info);
	$template_name = $tmp2[0];
	$template_check = $tmp2[1];
	$evalue_check = $tmp2[2];
	$template_aln = $tmp2[3];
	$target_aln = $tmp2[4];
	$template_str_info = $tmp2[5]; #structureN:4FIBB: 1: : 118: : : :6.0:
	if($evalue_check eq 'Template_evalue')## sometimes the construct.rank has incorrect information
	{
		next;
	}
	if($evalue_check > $evalue_cutoff)
	{
		next;
	}
	@tmp3 = split(/\|/,$template_name);
	$servername = $tmp3[0];
	if($servername eq 'raptorx')
	{
		$rapinfo = "0\t$template_check\t$evalue_check";
		push @arank2, $rapinfo;
	}
	
	
}
close ALIGN;


$tmpfile_out = "$outfolder/All_templates_resPair.txt";
$tmpfile_out2 = "$outfolder/All_templates_resPair.statistics";
open(OUT,">$tmpfile_out") || die "Failed to open file $tmpfile_out\n";
open(OUT2,">$tmpfile_out2") || die "Failed to open file $tmpfile_out2\n";
print OUT "res1_idx res1 res2_idx res2 res1_template_idx res1_temp res2_template_idx res2_temp distance template_name alignment evalue_check\n";
$select=0;
%pair_statistis=();
foreach $line (@arank2)
{
	chomp $line;
	if(index($line,'Template')>=0)
	{
		next;
	}
	$select++;
	
	## how many number of template in construct rank to choose
	if($select>10)
	{
		last;
	}
	@tmp = split(/\t/,$line);
	$template = $tmp[1];
	
	if(!exists($all_templates_list{$template})) ## sometimes the construct.rank has incorrect information
	{
		next;
	}
	
	open(ALIGN,"$tmpfile_align") || die "Failed to open file $tmpfile_align\n";
	while(<ALIGN>)
	{
		$info = $_;
		chomp $info;
		@tmp2 = split(/\t/,$info);
		$template_name = $tmp2[0];
		@tmp3 = split(/\|/,$template_name);
		$temp_server = $tmp3[0];
		$template_check = $tmp2[1];
		$evalue_check = $tmp2[2];
		$template_aln = $tmp2[3];
		$target_aln = $tmp2[4];
		$template_str_info = $tmp2[5]; #structureN:4FIBB: 1: : 118: : : :6.0:
		if($evalue_check eq 'Template_evalue')## sometimes the construct.rank has incorrect information
		{
			next;
		}
		if($template_check  ne  $template or $evalue_check > $evalue_cutoff)
		{
			next;
		}
		print "Processing $template --> $evalue_check\n";
		if (substr($template_aln,length($template_aln)-1) eq "*") {
			$template_aln = substr($template_aln,0,length($template_aln)-1);
		}
		if (substr($target_aln,length($target_aln)-1) eq "*") {
			$target_aln = substr($target_aln,0,length($target_aln)-1);
		}
		$target_seq = $target_aln;
		$template_seq = $template_aln;
		$target_seq =~ s/\-//g;
		$template_seq =~ s/\-//g;
		
		if($target_seq ne $fasta_seq)
		{
			die "$info has non-equal fasta sequence\n$target_seq\n$fasta_seq\n"
		}
		if(length($target_aln) != length($template_aln))
		{
			die "$info has non-equal aligned sequence\n$target_aln\n$template_aln\n"
		}
		
		@str_info = split(':',$template_str_info);
		$str_start = $str_info[2];
		$str_end = $str_info[4];
		
		$str_start =~s/\s//g;
		$str_end =~s/\s//g;
		$str_len =$str_end-$str_start+1; 
		if(length($template_seq) != $str_len)
		{
			print  "\n\nWarning: $info has non-equal structure sequence\n$template_seq\n".length($template_seq)."\n$str_len\n\n";
			next;;
		}
		
		%res2info=();
		$found_pdb = 0;
		foreach $server (@servers) 
		{
			if($temp_server ne $server)
			{
				next;
			}
			$pdbfile = "$multicom_dir/$server/$template_check.atm";
			if($server eq 'raptorx')
			{	 
				$tmpname = lc($template_check);# 1MLAA --> 1mlaA
				$tmpname = substr($tmpname,0,length($tmpname)-1).uc(substr($tmpname,length($tmpname)-1));
				$pdbfile = "/home/casp13/tools/RaptorX4/CNFsearch1.66/databases/pdb_BC100/$tmpname.pdb";
			}
			if(-e $pdbfile)
			{
				
				open INPUTPDB, $pdbfile or die "ERROR! Could not open $pdbfile";
				my @lines_PDB = <INPUTPDB>;
				close INPUTPDB;
				$this_rchain="";
				foreach (@lines_PDB) {
					next if $_ !~ m/^ATOM/;
					next unless (parse_pdb_row($_,"aname") eq "CA");
					$rname = $AA3TO1{parse_pdb_row($_,"rname")};
					$rnum = parse_pdb_row($_,"rnum");
					$res_x = parse_pdb_row($_,"x");
					$res_y = parse_pdb_row($_,"y");
					$res_z = parse_pdb_row($_,"z");
					if(exists($res2info{$rnum}))
					{
						print "duplicate CA atom for ($rname) $rnum in pdb $pdbfile\n\n";
						next;
					}else{
						$res2info{$rnum} = "$rname|$res_x|$res_y|$res_z";
					}
				}
				$found_pdb = 1;
				
				last;
			}
		}
		
		if($found_pdb == 0)
		{
			die "Failed to find pdb file for $template_check under folder $multicom_dir\n\n";
		}
		### get residue pair
		$res1_idx=0;
		$res2_idx=0;
		
		$res1_template_idx=$str_start-1;
		$res2_template_idx=$str_start-1;
		
		for($i=0;$i < length($target_aln); $i++)
		{
			## check if this residue has been aligned in template
			$res2_template_idx = $res1_template_idx;
			$res2_idx = $res1_idx;
			$res1_temp = substr($template_aln,$i,1);
			$res1 = substr($target_aln,$i,1);
			if($res1 eq '-' and $res1_temp eq '-')
			{
				next;
			}elsif($res1 eq '-' and $res1_temp ne '-')
			{
				$res1_template_idx++;
				$res2_template_idx++;
				next;
			}elsif($res1 ne '-' and $res1_temp eq '-')
			{
				$res1_idx++;
				$res2_idx++;
				next;
			}elsif($res1 ne '-' and $res1_temp ne '-')
			{
				$res1_idx++;
				$res2_idx++;
				$res1_template_idx++;
				$res2_template_idx++;
			}
			
			
			for($j=$i+1;$j < length($target_aln); $j++)
			{
				## check if this residue has been aligned in template
				$res2_temp = substr($template_aln,$j,1);
				$res2 = substr($target_aln,$j,1);
					
				if($res2 eq '-' and $res2_temp eq '-')
				{
					next;
				}elsif($res2 eq '-' and $res2_temp ne '-')
				{
					$res2_template_idx++;
					next;
				}elsif($res2 ne '-' and $res2_temp eq '-')
				{
					$res2_idx++;
					next;
				}elsif($res2 ne '-' and $res2_temp ne '-')
				{
					$res2_idx++;
					$res2_template_idx++;
				}
				
				## record pair information 
				#print "$res1_template_idx($res1_temp)  --> $res2_template_idx($res2_temp)\n\n";
				
				
				### check if res index are correct
				if(!exists($res2info{$res2_template_idx}))
				{
					die "Failed to find res2_template_idx: $res2_template_idx in pdb $pdbfile\n\n";
				}else{
					#$res2info{$rnum} = "$rname|$res_x|$res_y|$res_z";
					@tmpinfo = split(/\|/,$res2info{$res2_template_idx});
					$rname = $tmpinfo[0];
					if($rname ne $res2_temp)## check if alignment name matches the structure name
					{
						die "2: $res2_template_idx 's residue in alignment is $res2_temp, but in structure is $rname in $pdbfile\n$info\n";
					}
					$res2_x=$tmpinfo[1];
					$res2_y=$tmpinfo[2];
					$res2_z=$tmpinfo[3];
				}
				
				if(!exists($res2info{$res1_template_idx}))
				{
					die "Failed to find res1_template_idx: $res1_template_idx in pdb $pdbfile\n\n";
				}else{
					#$res2info{$rnum} = "$rname|$res_x|$res_y|$res_z";
					@tmpinfo = split(/\|/,$res2info{$res1_template_idx});
					$rname = $tmpinfo[0];
					if($rname ne $res1_temp)## check if alignment name matches the structure name
					{
						die "1: $res1_template_idx 's residue in alignment is $res1_temp, but in structure is $rname in $pdbfile\n$info\n"; 
					}
					$res1_x=$tmpinfo[1];
					$res1_y=$tmpinfo[2];
					$res1_z=$tmpinfo[3];
				}
				
				#print "$res1_x,$res1_y,$res1_z\t$res2_x,$res2_y,$res2_z\n";
				$distance = sprintf("%.3f",sqrt(($res2_x-$res1_x)*($res2_x-$res1_x) + ($res2_y-$res1_y)*($res2_y-$res1_y) + ($res2_z-$res1_z)*($res2_z-$res1_z)));
				if($distance >8 or  ($res2_idx - $res1_idx) < 6)
				{
					next;
				}
				if(exists($pair_statistis{"$res1_idx $res1 $res2_idx $res2"}))
				{
					$pair_statistis{"$res1_idx $res1 $res2_idx $res2"}++;
				}else{
					$pair_statistis{"$res1_idx $res1 $res2_idx $res2"}=1;
				}
				print OUT "$res1_idx $res1 $res2_idx $res2 $res1_template_idx $res1_temp $res2_template_idx $res2_temp $distance $template_check $template_name $evalue_check\n";


			}
		}
		
	}
	close ALIGN; 
}
close OUT;
#### get pair distance from template 

$norm_min=0.1;
$norm_max=0.99;
$mini=10000;
$maxi=0;
foreach $line (sort {$pair_statistis{$b} <=> $pair_statistis{$a}}  keys %pair_statistis)
{
	$num = $pair_statistis{$line};
    $mini=$num if $num<$mini;
    $maxi=$num if $num>$maxi;
	print OUT2 $line." ".$pair_statistis{$line}."\n";
}
close OUT2;


#### perform min-max normalization
print "#### perform min-max normalization\n";

print "Min: $mini  Max: $maxi Range: [$norm_min,$norm_max]\n";


$tmpfile_out3 = "$outfolder/All_templates_resPair.statistics_norm";
open(OUT,">$tmpfile_out3") || die "Failed to open file $tmpfile_out3\n";


@num_contact = keys %pair_statistis;

$batch_quantity = @num_contact / 10;

$inx=0;
print OUT "Quantile Res1_pos Res1 Res2_pos Res2 Score\n";
foreach $line (sort {$pair_statistis{$b} <=> $pair_statistis{$a}}  keys %pair_statistis)
{
	$num = $pair_statistis{$line};
	
	$result = sprintf("%.5f",($num - $mini) * ($norm_max - $norm_min) / ($maxi - $mini) + $norm_min);
	#print OUT $line." ".$result."\n";
	
	$inx++;
	$batch_indx = int($inx / $batch_quantity)+1;
	if($batch_indx>10)
	{
		$batch_indx=10;
	}
	print OUT $batch_indx." ".$line." ".$result."\n";
}
close OUT;



$tmpfile_out = "$outfolder/All_templates_resPair.txt";
$tmpfile_out2 = "$outfolder/All_templates_resPair.statistics";

print "\n\n########### contact prediction from templates are done\nChecking $tmpfile_out\nChecking $tmpfile_out2\nChecking $tmpfile_out3\nChecking $rankf2\n\n";

sub parse_pdb_row{
	my $row = shift;
	my $param = shift;
	my $result;
	$result = substr($row,6,5) if ($param eq "anum");
	$result = substr($row,12,4) if ($param eq "aname");
	$result = substr($row,16,1) if ($param eq "altloc");
	$result = substr($row,17,3) if ($param eq "rname");
	$result = substr($row,22,5) if ($param eq "rnum");
	$result = substr($row,21,1) if ($param eq "chain");
	$result = substr($row,30,8) if ($param eq "x");
	$result = substr($row,38,8) if ($param eq "y");
	$result = substr($row,46,8) if ($param eq "z");
	die "Invalid row[$row] or parameter[$param]" if (not defined $result);
	$result =~ s/\s+//g;
	return $result;
}