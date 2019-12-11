#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)"

cd /storage/tools/MULTICOM_db_tools//tools

cd OpenBLAS

make clean

make NO_AFFINITY=1 USE_OPENMP=1 TARGET=NEHALEM 

make PREFIX=/storage/tools/MULTICOM_db_tools//tools/OpenBLAS install

echo "installed" > /storage/tools/MULTICOM_db_tools//tools/OpenBLAS/install.done

