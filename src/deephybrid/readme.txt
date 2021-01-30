
15. build one more predictor (good idea)
(a) use deepmsa to generate target profile
(b) search the profile against Soeding hmm datase to identiy a list of templates
(c) use the same templates in our own database to build a customized hmm database
(d) search the target profile against the customized hmm databased to generate alignments (either hhsearch or hhblits)
change the default e-value to 1. 
(e) generate 3D models

will use the latest version of the hhsuite (/exports/store2/casp14/tools/hh-suite) to create such a system.

