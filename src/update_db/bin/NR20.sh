#!/bin/bash -l
#SBATCH -J  NR20
#SBATCH -o NR20.out
#SBATCH -p Lewis,hpc5
#SBATCH -N 4
#SBATCH -n 40
#SBATCH --mem 150G
#SBATCH -t 2-00:00:00


module load openmpi/openmpi-3.1.2-mellanox

cd /storage/htc/bdm/farhan/mmseqs
#RUNNER="mpirun -np 120" /storage/htc/bdm/tools/MMseqs2/bin/mmseqs createdb /storage/htc/bdm/tools/nr_database_updated/NR_90.fasta NR90
/storage/htc/bdm/tools/MMseqs2/bin/mmseqs linclust NR90 NR20 tmp20 --min-seq-id 0.2
RUNNER="mpirun -np 120" /storage/htc/bdm/tools/MMseqs2/bin/mmseqs result2repseq NR90 NR20 NR20_lin_req
RUNNER="mpirun -np 120" /storage/htc/bdm/tools/MMseqs2/bin/mmseqs result2flat NR90 NR90 NR20_lin_req NR20.fasta --use-fasta-header

duration=$SECONDS

echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
