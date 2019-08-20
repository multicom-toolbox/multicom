#!/usr/bin/perl -w
$num =@ARGV;
if($num != 3)
{
	die "The number of parameter is not correct!\n";
}

$workdir = $ARGV[0];
$targetid = $ARGV[1];
$outputdir = $ARGV[2];


$scripts_dir = '/storage/htc/bdm/jh7x3/multicom/src/visualize_multicom_construct/';
if(!(-d $outputdir))
{
	`mkdir $outputdir`;
}

###### handle full_length proteins
chdir($outputdir);

-d "$outputdir/full_length/" || `mkdir $outputdir/full_length/`;
-d "$outputdir/full_length/Top5_aln/" || `mkdir $outputdir/full_length/Top5_aln/`;
-d "$outputdir/Final_models/" || `mkdir $outputdir/Final_models/`;

$full_length_dir = 'full_length';
if(-d "$workdir/full_length_hard")
{
	$full_length_dir = 'full_length_hard';
}

###### copy basic information
if(!(-e "$workdir/full_length/hhsearch15/$targetid.fasta"))
{
	print "Warning: 0. Failed to find $workdir/full_length/hhsearch15/$targetid.fasta\n";
}else{
	`cp $workdir/full_length/hhsearch15/$targetid.fasta $outputdir/query.fasta`;
	`cp $workdir/full_length/hhsearch15/$targetid.fasta $outputdir/$targetid.fasta`;
	`cp $workdir/full_length/hhsearch15/$targetid.fasta $outputdir/full_length/$targetid.fasta`;
}

	
if(-d "$workdir/full_length_hard" and !(-e "$workdir/domain_info"))
{
	#print out domain information
	open(TMP,"$outputdir/query.fasta");
	@content = <TMP>;
	close TMP;
	shift @content;
	$seq = shift @content;
	chomp $seq;
	open(DOM_DEF, ">$workdir/domain_info");
	print DOM_DEF "domain 0:1-".length($seq)."\n"; 
	close DOM_DEF; 	
}


if(!(-e "$workdir/domain_info"))
{
	print "Warning: 1. Failed to find $workdir/domain_info\n";
}else{
	open(TMP1,"$workdir/domain_info");
	open(OUTMP1,">$outputdir/domain_info");
	while(<TMP1>)
	{
		$tmpa = $_;
		chomp $tmpa;
		if(index($tmpa,'Normal')>0)
		{
			$tmpa = substr($tmpa,0,index($tmpa,'Normal')-1);
			#print "Checking $tmpa\n";
		}
		print OUTMP1 "$tmpa\n";
	}
	close TMP1;
	close OUTMP1;
	`cp $outputdir/domain_info $outputdir/$targetid.domain_info`;
	
	#print "perl $scripts_dir/P4_make_domain_marker.pl $outputdir/$targetid.domain_info $outputdir/$targetid.fasta $outputdir/$targetid.domain_info.marker\n";
	`perl $scripts_dir/P4_make_domain_marker.pl $outputdir/$targetid.domain_info $outputdir/$targetid.fasta $outputdir/$targetid.domain_info.marker`;
	
	
	### create domain marker
	

	#print "python $scripts_dir/P3_Visualize_aln_folds.py $outputdir/$targetid.domain_info.marker $outputdir/$targetid.domain_info.marker.jpeg\n";
	`python $scripts_dir/P3_Visualize_aln_folds.py $outputdir/$targetid.domain_info.marker $outputdir/$targetid.domain_info.marker.jpeg`;


}

if(!(-e "$workdir/full_length/hhsearch15/$targetid.fasta.disorder"))
{
	print "Warning: 2. Failed to find $workdir/full_length/hhsearch15/$targetid.fasta.disorder\n";
}else{
	`cp $workdir/full_length/hhsearch15/$targetid.fasta.disorder $outputdir/full_length/$targetid.fasta.disorder`;
}

