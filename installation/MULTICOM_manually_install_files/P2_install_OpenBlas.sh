#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)
"

cd /home/casp14/MULTICOM_TS/jie_test/multicom//tools

cd OpenBLAS

make clean

make

make PREFIX=/home/casp14/MULTICOM_TS/jie_test/multicom//tools/OpenBLAS install

