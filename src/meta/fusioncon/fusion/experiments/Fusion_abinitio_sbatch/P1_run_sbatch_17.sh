#!/bin/bash -l
#SBATCH -J  P1_rose_17
#SBATCH -o P1_rose_17-%j.out
#SBATCH -p Lewis
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem 10G
#SBATCH -t 1-20:00:00
mkdir /home/casp13/fusion/experiments/Fusion_abinitio/T0862
cd /home/casp13/fusion/experiments/Fusion_abinitio/T0862

/home/casp13/fusion/scripts/Fusion_Abinitio_with_contact.sh   --target  T0862    --fasta /home/casp13/dncon2_Rosetta_experiments/Fasta//T0862.fasta   --email jh7x3@mail.missouri.edu --dir  /home/casp13/fusion/experiments/Fusion_abinitio/T0862  --timeout  10  --cpu 5 --decoy 100 --model  5 &> runFusion_T0862.log