if(!(-e "$workdir/full_length/dncon2/ss_sa/$targetid.ss_sa"))
{
	print "Warning: 3. Failed to find $workdir/full_length/dncon2/ss_sa/$targetid.ss_sa\n";
}else{
	`cp $workdir/full_length/dncon2/ss_sa/$targetid.ss_sa $outputdir/full_length/$targetid.ss_sa`;
}

if(!(-e "$workdir/full_length/dncon2/$targetid.dncon2.rr"))
{
	print "Warning: 4. Failed to find $workdir/full_length/dncon2/$targetid.dncon2.rr\n";
}else{
	#print "perl $scripts_dir/N1_clean_dncon_rr.pl   multicom_results/full_length/deep1_contact/4coo.dncon2.rr   multicom_results/full_length/deep1_contact/4coo.dncon2.clean.rr\n"; 
	`cp $workdir/full_length/dncon2/$targetid.dncon2.rr $outputdir/full_length/$targetid.dncon2.rr`;
	#print "perl $scripts_dir/P5_extract_aln_from_dncon.pl $outputdir/full_length/$targetid.dncon2.rr $outputdir/full_length/$targetid.dncon2.rr.stats\n";
	`perl $scripts_dir/P5_extract_aln_from_dncon.pl $outputdir/full_length/$targetid.dncon2.rr $outputdir/full_length/$targetid.dncon2.rr.stats`;
}

####### copy top models
if(-e "$workdir/qa/deepcomb1.pdb")
{
	print "This is multi-domain proteins, copy...\n";
	print "cp $workdir/qa/deepcomb1.pdb $outputdir/full_length/$targetid.deep1.pdb\n";
	`cp $workdir/qa/deepcomb1.pdb $outputdir/full_length/$targetid.deep1.pdb`;
	`cp $workdir/qa/deepcomb1.pdb $outputdir/Final_models/$targetid-1.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep1.pdb > $outputdir/full_length/$targetid-1.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-1.input > $outputdir/full_length/$targetid-1.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-1.ps  $outputdir/full_length/$targetid-1.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-1.pdb > $outputdir/Final_models/$targetid-1.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-1.input > $outputdir/Final_models/$targetid-1.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-1.ps  $outputdir/Final_models/$targetid-1.png`;
	
}elsif(-e "$workdir/qa/deep1.pdb")
{
	`cp $workdir/qa/deep1.pdb $outputdir/full_length/$targetid.deep1.pdb`;
	`cp $workdir/qa/deep1.pdb $outputdir/Final_models/$targetid-1.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep1.pdb > $outputdir/full_length/$targetid-1.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-1.input > $outputdir/full_length/$targetid-1.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-1.ps  $outputdir/full_length/$targetid-1.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-1.pdb > $outputdir/Final_models/$targetid-1.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-1.input > $outputdir/Final_models/$targetid-1.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-1.ps  $outputdir/Final_models/$targetid-1.png`;
}else
{
	print "Warning: 5. Failed to find $workdir/qa/deepcomb1.pdb or $workdir/qa/deep1.pdb\n";
}

if(-e "$workdir/qa/deepcomb2.pdb")
{
	print "This is multi-domain proteins, copy...\n";
	print "cp $workdir/qa/deepcomb2.pdb $outputdir/full_length/$targetid.deep2.pdb\n";
	`cp $workdir/qa/deepcomb2.pdb $outputdir/full_length/$targetid.deep2.pdb`;
	`cp $workdir/qa/deepcomb2.pdb $outputdir/Final_models/$targetid-2.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep2.pdb > $outputdir/full_length/$targetid-2.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-2.input > $outputdir/full_length/$targetid-2.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-2.ps  $outputdir/full_length/$targetid-2.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-2.pdb > $outputdir/Final_models/$targetid-2.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-2.input > $outputdir/Final_models/$targetid-2.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-2.ps  $outputdir/Final_models/$targetid-2.png`;
}elsif(-e "$workdir/qa/deep2.pdb")
{
	`cp $workdir/qa/deep2.pdb $outputdir/full_length/$targetid.deep2.pdb`;
	`cp $workdir/qa/deep2.pdb $outputdir/Final_models/$targetid-2.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep2.pdb > $outputdir/full_length/$targetid-2.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-2.input > $outputdir/full_length/$targetid-2.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-2.ps  $outputdir/full_length/$targetid-2.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-2.pdb > $outputdir/Final_models/$targetid-2.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-2.input > $outputdir/Final_models/$targetid-2.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-2.ps  $outputdir/Final_models/$targetid-2.png`;
}else
{
	print "Warning: 5. Failed to find $workdir/qa/deepcomb2.pdb or $workdir/qa/deep2.pdb\n";
}

