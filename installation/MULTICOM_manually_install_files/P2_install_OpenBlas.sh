#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)
"

cd /home/casp14/MULTICOM_db_tools//tools

cd OpenBLAS

make clean

make

make PREFIX=/home/casp14/MULTICOM_db_tools//tools/OpenBLAS install

