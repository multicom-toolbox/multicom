#!/bin/sh
#############################################################################
#need two input parameter: a fasta file of a protein sequence and output directory
#10 models will be generated in the output directory: hhsutie1-10.pdb
#Their corresponding alignment files are hhsuite1-10.pir
#############################################################################

/exports/store2/casp14/hhsuite/script/tm_hhsuite_main_v2.pl /exports/store2/casp14/hhsuite/hhsuite_option_v2   $1 $2 
