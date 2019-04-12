
implement sam against others

generate a model profile for query

score model against sort90 or sort30, model need to be calibrated

alignment model against top scored sequences

no particular library is needed for sam package. very easy to add. 

---------------------------------

Implementation:
	1) copy hhsearch_option_cluster to sam_option and make changes

	2) cop tm_hhsearch_main.pl to tm_sam_main.pl and make changes

test phase 1: sam template ranking
done. 


Problem: for T0397, sam wasn't able to rank the best template 3D4R at the top.
problem because NR search option is too loose. now change include e-value
to e-10.

Now tweak iteration numbers and including e-value
(iteration 3, evalue =  e-10 works better interms of evalue)
(iteration 5, evalue = e-10  works same)
now set iteration to 8. (it wont change)
now set incuding evalue to 0.001 to see what will happens.
the best template 3D4RE still ranked at the top, but evalues is higher. 

Now try including evalue 0.0001, 3D4RE ranked at the top with evalue lower
than e-37. So this is the best thresholds for SAM. 

deicision: including evalue for blast alignment for sam is 0.0001. 
12/27/2009. 


test phase 2: generate alignments

/test/397_6,7,8,9

we can convert alignments into pir, then do combination based on e-value

or we can use casp8/meta/script/multicom_gen.pl to generate models, 
which is used by sp3.

let's choose the first option. 

Now we can generate both local and global alignments. However,
ever for almost the same sequence, sam can't get the front end and back end
aligned well????????// What's the problem? is it because of profile? 

How to tweak profile?
	a) including evalue
	b) return evalue
	c) nr database (latest one, old one, or filter one?)? How to choose?

or alignment problem?
	should we do pairwise alignment instead of the entire profile?
	No. this is not reason. I just did a test. it produced the same
results.

In comparison with hhsearch, hhsearch seems to generate better alignments,
but still even hhsearch miss a few residues at the end...
(/home/chengji/casp8/hhsearch/test/397_2/hh1.pir). 

On the other hand, csiblast seems to generate the best alignment:
see: /home/chengji/casp8/csblast/test/397. The entire sequences seem to
be aligned perfectly. 

************************************************************************
		***********************************************
		****************Important Task*****************
One major CASP9 task is to global-local alignments. try to extend
fron end and back end............................................
use Clustal, Spem or any other global alignment tools.
		****************Important Task*****************
		***********************************************
************************************************************************

now, test nr including evalue as 0.000001 running.............
still, now working very well. Looks like SAM HMM is very sensitive
to noise. 

now, test e-10.  

not working every well. 

so use 0.0001 as final thresholds for sam HMM
Be awware that front / end regions may not be aligned
well. (12/27/2009). Worse than hhsearch and csiblast

done. 

Now try to use the latest nr database: 
new sam option file: sam_option_nr, results are the same. 

test phase 3: generate models

running.................................
done. 

works. 

test phase 4: add into the meta pipeline

	to do. 

done. 
-------------------------------------------------------------


Concluson:
	SAM alignment has problem with tailed regions.
	it is afraid to add gaps at the begining.
	so, even for the same sequence, it may not alignment 
	front / back end regions well. 
	For easy targets, we should not use SAM as the top 1 model.

	CSI-BLAST, PSI-BLAST, HHSearch are much more robust on this issue. 

Hope SAM is good on hard TBM targets. 
---------------------------------------------------------------

direct 8 iteration psi-blast on the latest nr database is too slow.
we need to let nr database to search nr90 reduction.
and set return evalue to 0.001. 

on nr90 database it only taks 4 rounds to converge. it is much faster and
fewer sequences are returned. 

the aligment quality seems to be improved. So from now on, we will use
this new option file and nr90 for sam predictor. 
---------------------------------------------------------------------------------------






