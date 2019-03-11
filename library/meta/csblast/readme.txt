------------------------------------------------------

Develop a comparative modeling system using csblast

------------------------------------------------------

1. copy psi-blast based comparative modeling programs to script directory

done.

2. copy multicom_cm.pl to  multicom_csblast.pl

	check if $csblast_dir exists

3. in cm_option_new, add csblast directory

done.

4. cp cm_psiblast_temp_opt.pl     cm_csiblast_temp_opt.pl

this is where most changes will be made.

(1) use csiblast to blast nr

(2) convert output into align format

(3) then psi-blast to do blast with the new profile for a few iterations 

5. now we have two new versions of csblast based comparative modeling software

a) multicom_csiblast.pl
b) multicom_csblast.pl

Next casp, we will have three servers:	multicom_cluster (model selection), multicom_refine (model combination), and
multicom_bold (model refinement and ab initio)


need to add one more consensus server to
use spem & muscle on all blast, csblast, hhsearch, and compass templates. (looks like only muscle and spem are
better alignment tools).  use Voting scheme to rank templates. if all evqual
votes, select psiblast first.   

---------------------------------------------------------------------


6. add csblast and csiblast system into meta server

in casp8/meta/script: create a new file meta_server_v6.pl based on
meta_server_v5.pl

in casp8/meta/test, create a new option file meta_option_v6 based on
meta_option_new

working.


7. test system with T0388

to compare it with results on sysbio/html/refine/T0388


------------------------------------------------------------------------------

8. test on T0393.

	multicom_csblast_v2.pl does not rank the best tempalte 2I76A at the
top. Instead it found some false positives.

On the other hand, multicom_csblast_v3.pl ranked the best 2I76A at the top.

So we should use multicom_csblast_v3.pl from now on. 
	
	to do: 
		mv multicom_csblast_v2.pl to multicom_csblast_v2.pl.old


		cp multicom_csblast_v3.pl to multicom_csblast_v2.pl. 	
		(from now on, we will use this one). 

Now I just change the cm_including_evalue of csblast_option, and
multicom_csblast_v2.pl works too. 

	we still use multicom_csblast_v2.pl. mv multicom_csblast_v3.pl
	to old verson. 
---------------------------------------------------------------------------







