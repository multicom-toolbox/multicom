#!/bin/bash
source /data/jh7x3/multicom_github/jie_test/multicom/tools/PyRosetta4.Release.python27.linux.release-221/SetPyRosettaEnvironment.sh
export PYROSETTA_DATABASE=$PYROSETTA/rosetta_database
export R_LIBS=/data/jh7x3/multicom_github/jie_test/multicom/tools/Fusion/fusion_lib
export PATH=$PATH:/data/jh7x3/multicom_github/jie_test/multicom/tools/Fusion/fusion_lib/phycmap.release/bin
python /data/jh7x3/multicom_github/jie_test/multicom/src/meta/fusioncon/fusion/scripts/Fusion_Abinitio_with_contact.py $*