if(-e "$workdir/qa/deepcomb3.pdb")
{
	print "This is multi-domain proteins, copy...\n";
	print "cp $workdir/qa/deepcomb3.pdb $outputdir/full_length/$targetid.deep3.pdb\n";
	`cp $workdir/qa/deepcomb3.pdb $outputdir/full_length/$targetid.deep3.pdb`;
	`cp $workdir/qa/deepcomb3.pdb $outputdir/Final_models/$targetid-3.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep3.pdb > $outputdir/full_length/$targetid-3.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-3.input > $outputdir/full_length/$targetid-3.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-3.ps  $outputdir/full_length/$targetid-3.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-3.pdb > $outputdir/Final_models/$targetid-3.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-3.input > $outputdir/Final_models/$targetid-3.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-3.ps  $outputdir/Final_models/$targetid-3.png`;
}elsif(-e "$workdir/qa/deep3.pdb")
{
	`cp $workdir/qa/deep3.pdb $outputdir/full_length/$targetid.deep3.pdb`;
	`cp $workdir/qa/deep3.pdb $outputdir/Final_models/$targetid-3.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep3.pdb > $outputdir/full_length/$targetid-3.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-3.input > $outputdir/full_length/$targetid-3.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-3.ps  $outputdir/full_length/$targetid-3.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-3.pdb > $outputdir/Final_models/$targetid-3.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-3.input > $outputdir/Final_models/$targetid-3.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-3.ps  $outputdir/Final_models/$targetid-3.png`;
}else
{
	print "Warning: 5. Failed to find $workdir/qa/deepcomb2.pdb or $workdir/qa/deep2.pdb\n";
}

