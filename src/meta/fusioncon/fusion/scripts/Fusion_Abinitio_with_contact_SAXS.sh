#!/bin/bash
source /home/jh7x3/fusion_hybrid/fusion_lib/PyRosetta.ScientificLinux-r55981.64Bit/SetPyRosettaEnvironment.sh
export PYROSETTA_DATABASE=$PYROSETTA/rosetta_database
export R_LIBS=/home/jh7x3/fusion_hybrid/fusion_lib
export PATH=$PATH:/home/jh7x3/fusion_hybrid/fusion_lib/phycmap.release/bin
python /home/casp13/fusion/scripts/Fusion_Abinitio_with_contact_SAXS.py $*
