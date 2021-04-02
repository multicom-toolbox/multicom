
$num = @ARGV;
if($num != 2)
{
	die "The number of parameter is not correct!\n";
}
$aln_summary = $ARGV[0];
$aln_summary_msa = $ARGV[1];

###### convert global pir to global alignment for visualization on website
open(MSA, ">$aln_summary_msa") || die("Couldn't open file $aln_summary_msa\n"); 
open(MARKER, ">$aln_summary_msa.marker") || die("Couldn't open file $aln_summary_msa.marker\n"); 
open(IN1, $aln_summary) || die("Couldn't open file $aln_summary\n"); 
@aalignf_tmp=<IN1>;
close IN1;
$c_tmp=0;
$aligntarget_tmp="";
$aligntarget_info="";
$aligntarget_id="";
foreach $line_tmp (@aalignf_tmp){
	chomp($line_tmp);
	$c_tmp++;
	if ($c_tmp%5==1) {
			$aligntarget_info=$line_tmp;
	}
	if ($c_tmp%5==2) {
                        $aligntarget_id=$line_tmp;
        }
	if ($c_tmp%5==4) {
		$aligntarget_tmp=$line_tmp;
	}
}
#print "$aligntarget_id\n";
@temp = split(';',$aligntarget_id);
$qid = $temp[1];
$coverage = 0;# this is not the global msa coverage
if(index($aligntarget_info,'cover_ratio:')>0)
{
	$coverage = substr($aligntarget_info,index($aligntarget_info,'cover_ratio:')+12,index($aligntarget_info,'cover:')-index($aligntarget_info,'cover_ratio:')-12);
	$coverage =~ s/^\s+|\s+$//g;
}
#print MSA ">$qid|cov:$coverage\n$aligntarget_tmp\n";
print MSA ">$qid\n$aligntarget_tmp\n";
$aligntarget_tmp_new = $aligntarget_tmp;
$aligntarget_tmp_new =~ s/\-//g;
$fasta_len = length($aligntarget_tmp_new);
print MARKER "1-$fasta_len\t$qid\t(Length: 1-$fasta_len)\n";
$id_tmp="";
$start_region="";
$end_region="";
$temp_index=0;
$c_tmp=0;
foreach $line_tmp (@aalignf_tmp){
	chomp($line_tmp);
	$c_tmp++;
	if ($c_tmp%5==2) {
		@temp = split(';',$line_tmp);
		$id_tmp = $temp[1];
		$id_tmp =~ s/\s+//g;
	}
	if ($c_tmp%5==3) {
		@temp = split(':',$line_tmp);
		$start_region = $temp[2];
		$start_region =~ s/^\s+|\s+$//g;
		$end_region = $temp[4];
		$end_region =~ s/^\s+|\s+$//g;
	}
	if ($c_tmp%5==4) {
		if ($id_tmp ne $qid) {
			$aligntemp=$line_tmp;
			$temp_index++;
			print MSA ">$id_tmp|pos:$start_region-$end_region\n$aligntemp\n";
			($range) = get_align_region_annotation($aligntarget_tmp, $id_tmp, $aligntemp);
			@tmp2 = split('-',$range);
			$len = $tmp2[1]-$tmp2[0]+1;
			if($len > 5)
			{
				print MARKER "$range\t$id_tmp\t(alignment: $range)\n";
			}
		}
	}
}
close MSA;


sub get_align_region_annotation{
	my $target_align = shift;
	my $temp_name = shift;
	my $temp_align = shift;
	
	$label="";
	if(substr($target_align,length($target_align)-1) eq '*')
	{
		$target_align = substr($target_align,0,length($target_align)-1);
	}
	if(substr($temp_align,length($temp_align)-1) eq '*')
	{
		$temp_align = substr($temp_align,0,length($temp_align)-1);
	}
	for($i =0;$i<length($target_align);$i++)
	{
		$target_tmp = substr($target_align,$i,1);
		$temp_tmp = substr($temp_align,$i,1);
		if($target_tmp eq '-')
		{
			next;
		}
		
		if($temp_tmp eq '-')
		{
			$label .="0";
		}else{
			$label .= "1";
		}
	}
	
	$start = 0;
	for($i =0;$i<length($label);$i++)
	{
		if(substr($label,$i,1) eq '1')
		{
			$start = $i;
			last;
		}
	}
	$start += 1;
	$end = 0;
	for($i =length($label)-1;$i>=0;$i--)
	{
		if(substr($label,$i,1) eq '1')
		{
			$end = $i;
			last;
		}
	}
	$end += 1;

	return ("$start-$end");
}


