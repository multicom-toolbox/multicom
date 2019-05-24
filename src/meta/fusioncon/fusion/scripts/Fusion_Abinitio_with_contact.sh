#!/bin/bash
source /home/casp14/MULTICOM_TS/jie_github/multicom/tools/PyRosetta4.Release.python27.linux.release-221/SetPyRosettaEnvironment.sh
export PYROSETTA_DATABASE=$PYROSETTA/rosetta_database
export R_LIBS=/home/casp14/MULTICOM_TS/jie_github/multicom/tools/Fusion/fusion_lib
export PATH=$PATH:/home/casp14/MULTICOM_TS/jie_github/multicom/tools/Fusion/fusion_lib/phycmap.release/bin
python /home/casp14/MULTICOM_TS/jie_github/multicom/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.py $*
