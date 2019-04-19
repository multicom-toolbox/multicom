#!/bin/sh

if [ $# -ne 3 ]
then
        echo "need three parameters:seq_file(fasta), output profile file, ouput pssm file."
        exit 1
fi
/home/jianlinc/prosys/script/prof_blast_gen.pl /home/jianlinc/pspro/blast2.2.8/blastpgp /home/jianlinc/pspro/data/big/big_98_X /home/jianlinc/pspro/data/nr/nr $1 $2 $3
