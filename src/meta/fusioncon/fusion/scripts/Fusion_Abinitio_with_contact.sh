#!/bin/bash
source /data/jh7x3/multicom_github/multicom/tools/Fusion/fusion_lib/PyRosetta.ScientificLinux-r55981.64Bit/SetPyRosettaEnvironment.sh
export PYROSETTA_DATABASE=$PYROSETTA/rosetta_database
export R_LIBS=/data/jh7x3/multicom_github/multicom/tools/Fusion/fusion_lib
export PATH=$PATH:/data/jh7x3/multicom_github/multicom/tools/Fusion/fusion_lib/phycmap.release/bin
python /data/jh7x3/multicom_github/multicom/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.py $*
