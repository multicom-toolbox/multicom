#!/bin/bash -l
#SBATCH -J  P1_rose_2
#SBATCH -o P1_rose_2-%j.out
#SBATCH -p Lewis
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem 10G
#SBATCH -t 1-20:00:00
mkdir /home/casp13/fusion/experiments/Fusion_with_contact/T0898
cd /home/casp13/fusion/experiments/Fusion_with_contact

sh /home/casp13/fusion/scripts/run_CASP13_fusion_withcontact_LongMediumShortL5.sh   T0898  /home/casp13/dncon2_Rosetta_experiments/Fasta//T0898.fasta   /home/casp13/fusion/experiments/Fusion_with_contact/T0898 /home/casp13/dncon2_Rosetta_experiments/DNCON2-Filtered//T0898.rr   &> dncon2_fusion_scratch_T0898.log &