if(-e "$workdir/qa/deepcomb4.pdb")
{
	print "This is multi-domain proteins, copy...\n";
	print "cp $workdir/qa/deepcomb4.pdb $outputdir/full_length/$targetid.deep4.pdb\n";
	`cp $workdir/qa/deepcomb4.pdb $outputdir/full_length/$targetid.deep4.pdb`;
	`cp $workdir/qa/deepcomb4.pdb $outputdir/Final_models/$targetid-4.pdb`;
	

	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep4.pdb > $outputdir/full_length/$targetid-4.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-4.input > $outputdir/full_length/$targetid-4.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-4.ps  $outputdir/full_length/$targetid-4.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-4.pdb > $outputdir/Final_models/$targetid-4.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-4.input > $outputdir/Final_models/$targetid-4.ps`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-4.ps  $outputdir/Final_models/$targetid-4.png`;
}elsif(-e "$workdir/qa/deep4.pdb")
{
	`cp $workdir/qa/deep4.pdb $outputdir/full_length/$targetid.deep4.pdb`;
	`cp $workdir/qa/deep4.pdb $outputdir/Final_models/$targetid-4.pdb`;
	

	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep4.pdb > $outputdir/full_length/$targetid-4.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-4.input > $outputdir/full_length/$targetid-4.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-4.ps  $outputdir/full_length/$targetid-4.png`;
	
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-4.pdb > $outputdir/Final_models/$targetid-4.input`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-4.input > $outputdir/Final_models/$targetid-4.ps`;
	#`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-4.ps  $outputdir/Final_models/$targetid-4.png`;
}else
{
	print "Warning: 5. Failed to find $workdir/qa/deepcomb4.pdb or $workdir/qa/deep4.pdb\n";
}

if(-e "$workdir/qa/deepcomb5.pdb")
{
	print "This is multi-domain proteins, copy...\n";
	print "cp $workdir/qa/deepcomb5.pdb $outputdir/full_length/$targetid.deep5.pdb\n";
	`cp $workdir/qa/deepcomb5.pdb $outputdir/full_length/$targetid.deep5.pdb`;
	`cp $workdir/qa/deepcomb5.pdb $outputdir/Final_models/$targetid-5.pdb`;
	

	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep5.pdb > $outputdir/full_length/$targetid-5.input`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-5.input > $outputdir/full_length/$targetid-5.ps`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-5.ps  $outputdir/full_length/$targetid-5.png`;
	
	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-5.pdb > $outputdir/Final_models/$targetid-5.input`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-5.input > $outputdir/Final_models/$targetid-5.ps`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-5.ps  $outputdir/Final_models/$targetid-5.png`;
}elsif(-e "$workdir/qa/deep5.pdb")
{
	`cp $workdir/qa/deep5.pdb $outputdir/full_length/$targetid.deep5.pdb`;
	`cp $workdir/qa/deep5.pdb $outputdir/Final_models/$targetid-5.pdb`;
	

	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/full_length/$targetid.deep5.pdb > $outputdir/full_length/$targetid-5.input`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/full_length/$targetid-5.input > $outputdir/full_length/$targetid-5.ps`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/full_length/$targetid-5.ps  $outputdir/full_length/$targetid-5.png`;
	
	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molauto $outputdir/Final_models/$targetid-5.pdb > $outputdir/Final_models/$targetid-5.input`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/molscript-2.1.2/molscript  -ps  < $outputdir/Final_models/$targetid-5.input > $outputdir/Final_models/$targetid-5.ps`;
	##`/storage/htc/bdm/jh7x3/multicom/tools/ImageMagick-7.0.4-7/bin/convert -density 400 $outputdir/Final_models/$targetid-5.ps  $outputdir/Final_models/$targetid-5.png`;
}else
{
	print "Warning: 5. Failed to find $workdir/qa/deepcomb5.pdb or $workdir/qa/deep5.pdb\n";
}

## check if alignment are found
if(!(-e "$workdir/qa/deep.full"))
{
	print "Warning: 10. Failed to find $workdir/qa/deep.full\n";
}else{
	open(TMP,"$workdir/qa/deep.full");
	$indx = 0;
	while(<TMP>)
	{
		$li=$_;
		chomp $li; 
		if(index($li,'.pdb')<0)
		{
			next;
		}
		$indx++;
		@tmp = split(/\s+/,$li);
		$model = $tmp[0];
		$score = sprintf("%.3f",$tmp[1]);
		@tmp2 = split(/\./,$model);
		$modelname = $tmp2[0];
		$modelpir = "$workdir/$full_length_dir/meta/$modelname.pir";
		open(SCORE,">$outputdir/full_length/Top5_aln/$targetid.deep$indx.deeprank");
		print SCORE "DeepRank score: $score\n";
		close SCORE;
		if(!(-e $modelpir))
		{
			#print "Failed to find $modelpir, this ab initio model\n";
		}else{
			`cp $modelpir $outputdir/full_length/Top5_aln/$targetid.deep$indx.pir`;
			
			#print "perl $scripts_dir/P2_pir2msa_web.pl  $outputdir/full_length/Top5_aln/$targetid.deep$indx.pir  $outputdir/full_length/Top5_aln/$targetid.deep$indx.msa\n";
			`perl $scripts_dir/P2_pir2msa_web.pl  $outputdir/full_length/Top5_aln/$targetid.deep$indx.pir  $outputdir/full_length/Top5_aln/$targetid.deep$indx.msa`;

			#print "python $scripts_dir/P3_Visualize_aln_folds.py $outputdir/full_length/Top5_aln/$targetid.deep$indx.msa.marker $outputdir/full_length/Top5_aln/$targetid.deep$indx.msa.marker.jpeg\n";
			`python $scripts_dir/P3_Visualize_aln_folds.py $outputdir/full_length/Top5_aln/$targetid.deep$indx.msa.marker $outputdir/full_length/Top5_aln/$targetid.deep$indx.msa.marker.jpeg`;


		}
		
		if($indx == 5)
		{
			last;
		}
	}
	close TMP;
}

