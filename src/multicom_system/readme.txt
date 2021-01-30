This is a comprehensive casp14 tertiary stucture prediction system

It has multiple predictors

(1) template-based predictors

	psiblst-based multicom
	hhblits3 running on different databases
	hhsuite running on different databases

	Produce up to 50 models

copy multicom_server_hard_ve.pl to multicom_server.pl as start point

(2) ab initio predictors
	distance prediction
	distance-based ab initio prediction

	Select up to 50 models

(3) integration of template-based and ab initio

	Select up to 10 models


(4) domain-based prediction
	repeat (1), (2) and (3) on individual domains and combine domain models together


(5) model ranking
	full-length model ranking and domain-based model ranking
	Apollo approach
	DeepRank approach



