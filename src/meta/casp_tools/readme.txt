This directory includes some handy tools for casp competition:
(this can be used to do manual prediction)

1) generate a model from a pir file

	pir2ts_energy.pl

2) combine domains

	./comb.pl

3) local alignments to models
	
	local2model.pl

4) model evaluation (pairwise comparison)

	q_score

	q_score_no_q (see pairwise_C), we may use this program 
	to speed up the the pairwise model evaluation process.
	It does not generate Q score. It just uses 0 for Q-score.

5) steric clash checking
	clash_check.pl

6) email models
	email_casp9_ts.pl

8) self modeling
	prosys/script/model_itself.pl

9) a tool to do alignment combination
	expan_alignment_v2.pl
  
10) a tool to convert a pdb file into casp format
	pdb2casp.pl

11) SOV score evalution

SOV: The SOV program and its running example (.sh file) are all under
/data/casp9_prepare/2nd_qa at sysbio.

have been downloaded to the current directory

12) q_score without q score
Q-score without Q: It is on Sysbio server, the executable program is
/data/casp9_prepare/script/pairwise_C/q_score_no_q.

have been downloaded to the current directory

We can use it to replace the old q_score. I have tested it. The results are
the same as old q_score except that q score is not generated.


13) casp_jury.pl
select the most common one out of a few top models



