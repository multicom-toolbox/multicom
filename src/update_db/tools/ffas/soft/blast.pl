#!/usr/bin/perl
###### Blast variables ########################################################
$ncbi=$ENV{'FFAS'}.'/blast';
$ffasdir=$ENV{'FFAS'}.'/soft';
$ENV{'NCBI'}=$ncbi;
$ENV{'BLASTDB'}=$ncbi.'/db';
$ENV{'BLASTMAT'}=$ncbi.'/data';

  sub co
  {
  ($d,$ea)=split(' ',$a);
  ($d,$eb)=split(' ',$b);
  return ($ea <=> $eb);
  }

  sub ParseBlast
  {
  my(@blout)=@_;
  @bdesc=(); @qstart=(); @sstart=(); @sbjct=(); @query=(); @evalue=(); @round=(); @fra=();
  $j=-1;

    foreach $line (@blout)
    {
    if ($line=~/Results from round/) {($dummy,$roun)=split('round ',$line); chomp($roun)}
    if ($line=~/^>/) {$bd=''; $con='desc'}
    if ($line=~/Length =/) {$con='wait'}
    if ($con eq 'desc') {$lin=$line; $lin=~s/^ +//; $lin=~s/ +$//; $bd.=$lin.' '}

      if ($line=~/Expect(|\(\d\)) = /)
      {
      $j++;
      $sbjct[$j]=''; $query[$j]=''; 
      $bdesc[$j]=$bd; $round[$j]=$roun; $con='start';
      ($dummy,$evalue[$j])=split(/Expect = /,$line);
      $evalue[$j]=~s/^e-/1e-/;
      $evalue[$j]=~s/ //;
      if ($evalue[$j] <= 1e-98) {$evalue[$j]=0.0}
      $fra[$j]=0;
      }

    if ($line=~/ Frame = (\S\d)/) {$fra[$j]=$1}

      if ($line=~/^Query:/) 
      {
      ($dumm,$qs,$q)=split(' ',$line);
        if ($qs=~/[A-Z]/) {$q=$qs; $q=~s/[0-9]//g; $qs=~s/[A-Z]//g}
      $query[$j].=$q;
      }
     
      if ($line=~/^Sbjct:/)
      {
      ($dumm,$ss,$s)=split(' ',$line);
        if ($ss=~/[A-Z]/) {$s=$ss; $s=~s/[0-9]//g; $ss=~s/[A-Z]//g}
      $sbjct[$j].=$s;
      if ($con eq 'start') {$qstart[$j]=$qs; $sstart[$j]=$ss; $con='cont'}
      }
    }

  @evs=();
  $saved=' ';
  $last_round=0;
    for ($k=0; $k <= $#bdesc; $k++)
    {
    $j=$#bdesc-$k;
    $des=$bdesc[$j]; $des=~s/>gi\|//;
    ($bde,$dumm)=split('\|| ',$des,2);
    if ($saved!~/ $bde /)
      {
      $saved.=$bde.' ';
      push(@evs, "$j $evalue[$j]\n");
      if ($round[$j] > $last_round) {$last_round=$round[$j]}
      }
    }
 
    @evs=sort co @evs;

    for ($k=0; $k <= $#evs; $k++)
    {
    ($j,$e)=split(' ',$evs[$k]);
    $bdesc[$j].=':_:';
    printf ">  %10.3e %s Frame:%i Round:%i\n",$evalue[$j],$bdesc[$j],$fra[$j],$round[$j];
    printf "%6i %-1.5000s\n",$qstart[$j],$query[$j];
    printf "%6i %-1.5000s\n",$sstart[$j],$sbjct[$j];
    }
  }
 
  sub blast
  {
  my($desc,$seq)=@_;
  $seq=~s/\n| //g; $desc=~s/^>+//g;
    if ($seq ne '')
    {
    print ">>$desc\n";
    print "$seq\n";
    open(B,"echo $seq | $ncbi/bin/blastpgp -d nr85s -a 4 -e 0.005 -h 0.005 -j 5 -v 50 -b 750 |");
    @blout=<B>;
    chomp(@blout);
    &ParseBlast(@blout);
    print ">*\n";
    }
  }


$seq='';

  while (<STDIN>)
  {
  $l=$_; chomp($l);      
    if ($l=~/^>/) 
    {
    $seq=substr($seq,0,1999); 
    &blast($desc,$seq); 
    $desc=$l; $seq=''
    }
    else 
    {$seq.=uc($l)}
  }

&blast($desc,$seq);
