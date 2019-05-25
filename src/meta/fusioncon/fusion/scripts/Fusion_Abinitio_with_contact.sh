#!/bin/bash
source /home/jh7x3/multicom/tools/PyRosetta4.Release.python27.linux.release-221/SetPyRosettaEnvironment.sh
export PYROSETTA_DATABASE=$PYROSETTA/rosetta_database
export R_LIBS=/home/jh7x3/multicom/tools/Fusion/fusion_lib
export PATH=$PATH:/home/jh7x3/multicom/tools/Fusion/fusion_lib/phycmap.release/bin
python /home/jh7x3/multicom/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.py $*