##### generate contact information
for($indx = 1; $indx <=5; $indx++)
{
	mkdir("$outputdir/full_length/deep${indx}_contact/");
	chdir("$outputdir/full_length/deep${indx}_contact/");
	`cp ../$targetid.fasta ./`;
	`cp ../$targetid.dncon2.rr ./`;
	`cp ../$targetid.deep$indx.pdb  ./`;
	#print "perl $scripts_dir/cmap/coneva-camp.pl  -fasta $targetid.fasta -rr $targetid.dncon2.rr  -pdb $targetid.deep$indx.pdb  -smin 24 -o ./\n";
	`perl $scripts_dir/cmap/coneva-camp.pl  -fasta $targetid.fasta -rr $targetid.dncon2.rr  -pdb $targetid.deep$indx.pdb  -smin 24 -o ./`;
	#print "perl $scripts_dir/cmap/P1_format_acc.pl long_Acc.txt  long_Acc_formated.txt\n";
	`perl $scripts_dir/cmap/P1_format_acc.pl long_Acc.txt  long_Acc_formated.txt`;
}


########### handle domain proteins
$domainfile = "$workdir/domain_info";
open(IN, "$domainfile") || die("Couldn't open file $domainfile\n"); 
@content = <IN>;
close IN;
$domain_num = @content;
if($domain_num>1)
{
	for($domid=0;$domid<$domain_num;$domid++)
	{
		chdir($outputdir);
		-d "$outputdir/domain$domid" || `mkdir $outputdir/domain$domid/`;
		-d "$outputdir/domain$domid/Top5_aln" || `mkdir $outputdir/domain$domid/Top5_aln/`;

		$full_length_dir = "domain$domid";
		###### copy basic information
		if(!(-e "$workdir/domain$domid.fasta"))
		{
			print "Warning: 1. Failed to find $workdir/domain$domid.fasta\n";
		}else{
			`cp $workdir/domain$domid.fasta $outputdir/domain$domid/domain$domid.fasta`;
		}

		if(!(-e "$workdir/$full_length_dir/hhsearch15/$targetid.fasta.disorder"))
		{
			#print "Warning: 2. Failed to find $workdir/$full_length_dir/hhsearch15/domain$domid.fasta.disorder\n";
		}else{
			`cp $workdir/$full_length_dir/hhsearch15/domain$domid.fasta.disorder $outputdir/domain$domid/domain$domid.fasta.disorder`;
		}
		
		if(-e "$workdir/domain$domid/dncon2/ss_sa/domain$domid.ss_sa")
		{
			`cp $workdir/domain$domid/dncon2/ss_sa/domain$domid.ss_sa $outputdir/domain$domid/domain$domid.ss_sa`;
		}elsif(-e "$workdir/domain$domid/confold/dncon2/ss_sa/domain$domid.ss_sa")
		{
			`cp $workdir/domain$domid/confold/dncon2/ss_sa/domain$domid.ss_sa $outputdir/domain$domid/domain$domid.ss_sa`;
		}else{
			print "Warning: 3. Failed to find $workdir/domain$domid/dncon2/ss_sa/domain$domid.ss_sa\n";
		}


		if(-e "$workdir/domain$domid/dncon2/domain$domid.dncon2.rr")
		{
			`cp $workdir/domain$domid/dncon2/domain$domid.dncon2.rr $outputdir/domain$domid/domain$domid.dncon2.rr`;
			#print "perl $scripts_dir/P5_extract_aln_from_dncon.pl $outputdir/domain$domid/domain$domid.dncon2.rr $outputdir/domain$domid/domain$domid.dncon2.rr.stats\n";
			`perl $scripts_dir/P5_extract_aln_from_dncon.pl $outputdir/domain$domid/domain$domid.dncon2.rr $outputdir/domain$domid/domain$domid.dncon2.rr.stats`;
		}elsif(-e "$workdir/domain$domid/confold/dncon2/domain$domid.dncon2.rr")
		{
			`cp $workdir/domain$domid/confold/dncon2/domain$domid.dncon2.rr $outputdir/domain$domid/domain$domid.dncon2.rr`;
			#print "perl $scripts_dir/P5_extract_aln_from_dncon.pl $outputdir/domain$domid/domain$domid.dncon2.rr $outputdir/domain$domid/domain$domid.dncon2.rr.stats\n";
			`perl $scripts_dir/P5_extract_aln_from_dncon.pl $outputdir/domain$domid/domain$domid.dncon2.rr $outputdir/domain$domid/domain$domid.dncon2.rr.stats`;
		}else
		{
			print "Warning: 4. Failed to find $workdir/domain$domid/dncon2/domain$domid.dncon2.rr\n";
		}

		####### copy top models
		## check if alignment are found
		if(!(-e "$workdir/qa/deep.domain$domid"))
		{
			print "Warning: 10. Failed to find $workdir/qa/deep.domain$domid\n";
		}else{
			open(TMP,"$workdir/qa/deep.domain$domid");
			$indx = 0;
			while(<TMP>)
			{
				$li=$_;
				chomp $li;
				if(index($li,'.pdb')<0)
				{
					next;
				}
				$indx++;
				@tmp = split(/\s+/,$li);
				$model = $tmp[0];
				$score = sprintf("%.3f",$tmp[1]);
				@tmp2 = split(/\./,$model);
				$modelname = $tmp2[0];
				$modelpir = "$workdir/$full_length_dir/meta/$modelname.pir";
				$modelpdb = "$workdir/$full_length_dir/meta/$modelname.pdb";
				open(SCORE,">$outputdir/domain$domid/Top5_aln/domain$domid.deep$indx.deeprank");
				print SCORE "DeepRank score: $score\n";
				close SCORE;
				if(!(-e $modelpir))
				{
					#print "Failed to find $modelpir, this ab initio model\n";
				}else{
					`cp $modelpir $outputdir/domain$domid/Top5_aln/domain$domid.deep$indx.pir`;
					
					`perl $scripts_dir/P2_pir2msa_web.pl  $outputdir/domain$domid/Top5_aln/domain$domid.deep$indx.pir  $outputdir/domain$domid/Top5_aln/domain$domid.deep$indx.msa`;

					#`source /home/deep13/python_virtualenv/bin/activate`;

					`python $scripts_dir/P3_Visualize_aln_folds.py $outputdir/domain$domid/Top5_aln/domain$domid.deep$indx.msa.marker $outputdir/domain$domid/Top5_aln/domain$domid.deep$indx.msa.marker.jpeg`;


				}
				if(!(-e $modelpdb))
				{
					print "Failed to find $modelpdb\n";
				}else{
					`cp $modelpdb $outputdir/domain$domid/domain$domid.deep$indx.pdb`;
				}
				

				
				if($indx == 5)
				{
					last;
				}
			}
			close TMP;
			
			
			############# get domain alignment for full_length report 
			## get domain start 
			## get domain align information domain1/Top5_aln/domain1.deep1.msa.marker
		}

		##### generate contact information
		for($indx = 1; $indx <=5; $indx++)
		{
			mkdir("$outputdir/domain$domid/deep${indx}_contact/");
			chdir("$outputdir/domain$domid/deep${indx}_contact/");
			`cp ../domain$domid.fasta ./`;
			`cp ../domain$domid.dncon2.rr ./`;
			`cp ../domain$domid.deep$indx.pdb  ./`;
			`perl $scripts_dir/cmap/coneva-camp.pl  -fasta domain$domid.fasta -rr domain$domid.dncon2.rr  -pdb domain$domid.deep$indx.pdb  -smin 24 -o ./`;
			`perl $scripts_dir/cmap/P1_format_acc.pl long_Acc.txt  long_Acc_formated.txt`; 
		}
	}
}

#### mark done
`touch $outputdir/.done`;
