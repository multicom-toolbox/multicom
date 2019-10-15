#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)"

cd /home/casp14/MULTICOM_db_tools//tools

cd OpenBLAS

make clean

make NO_AFFINITY=1 USE_OPENMP=1 TARGET=NEHALEM 

make PREFIX=/home/casp14/MULTICOM_db_tools//tools/OpenBLAS install

echo "installed" > /home/casp14/MULTICOM_db_tools//tools/OpenBLAS/install.done

