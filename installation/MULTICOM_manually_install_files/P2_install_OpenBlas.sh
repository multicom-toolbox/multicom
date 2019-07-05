#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)"

cd /data/commons/MULTICOM_db_tools_v1.1//tools

cd OpenBLAS

make clean

make

make PREFIX=/data/commons/MULTICOM_db_tools_v1.1//tools/OpenBLAS install

